function removeAllHighlights(~)

    allSys=find_system('SearchDepth',0);
    for ii=1:length(allSys)
        set_param(allSys{ii},'HiliteAncestors','off');
    end

    stylerName='CloneDetection.styleAllClones';
    styler=diagram.style.getStyler(stylerName);
    if~(isempty(styler))
        styler.clearAllClasses();
    end
