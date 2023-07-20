function strippedItem=cfgDlgStripHighlightPageName(item)




    strippedItem=item;
    if configset.feature('ConfigSetHighlightPageName')==0
        return;
    end

    if~ischar(item)
        DAStudio.error('Simulink:dialog:ItemMustBeCharacterString','stripHighlightTreeItem');
    end

    if(any(strfind(item,'*')))
        strippedItem=regexprep(item,{'\*\*\s','\s\(\d+\)'},{'',''});
    end
end