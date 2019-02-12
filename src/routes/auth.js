const express = require("express");
const router = express.Router();
const passport = require("passport");
//lsdlkdslkdskl
router.post(
  "/signup",
  passport.authenticate("local.signup", {
    successRedirect: "/",
    failureRedirect: "/signup",
    failureFlash: true
  })
);
router.post('/login', (req, res, next) => {
  passport.authenticate('local.signin', {
    successRedirect: '/profile',
    failureRedirect: '/login',
    failureFlash: true
  })(req, res, next);
})




router.get('/logout', (req, res) => {
  req.logOut();
  res.redirect('/login')
})
module.exports = router;
