
function OpenConfigureSetAndHighlightUndefinedFunctionHandling(modelName)
    load_system(modelName);
    configset.highlightParameter(modelName,'CustomCodeUndefinedFunction');
end
