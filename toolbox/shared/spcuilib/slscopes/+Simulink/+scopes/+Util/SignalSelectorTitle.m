function title=SignalSelectorTitle(block)
    if Simulink.scopes.Util.IsModelBased(block)
        title=viewertitle(block,true);
    else
        title=getfullname(block);
    end
end
