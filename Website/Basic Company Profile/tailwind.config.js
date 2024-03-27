/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['index.html'],
  theme: {
    extend: {
      container: {
        center: true,
        padding: '16px',
        
      },

      colors: {
        primaryColor : '#020617',

      },

      screens: {
        '3xl' : '1920px',
      }

    },
  },
  plugins: [require("daisyui")],
}

