function importCostData(cbinfo)




    [matFile,matFilePath]=uigetfile('*.mat','Select a MAT File');

    if matFile==0
        return
    end
    model=cbinfo.model.Name;
    appMgr=multicoredesigner.internal.UIManager.getInstance();
    modelH=get_param(model,'Handle');


    if~isPerspectiveEnabled(appMgr,modelH)
        openPerspective(appMgr,modelH);
    end

    uiObj=getMulticoreUI(appMgr,modelH);
    filePath=fullfile(matFilePath,matFile);
    uiObj.importCostFromMATFile(filePath);



