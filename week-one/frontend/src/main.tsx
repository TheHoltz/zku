import { render } from "preact";
import { App } from "./pages/home";
import "./index.css";

render(<App />,
    document.getElementById("app")!
);
