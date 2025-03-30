import React from "react";
import { createRoot } from "react-dom/client";

export default class ReactHydrator {
    constructor() {
        this.pendingElements = {};
    }

    add(id, component) {
        this.pendingElements[id] = component;
    }

    done() {
        for (const [id, component] of Object.entries(this.pendingElements)) {
            const element = document.getElementById(id);
            createRoot(element).render(component);
        }
    }
}
