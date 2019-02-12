const express = require("express");
const router = express.Router();
const pool = require("../database");

router.get("/add", (req, res) => {
  res.render("links/add");
});

router.post("/add", async (req, res) => {
  console.log(req.body);
  const { title, url, description } = req.body;
  const newLink = {
    title,
    url,
    description
  };
  console.log(newLink);
  await pool.query("INSERT INTO links set ?", [newLink]);
  req.flash("success", "Link saved successfully");
  res.redirect("/links");
});

router.post("/edit/:id", async (req, res) => {
  const id = req.params.id;
  console.log(req.body);
  const { title, url, description } = req.body;
  const newLink = {
    title,
    url,
    description
  };
  console.log(newLink);
  await pool.query("UPDATE links set ? WHERE id= ?", [newLink, id]);
  req.flash("success", "Link edited successfully");
  res.redirect("/links");
});

router.get("/", async (req, res) => {
  const links = await pool.query("SELECT * FROM links");
  console.log(links);
  res.render("links/list", { links });
});
module.exports = router;

router.get("/delete/:id", async (req, res) => {
  const id = req.params.id;
  console.log(id);
  await pool.query("DELETE FROM links WHERE id = ?", [id]);
  req.flash("success", "Link deleted successfully");
  res.redirect("/links");
});

router.get("/edit/:id", async (req, res) => {
  const id = req.params.id;
  const links = await pool.query("SELECT * FROM links WHERE id = ?", [id]);
  console.log(links[0]);
  res.render("links/edit", { link: links[0] });
});
