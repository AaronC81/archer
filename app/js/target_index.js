import React from "react";
import FilterView from "./component/FilterView.jsx";
import ResultCard from "./component/ResultCard.jsx";
import DataManager from "./data/DataManager.js";
import ReactHydrator from "./util/ReactHydrator.js";

const topLevelHydrator = new ReactHydrator();
topLevelHydrator.add("content", <FilterView targetName={globalThis.targetName} targetTitle={globalThis.targetTitle} />);
topLevelHydrator.done();
