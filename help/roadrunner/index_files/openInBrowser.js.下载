function getOpenWithConfig (component, exampleId) {
    var config = {
        coordinates: {
            component: component,
            exampleId: exampleId
        },
        repository: "MATLAB Examples",
        targetViewer: "LIVE_EDITOR"
    }
    return config;
}

function getOpenWithContainerOptions() {
    var containerOpts = {};
    return containerOpts;
}

function getOpenWithLabel() {
    this.getString = function() { 
        return getLocalizedString("Try This Example");
    }
    
    this.getStatus = function() { 
        return "user_not_licensed";
    }
}