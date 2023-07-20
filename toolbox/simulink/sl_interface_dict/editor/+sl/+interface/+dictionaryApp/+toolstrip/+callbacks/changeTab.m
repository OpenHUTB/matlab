function changeTab(destinationTabId,cbinfo)




    pause(0.0001);
    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    currentTabName=guiObj.getCurrentTabName;
    if~strcmp(currentTabName,destinationTabId)

        guiObj.forceTabChangeByName(destinationTabId);
        currentTabName=guiObj.getCurrentTabName;
        hasTabChanged=strcmp(currentTabName,destinationTabId);
        while~hasTabChanged

            pause(0.0001);
            currentTabName=guiObj.getCurrentTabName;
            hasTabChanged=strcmp(currentTabName,destinationTabId);
        end
    end
end
