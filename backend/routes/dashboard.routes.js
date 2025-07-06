const express = require("express");
const { protect, authorize } = require("../middleware/auth.middleware");
const {
  getStudentDashboard,
  getAdminOverview,
  getAdminAnalytics,
  getTopBorrowers,
} = require("../controllers/dashboard.controller");

const router = express.Router();

router.get("/student/:userId", protect, authorize("student", "admin"), getStudentDashboard);
router.get("/admin/overview", protect, authorize("admin"), getAdminOverview);
router.get("/admin/analytics", protect, authorize("admin"), getAdminAnalytics);
router.get("/admin/overview/top-borrowers", protect, authorize("admin"), getTopBorrowers);

module.exports = router;
