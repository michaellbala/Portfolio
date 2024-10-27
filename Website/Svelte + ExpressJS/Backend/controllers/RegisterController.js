const express = require('express')
const {validationResult} = require('express-validator')
const bcrypt = require('bcrypt')
const prisma = require('../prisma/client')

const register = async (req, res) => {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
        return res.status(422).json({
            success: false,
            message: 'Validation failed',
            errors: errors.array()})
    }
    
    const hashedPassword = await bcrypt.hash(req.body.password, 10)
    try {
        const user = await prisma.user.create({
            data: {
                name : req.body.name,
                email : req.body.email,
                password: hashedPassword
            }
        })
        res.status(201).json({
            success: true,
            message: 'Register Success',
            user: user
        })
    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message})
    }
}

module.exports = {
    register
}