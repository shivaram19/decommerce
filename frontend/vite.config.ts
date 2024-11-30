import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from "path"

// https://vite.dev/config/
export default defineConfig({
  build :{
    outDir: path.resolve(__dirname, '../dist'), // Adjust this path as needed
  },
  plugins: [react()],
})
