const express = require("express");
const morgan = require("morgan");

const CookieParser = require('cookie-parser');
const authRoutes = require('./routes/auth');
const Pg = require('pg');
const ConnectPg = require('connect-pg-simple');
const bodyParser = require('body-parser')
//session de Node
const Session = require("express-session");
const User = require('./models/user');
//initiaizations
const passport = require("passport");
const app = express();
//require("./lib/passport");
app.use(bodyParser.json())

//settings
app.set("port", process.env.PORT || 4000);

app.use(express.static(__dirname + '/public'))



//Middleware



app.use(morgan("dev"));
//Esto es para pps chicas, ver más adelante
app.use(express.urlencoded({ extended: false }));
app.use(express.json());


//Global variables
const pgSession = ConnectPg(Session);
app.use(CookieParser());
app.use(Session({
  store: new pgSession({
    pg: Pg,
    conString:"postgres://postgres:postgres@localhost:5433/hospital",
    tableName: 'session',
    schemaName: 'public',
  }),
  secret: "super_secret",
  resave: false,
  saveUninitialized: false,
  cookie: {httpOnly: true, secure: false}
}));

app.use(passport.initialize());
app.use(passport.session());

passport.serializeUser(function(user, done) {
  done(null, user.rut);
});

passport.deserializeUser(function(id, done) {
  User.findOne({ where: {rut: id} })
  .then(user=>{
    return done(null, user)
  }) 
});


// Load passport strategies



const isAuthenticated = (req, res, next) => {
  if (req.isAuthenticated()) {
    return next();
  }
  res.status(401).json({
    error: 'Unauthorized access',
    message: 'User must be logged to access the specified URI'
  });
};

// Routes
app.use(`/auth`, authRoutes);
//app.use("/links", require("./routes/links"));
app.use("/pg", require("./routes/hospital"));




app.listen(app.get("port"), () => {
  console.log(`Server on port ${app.get("port")}`);
});
