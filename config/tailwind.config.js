const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        // LoL Official Colors
        'lol-gold': {
          DEFAULT: '#C4A15B',
          50: '#F5F0E6',
          100: '#EAE0CC',
          200: '#DCC999',
          300: '#CDB166',
          400: '#C4A15B',
          500: '#A88745',
          600: '#8C6D30',
          700: '#6B5323',
          800: '#4A3918',
          900: '#2A200D',
        },
        'lol-blue': {
          DEFAULT: '#548CB4',
          50: '#E8F1F7',
          100: '#D1E3EF',
          200: '#A3C7DF',
          300: '#75ABCF',
          400: '#548CB4',
          500: '#427099',
          600: '#30547E',
          700: '#1E3863',
          800: '#0C1C48',
          900: '#06102D',
        },
        // Dark Theme Base
        'navy': {
          50: '#E8E9F0',
          100: '#D1D3E1',
          200: '#A3A7C3',
          300: '#757BA5',
          400: '#474F87',
          500: '#2A3158',
          600: '#1F2640',
          700: '#15182E',
          800: '#0E1020',
          900: '#0A0E27',
        },
        // Role Colors
        'role-top': {
          DEFAULT: '#E74C3C',
          light: '#EC7063',
          dark: '#C0392B',
        },
        'role-jungle': {
          DEFAULT: '#9B59B6',
          light: '#BB8FCE',
          dark: '#7D3C98',
        },
        'role-mid': {
          DEFAULT: '#F39C12',
          light: '#F8C471',
          dark: '#D68910',
        },
        'role-adc': {
          DEFAULT: '#3498DB',
          light: '#5DADE2',
          dark: '#2874A6',
        },
        'role-support': {
          DEFAULT: '#2ECC71',
          light: '#58D68D',
          dark: '#28B463',
        },
      },
      boxShadow: {
        'glow-sm': '0 0 10px rgba(196, 161, 91, 0.3)',
        'glow': '0 0 20px rgba(196, 161, 91, 0.4)',
        'glow-lg': '0 0 30px rgba(196, 161, 91, 0.5)',
        'glow-xl': '0 0 40px rgba(196, 161, 91, 0.6)',
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
