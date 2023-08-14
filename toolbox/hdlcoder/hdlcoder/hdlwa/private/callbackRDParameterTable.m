function callbackRDParameterTable(dlg,rowIdx,colIdx,newValue)




    taskobj=Advisor.Utils.convertMCOS(dlg.getDialogSource);
    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;

    try

        hRD=hDI.hIP.getReferenceDesignPlugin;
        if~isempty(hRD)
            hRD.setParameterGUITable(rowIdx,colIdx,newValue);
        end


        hdlwa.utilUpdateRDParameterTable(mdladvObj,hDI);


        enableJTAGModelOption=hRD.getJTAGAXIParameterValue;
        enableEthernetAXIModelOption=hRD.getEthernetAXIParameterValue;
        enableEthernetOption=hDI.isProcessingSystemAvailable;

        hDI.hIP.setHostTargetInterfaceOptions(enableJTAGModelOption,enableEthernetAXIModelOption,enableEthernetOption);


        if enableEthernetAXIModelOption
            hostEthernetIPAddress=hRD.getEthernetIPAddressValue;
            hDI.hIP.setHostTargetEthernetIPAddress(hostEthernetIPAddress);
        end

        utilAdjustEmbeddedModelGen(mdladvObj,hDI)


        hDI.saveRDSettingToModel(hModel,hDI.hIP.getReferenceDesign);

    catch ME


        utilUpdateInterfaceTable(mdladvObj,hDI);


        forceGUITableCellValue(mdladvObj,hDI,rowIdx,colIdx);


        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','Parameter Table error dialog');
        setappdata(hf,'MException',ME);






        uiwait(hf);
    end


    taskobj.reset;

end

function forceGUITableCellValue(mdladvObj,hDI,rowIdx,colIdx)


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        hRD=hDI.hIP.getReferenceDesignPlugin;
        if~isempty(hRD)
            setValue=hRD.getParameterTableCellGUIValue(rowIdx,colIdx);
        end
        currentDialog.setTableItemValue('InputParameters_4',rowIdx,colIdx,setValue);
    end

end


