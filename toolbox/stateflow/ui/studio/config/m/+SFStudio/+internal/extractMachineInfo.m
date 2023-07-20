function[machineName,status,chartH]=extractMachineInfo(cbInfo)
    status.enabled=false;
    machineName='';
    chartH=cbInfo.uiObject;
    if isempty(chartH)
        return;
    end

    machineH=chartH.Machine;
    isLibrary=machineH.isLibrary;

    if isLibrary
        editor=cbInfo.studio.App.getActiveEditor();
        linkChartH=SFStudio.Utils.getOpenLinkedInstanceForChart(chartH,editor);
        if isempty(linkChartH)




            return;
        else



            chartH=linkChartH;
            machineName=linkChartH.Machine.Name;
            status.enabled=true;
            return;
        end
    end

    status.enabled=true;
    machineName=machineH.Name;
end