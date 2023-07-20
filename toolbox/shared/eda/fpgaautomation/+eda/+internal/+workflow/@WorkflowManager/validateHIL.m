function success=validateHIL(h,continueOnWarn)





    vstruct.name=true;
    vstruct.folder=true;
    vstruct.userfiles=false;
    vstruct.processprop=false;

    h.validateNewProjectParam(vstruct);

    success=h.checkProjectOverwrite(continueOnWarn);

