function success=validateGenerateTcl(h)




    success=1;

    userParam=h.mWorkflowInfo.userParam;


    if strcmpi(userParam.tclOption,'Create new project')
        vstruct.name=true;
        vstruct.folder=false;
        vstruct.userfiles=true;
        vstruct.processprop=true;

        h.validateNewProjectParam(vstruct);
    end
