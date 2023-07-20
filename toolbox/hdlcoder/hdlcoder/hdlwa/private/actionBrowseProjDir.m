function actionBrowseProjDir(taskobj)



    mdladvObj=taskobj.MAObj;


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        currentDialog.apply;
    end


    browsedir=uigetdir;


    if browsedir~=0
        inputParams=mdladvObj.getInputParameters(taskobj.MAC);
        projectDir=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputProjectFolder'));
        projectDir.Value=browsedir;

        taskobj.reset;
    end

