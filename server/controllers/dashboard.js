const error404 = (req, res) => {
    res.redirect("/dashboard");
};

module.exports = {
    error404,
};
