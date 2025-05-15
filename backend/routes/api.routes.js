import express from "express";  
import { number1Controller } from "../controllers/number1.controller.js";
import { number2Controller } from "../controllers/number2.controller.js";
import { number3Controller } from "../controllers/number3.controller.js";
import { number4Controller } from "../controllers/number4.controller.js";
import { number5Controller } from "../controllers/number5.controller.js";

const router = express.Router();

router.get('/category', number1Controller);
router.get('/number2', number2Controller);
router.get('/number3', number3Controller);
router.get('/number4', number4Controller);
router.get('/number5', number5Controller);

export default router;