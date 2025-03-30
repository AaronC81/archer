import React from "react";
import { createRoot } from "react-dom/client";
import FilterView from "./component/FilterView.jsx";

createRoot(document.getElementById("content"))
    .render(<FilterView targetName={globalThis.targetName} targetTitle={globalThis.targetTitle} />);
