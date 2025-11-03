/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Add the custom colors from your teammate's files
        'beige-50': '#fefaf0',
        'beige-100': '#fdf6e3',
        'beige-200': '#faf0d7',
        'beige-300': '#e5d5b8',
        'green-50': '#f0fdf4',
        'green-100': '#dcfce7',
        'green-600': '#16a34a',
        'green-700': '#15803d',
        'brown-50': '#fef7ed',
        'brown-600': '#ea580c',
      }
    },
  },
  plugins: [],
}