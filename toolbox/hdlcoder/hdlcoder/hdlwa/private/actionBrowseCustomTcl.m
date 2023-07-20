function actionBrowseCustomTcl(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        currentDialog.apply;
    end


    [filename,filepath]=uigetfile('*.tcl');


    if filename~=0
        file=fullfile(filepath,filename);
        hDI.setCustomBuildTclFile(file);
        taskobj.reset;
    end

    utilAdjustEmbeddedSystemBuild(mdladvObj,hDI);