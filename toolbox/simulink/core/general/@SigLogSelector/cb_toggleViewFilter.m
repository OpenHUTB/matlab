function cb_toggleViewFilter(varargin)







    me=SigLogSelector.getExplorer;
    if me.isLoadingActions
        return;
    end
    root=me.getRoot;





    if strcmp(varargin{1},'VIEW_MASKS_MENU')
        act=me.getAction('VIEW_MASKS');
        act.on=me.getAction('VIEW_MASKS_MENU').on;
        return;
    elseif strcmp(varargin{1},'VIEW_LINKS_MENU')
        act=me.getAction('VIEW_LINKS');
        act.on=me.getAction('VIEW_LINKS_MENU').on;
        return;
    elseif strcmp(varargin{1},'VIEW_ALL_SUBSYS_MENU')
        act=me.getAction('VIEW_ALL_SUBSYS');
        act.on=me.getAction('VIEW_ALL_SUBSYS_MENU').on;
        return;
    end



    me.isLoadingActions=true;
    menu_act=me.getAction([varargin{1},'_MENU']);
    menu_act.on=me.getAction(varargin{1}).on;
    me.isLoadingActions=false;



    locClearHasLoggedSignals(root);


    root.fireHierarchyChanged;


    val=me.getAction('VIEW_MASKS').on;
    me.setPreference('ShowMasks',val);

    val=me.getAction('VIEW_LINKS').on;
    me.setPreference('ShowLibraries',val);

    val=me.getAction('VIEW_ALL_SUBSYS').on;
    me.setPreference('ShowAll',val);
end



function locClearHasLoggedSignals(h)


    h.cachedHasSignals='unknown';


    if~isempty(h.childNodes)
        numChildren=h.childNodes.getCount;
        for chIdx=1:numChildren
            child=h.childNodes.getDataByIndex(chIdx);
            locClearHasLoggedSignals(child);
        end
    end

end
