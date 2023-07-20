



function hiliteBlock(modelName,blockHandles)
    styler=SLStudio.AttentionStyler;
    styler.clearAllStylers(modelName);
    arrayfun(@(x)styler.applyHighlight(x),blockHandles);
end