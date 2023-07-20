function registerProc(reg,pitType,pitFile,procName,procDefFile,toolDefFile)





    if isProcRegistered(reg,procName)
        DAStudio.error('ERRORHANDLER:pjtgenerator:ProcAlreadyRegistered',procName);
    end


    validatePIT(reg,pitFile);
    validateProcRegFiles(reg,procDefFile,toolDefFile);

    insertProc(reg,pitType,pitFile,procName,procDefFile,toolDefFile);

    savePIT(reg,pitFile);
end