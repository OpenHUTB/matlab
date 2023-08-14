function utilAdjustGenerateAXISlave(mdladvObj,hDI)



    if~hDI.isIPCoreGen
        return;
    end


    targetInterfaceTaskID=utilGetTargetInterfaceTask(hDI);
    inputParams=mdladvObj.getInputParameters(targetInterfaceTaskID);

    axi4SlaveOn=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAGenerateAXI4Slave'));
    axi4SlaveOnOldValue=hDI.hIP.getAXI4SlaveEnable;

    if axi4SlaveOnOldValue~=axi4SlaveOn.Value


        hDI.hIP.setAXI4SlaveEnable(axi4SlaveOn.Value)
    end




    hDI.hIP.adjustAXI4SlaveEnable;
    hDI.hIP.adjustAXI4SlaveEnableGUI;


    if(axi4SlaveOn.Value~=hDI.hIP.getAXI4SlaveEnable)

        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            currentDialog.setWidgetValue('InputParameters_4',hDI.hIP.getAXI4SlaveEnable);
        end
    end

    axi4SlaveOn.Value=hDI.hIP.getAXI4SlaveEnable;
    axi4SlaveOn.Enable=hDI.hIP.getAXI4SlaveEnableGUI;

end