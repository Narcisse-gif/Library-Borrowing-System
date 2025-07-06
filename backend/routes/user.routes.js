const express = require("express");
const router = express.Router();
const { getAllUsers } = require("../controllers/user.controller");
const { protect, authorize } = require("../middleware/auth.middleware");

router.get("/", protect, authorize("admin"), getAllUsers);

module.exports = router;
