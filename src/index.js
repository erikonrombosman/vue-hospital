const express = require("express");
const morgan = require("morgan");
const exphbs = require("express-handlebars");
const path = require("path");
const flash = require("connect-flash");
//session de Node
const session = require("express-session");
//session para mysql
const mysqlStore = require("express-mysql-session");
//datos de la bd mysql
const { database } = require("./keys");

//initiaizations
const passport = require("passport");
const app = express();
require("./lib/passport");

//settings
app.set("port", process.env.PORT || 4000);

app.use(express.static(__dirname + '/public'))
//Middleware
app.use(
  session({
    secret: "erik",
    resave: false,
    saveUninitialized: false,
    store: new mysqlStore(database)
  })
);
app.use(flash());
app.use(morgan("dev"));
//Esto es para pps chicas, ver más adelante
app.use(express.urlencoded({ extended: false }));
app.use(express.json());
app.use(passport.initialize());
app.use(passport.session());

//Global variables
app.use((req, res, next) => {
  app.locals.success = req.flash("success");
  app.locals.user = req.user
  next();
});
//Routes
//app.use(require("./routes"));
app.use(require("./routes/auth"));
app.use("/links", require("./routes/links"));
//Public
//app.use(express.static(path.join(__dirname, "public")));
//Starting the server
app.listen(app.get("port"), () => {
  console.log(`Server on port ${app.get("port")}`);
});
