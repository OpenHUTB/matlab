function actionBrowseUsrpFolder(taskobj)



    mdladvObj=taskobj.MAObj;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    usrpFolder=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAUsrpSourceFolder'));



    startpath=usrpFolder.Value;
    if~ischar(startpath)
        startpath=pwd;
    end
    folder=uigetdir(startpath,'Select USRP Source File Folder');

    usrpFolder.Value=folder;

