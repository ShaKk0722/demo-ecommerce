import pool from "../db/db.js";

const queryTest = async () => {
    const query = `
    SELECT
    u.full_name AS name,
    u.email,
    u.phone,
    a.province,
    a.district,
    a.commune,
    a.detail_address AS address,
    a.housing_type
    FROM users u
    JOIN customer c ON u.user_id = c.user_id
    JOIN addresses a ON u.user_id = a.user_id
    WHERE u.email = 'gu@gmail.com';
    `;
    try {
        pool.query(query);
    } catch (error) {
        console.error("Error query", error);
    }
};

export default queryTest();
