function onMouseEnter(obj,data)




    mdl=data.model;
    sids=unique(data.sids);
    handles=simulinkcoder.internal.util.getHandle(mdl,sids);

    styler=SLStudio.AttentionStyler;
    styler.clearAllStylers(mdl);

    arrayfun(@(x)styler.applyHighlight(x),handles);

