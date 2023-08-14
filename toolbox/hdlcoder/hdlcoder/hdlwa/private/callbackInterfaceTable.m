function callbackInterfaceTable(dlg,rowIdx,colIdx,newValue)



    taskobj=Advisor.Utils.convertMCOS(dlg.getDialogSource);
    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;

    try


        [launchAddInterfaceGUI,launchSetInterfaceOptGUI]=hDI.hTurnkey.hTable.setInterfaceTableGUI(rowIdx,colIdx,newValue);
        if launchAddInterfaceGUI

            forceGUITableCellValue(mdladvObj,hDI,rowIdx,colIdx);


            hAddInterfaceGUI=hdlturnkey.interface.AddInterfaceGUI(taskobj,hDI.hTurnkey);
            hDlg=DAStudio.Dialog(hAddInterfaceGUI);
        elseif launchSetInterfaceOptGUI

            hSetInterfaceOptGUI=hdlturnkey.interface.SetInterfaceOptionGUI(taskobj,hDI.hTurnkey,rowIdx);
            hDlg=DAStudio.Dialog(hSetInterfaceOptGUI);
        end


        utilUpdateInterfaceTable(mdladvObj,hDI);


        utilAdjustGenerateAXISlave(mdladvObj,hDI);


    catch ME


        utilUpdateInterfaceTable(mdladvObj,hDI);


        utilAdjustGenerateAXISlave(mdladvObj,hDI);


        forceGUITableCellValue(mdladvObj,hDI,rowIdx,colIdx);


        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','Target Interface Table error dialog');
        setappdata(hf,'MException',ME);






        uiwait(hf);
    end


    taskobj.reset;

end

function forceGUITableCellValue(mdladvObj,hDI,rowIdx,colIdx)


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        setValue=hDI.hTurnkey.hTable.getTableCellGUIValue(rowIdx,colIdx);
        if hDI.showExecutionMode
            currentDialog.setTableItemValue('InputParameters_2',rowIdx,colIdx,setValue);
        else
            currentDialog.setTableItemValue('InputParameters_1',rowIdx,colIdx,setValue);
        end
    end

end


