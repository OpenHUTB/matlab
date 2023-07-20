function actionBrowseIPRepository(taskobj)



    mdladvObj=taskobj.MAObj;


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        currentDialog.apply;
    end


    browsedir=uigetdir;


    if browsedir~=0
        inputParams=mdladvObj.getInputParameters(taskobj.MAC);
        repositoryDir=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPRepository'));
        repositoryDir.Value=browsedir;

        taskobj.reset;
    end


