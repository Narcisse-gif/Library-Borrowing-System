const app = require('./app');
require("./cron/jobs");


const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

require("dotenv").config();

