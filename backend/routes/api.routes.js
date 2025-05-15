import express from "express";  

import { fetchCategory } from "../controllers/fetchCategory.controller.js";
import { fetchProductsByCategory } from "../controllers/fetchProduct.controller.js";
import { searchProducts } from "../controllers/searchProducts.controller.js";

const router = express.Router();

router.get('/category', fetchCategory);
router.get('/categories/:categoryId/products', fetchProductsByCategory);
router.get('/products/search', searchProducts);


export default router;