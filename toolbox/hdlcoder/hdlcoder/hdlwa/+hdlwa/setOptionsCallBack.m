function[status,message]=setOptionsCallBack(taskobj)




    taskobj=Advisor.Utils.convertMCOS(taskobj);
    status=true;
    message='';

    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;
    mdlName=bdroot(system);

    try

        hcc=gethdlcc(mdlName);
        hcc.runDialogApplyCallback;

        taskobj.reset;

    catch me
        status=false;
        message=me.message;
    end
