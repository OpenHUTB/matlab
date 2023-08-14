function onCleanupObj=disableWidgets(this,dlg)






    widgetTagsToDisable={'edaButtonSet','edaWidgetGroupHwOpt',...
    'edaWidgetGroupSrcFile','edaWidgetGroupPorts','edaWidgetGroupBuildOpt'};

    for m=1:numel(widgetTagsToDisable)
        setEnabled(dlg,widgetTagsToDisable{m},false);
    end
    this.EnableDialog=false;
    onCleanupObj=onCleanup(@()l_myCleanupFcn(this,dlg));

    function l_myCleanupFcn(this,dlg)
        this.EnableDialog=true;
        for n=1:numel(widgetTagsToDisable)
            setEnabled(dlg,widgetTagsToDisable{n},true);
        end
    end

end
