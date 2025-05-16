import pool from '../db/db.js';


export const searchProducts = async (req, res) => {
    try {

        const {
            q,              // Search term
            category,       // Category ID
            brand,          // Brand name
            color,          // Color
            size,           // Size
            min_price,      // Minimum price
            max_price,      // Maximum price
            page = 1,       // Page number (default: 1)
            limit = 20      // Results per page (default: 20)
        } = req.query;


        const pageInt = parseInt(page) || 1;
        const limitInt = parseInt(limit) || 20;
        const offset = (pageInt - 1) * limitInt;


        let conditions = [];
        let params = [];
        let paramCount = 1;


        const addCondition = (column, value, operator = '=') => {
            if (value !== undefined && value !== null && value !== '') {
                if (operator === 'LIKE') {
                    conditions.push(`${column} ILIKE $${paramCount}`);
                    params.push(`%${value}%`);
                } else if (operator === '>=') {
                    conditions.push(`${column} >= $${paramCount}`);
                    params.push(parseFloat(value));
                } else if (operator === '<=') {
                    conditions.push(`${column} <= $${paramCount}`);
                    params.push(parseFloat(value));
                } else {
                    conditions.push(`${column} = $${paramCount}`);
                    params.push(value);
                }
                paramCount++;
            }
        };


        if (q) {
            conditions.push(`(
                p.product_name ILIKE $${paramCount} OR
                p.brand ILIKE $${paramCount} OR
                p.model ILIKE $${paramCount}
            )`);
            params.push(`%${q}%`);
            paramCount++;
        }

        if (category) {
            addCondition('p.categoryNo', category);
        }


        if (brand) {
            addCondition('p.brand', brand, 'LIKE');
        }


        if (color) {
            addCondition('p.color', color, 'LIKE');
        }


        if (size) {
            addCondition('p.size', size);
        }

        if (min_price) {
            addCondition('s.price', min_price, '>=');
        }

        if (max_price) {
            addCondition('s.price', max_price, '<=');
        }

        const whereClause = conditions.length > 0 
            ? 'WHERE ' + conditions.join(' AND ') 
            : '';


        const productsQuery = `
            SELECT 
                p.product_id, 
                p.product_name, 
                p.model, 
                p.color, 
                p.product_imageURL, 
                p.brand, 
                p.size,
                MIN(s.price) AS price,
                c.category_id,
                c.category_name
            FROM product p
            JOIN supply s ON p.product_id = s.product_id
            JOIN category c ON p.categoryNo = c.category_id
            ${whereClause}
            GROUP BY 
                p.product_id, 
                p.product_name, 
                p.model, 
                p.color, 
                p.product_imageURL, 
                p.brand, 
                p.size,
                c.category_id,
                c.category_name
            ORDER BY 
                CASE WHEN $${paramCount} = 'price_asc' THEN MIN(s.price) END ASC,
                CASE WHEN $${paramCount} = 'price_desc' THEN MIN(s.price) END DESC,
                CASE WHEN $${paramCount} = 'name_asc' THEN p.product_name END ASC,
                CASE WHEN $${paramCount} = 'name_desc' THEN p.product_name END DESC,
                CASE WHEN $${paramCount} NOT IN ('price_asc', 'price_desc', 'name_asc', 'name_desc') THEN p.product_id END ASC
            LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}
        `;


        const sort = req.query.sort || 'product_id';
        let sortOption;
        

        if (sort === 'price_asc') sortOption = 'price_asc';
        else if (sort === 'price_desc') sortOption = 'price_desc';
        else if (sort === 'name_asc') sortOption = 'name_asc';
        else if (sort === 'name_desc') sortOption = 'name_desc';
        else sortOption = 'product_id';

        params.push(sortOption, limitInt, offset);


        const productsResult = await pool.query(productsQuery, params);
        const products = productsResult.rows.map(row => {
            return {
                product_id: row.product_id,
                product_name: row.product_name,
                model: row.model,
                color: row.color,
                product_imageURL: row.product_imageURL,
                brand: row.brand,
                size: row.size,
                price: parseFloat(row.price),
                category: {
                    category_id: row.category_id,
                    category_name: row.category_name
                }
            };
        });


        let countParams = [...params.slice(0, params.length - 3)]; 
        const countQuery = `
            SELECT COUNT(DISTINCT p.product_id) AS total
            FROM product p
            JOIN supply s ON p.product_id = s.product_id
            JOIN category c ON p.categoryNo = c.category_id
            ${whereClause}
        `;
        
        const countResult = await pool.query(countQuery, countParams);
        const total = parseInt(countResult.rows[0].total);
        const totalPages = Math.ceil(total / limitInt);


        const filtersQuery = `
            SELECT
                p.brand,
                COUNT(DISTINCT p.product_id) AS brand_count,
                p.color,
                COUNT(DISTINCT p.product_id) AS color_count
            FROM product p
            JOIN supply s ON p.product_id = s.product_id
            ${whereClause}
            GROUP BY p.brand, p.color
            ORDER BY p.brand, p.color
        `;
        
        const filtersResult = await pool.query(filtersQuery, countParams);
        

        const brands = [];
        const colors = [];
        
        filtersResult.rows.forEach(row => {
            if (row.brand && !brands.some(b => b.brand === row.brand)) {
                brands.push({
                    brand: row.brand,
                    count: parseInt(row.brand_count)
                });
            }
            
            if (row.color && !colors.some(c => c.color === row.color)) {
                colors.push({
                    color: row.color,
                    count: parseInt(row.color_count)
                });
            }
        });


        return res.status(200).json({
            success: true,
            data: {
                products,
                pagination: {
                    total,
                    page: pageInt,
                    limit: limitInt,
                    pages: totalPages
                },
                filters: {
                    brands,
                    colors
                }
            }
        });

    } catch (error) {
        console.error('Error searching products:', error);
        
        return res.status(500).json({
            success: false,
            error: {
                code: 500,
                message: 'Failed to search products',
                details: error.message
            }
        });
    }
}

