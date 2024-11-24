module.exports = {
  username: process.env.DB_USER || "postgres",
  password: process.env.DB_PWD || "postgres",
  database: "bia",
  host: process.env.DB_HOST || "bia.cbu8yu2a03r9.us-east-1.rds.amazonaws.com",
  port: process.env.DB_PORT || 5432,
  dialect: "postgres",
};
