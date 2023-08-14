function actionLaunchHDLSettings(taskobj)


    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;
    mdlName=bdroot(system);
    sectionName=DAStudio.message('HDLShared:hdldialog:hdlccHDLCodername');


    hcc=gethdlcc(mdlName);
    if~isempty(hcc)
        hcc.createCLI;
        configset.showParameterGroup(mdlName,{sectionName});
    end

end
