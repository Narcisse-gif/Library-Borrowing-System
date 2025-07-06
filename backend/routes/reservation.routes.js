const express = require("express");
const {
  reserveBook,
  getUserReservations,
  getAllReservations,
  cancelReservation,
  getBookQueue,
  fulfillReservation,
  expireOldReservations,
} = require("../controllers/reservation.controller");

const { protect, authorize } = require("../middleware/auth.middleware");

const router = express.Router();

router.post("/", protect, authorize("student"), reserveBook);
router.get("/user/:userId", protect, authorize("student", "admin"), getUserReservations);
router.put("/:id/cancel", protect, authorize("student", "admin"), cancelReservation);
router.get("/queue/:bookId", protect, authorize("admin"), getBookQueue);
router.put("/:id/fulfill", protect, authorize("admin"), fulfillReservation);
router.put("/expire/check", protect, authorize("admin"), expireOldReservations); // can be hooked to a cron job
router.get("/", protect, authorize("admin"), getAllReservations);


module.exports = router;
