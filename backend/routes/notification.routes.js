const express = require("express");
const { sendTestEmail, sendTestReminder } = require("../controllers/notification.controller");

const router = express.Router();

router.get("/test", sendTestEmail);
router.get("/reminder", sendTestReminder);

module.exports = router;
