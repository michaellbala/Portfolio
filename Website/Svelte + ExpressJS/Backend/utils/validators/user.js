const {body} = require("express-validator");
const prisma = require("../../prisma/client");

const validateUser = [
    body("name")
        .notEmpty()
        .withMessage("Name is required")
        .isLength({min: 3})
        .withMessage("Name must be at least 3 characters long"),
    body("email")
        .notEmpty()
        .withMessage("Email is required")
        .isEmail()
        .withMessage("Email is invalid")
        .custom(async (value) => {
            if (!value) {
                throw new Error("Email is required");
            }
            const user = await prisma.user.findUnique({where: {email: value}});
            if (user && user.id !== Number(req.params.id)) {
                throw new Error("Email already exists");
            }
            return true;
        }),
    body("password")
        .notEmpty()
        .withMessage("Password is required")
        .isLength({min: 6})
        .withMessage("Password must be at least 6 characters long"),
];

module.exports = {validateUser}