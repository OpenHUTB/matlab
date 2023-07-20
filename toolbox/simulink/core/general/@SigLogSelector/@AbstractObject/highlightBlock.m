function highlightBlock(h,bHighlight)






    me=SigLogSelector.getExplorer;
    me.sleep;


    mdl=h.getBdRoot;
    bd=get_param(mdl,'Object');
    bd.hilite('off');
    slprivate('remove_hilite',mdl);


    if bHighlight
        open_system(mdl,'force');
        hilite_system(h.getBlockName);
    end


    me.wake;
end
