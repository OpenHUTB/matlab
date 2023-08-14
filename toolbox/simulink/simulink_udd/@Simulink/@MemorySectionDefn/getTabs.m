function msSubTabs=getTabs(hThis,hUI)




    msSubTabs=hThis.getMSPropDetails(hUI);


    isRegFileReadOnly=hUI.isCSCRegFileReadOnly;
    if isRegFileReadOnly
        for i=1:size(msSubTabs.Tabs,2)
            msSubTabs.Tabs{i}=Simulink.CSCUI.disableWidgets(msSubTabs.Tabs{i});
        end
    end

end






