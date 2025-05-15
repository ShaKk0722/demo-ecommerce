import pool from '../db/db.js';

/**
 * Fetch all product categories
 * GET /category
 */
export const fetchCategory = async (req, res) => {
    try {
        const query = `
            SELECT 
                category_id, 
                category_name, 
                category_description, 
                category_imageURL 
            FROM category
            ORDER BY category_id;
        `;

        const result = await pool.query(query);

        return res.status(200).json({
            success: 'true',
            data: result.rows
        });

    } catch (error) {
        console.error('Error fetching categories:', error);

        return res.status(500).json({
            success: 'false',
            message: 'Failed to fetch categories',
            error: error.message
        });
    }
};