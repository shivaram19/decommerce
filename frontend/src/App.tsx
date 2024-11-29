import { Cover } from "./components/ui/cover"

function App() {
  return (
    <div className="bg-gradient-to-r from-blue-500 w-screen h-screen flex">
      <h1 className="text-4xl md:text-4xl lg:text-6xl font-semibold max-w-7xl mx-auto text-center bg-clip-text text-transparent  text-black bg-gradient-to-b from-neutral-800 via-neutral-700 to-neutral-700 dark:from-neutral-800 dark:via-white dark:to-white flex justify-center gap-2 flex-col">
        Building the next BIG DECOMMERCE  <br /><Cover>Coming Soon...</Cover>
      </h1>
    </div>
  )
}

export default App
