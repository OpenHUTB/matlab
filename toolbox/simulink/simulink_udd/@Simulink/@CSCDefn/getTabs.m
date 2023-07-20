function cscSubTabs=getTabs(hThis,hUI)




    cscSubTabs=hThis.getCSCPropDetails(hUI);


    isRegFileReadOnly=hUI.isCSCRegFileReadOnly;
    if isRegFileReadOnly
        for i=1:size(cscSubTabs.Tabs,2)
            cscSubTabs.Tabs{i}=Simulink.CSCUI.disableWidgets(cscSubTabs.Tabs{i});
        end
    end

end


