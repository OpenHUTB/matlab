function hiliteHelpTextItem=updateHighlightHelpTextCatelog(sel)









    highlightMode=sel.sourceObj.highlightMode;

    if strcmp(highlightMode,'source')
        if(strcmp(sel.type,'rate')&&isempty(sel.SourceBlocks)&&isempty(sel.RateOwner))
            hiliteHelpTextItem='Simulink:utility:ColorWithHiddenSrcBlock';
        else
            hiliteHelpTextItem='Simulink:utility:HighlightOrigHelpText';
        end
    elseif strcmp(highlightMode,'all')
        if strcmp(sel.type,'rate')&&isempty(sel.AllBlocks)
            hiliteHelpTextItem='Simulink:utility:ColorWithHiddenBlock';
        else
            hiliteHelpTextItem='Simulink:utility:HighlightAllHelpText';
        end
    end
end
