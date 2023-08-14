function actionBrowseXilinxSimLibPath(taskobj)



    mdladvObj=taskobj.MAObj;


    browsedir=uigetdir;


    if browsedir~=0
        inputParams=mdladvObj.getInputParameters(taskobj.MAC);
        projectDir=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputXilinxLibraryPath'));
        projectDir.Value=browsedir;
    end

