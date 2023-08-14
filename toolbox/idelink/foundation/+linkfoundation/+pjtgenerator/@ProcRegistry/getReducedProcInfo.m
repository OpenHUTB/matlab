function info=getReducedProcInfo(reg,procName)






    procIdx=getProcRegIdx(reg,procName);
    if isempty(procIdx)

        DAStudio.error('ERRORHANDLER:pjtgenerator:ProcIsNotRegistered',procName);
    end





    procImportFcn=[reg.tag,'_getReducedProcInfo'];
    if exist(procImportFcn,'file')
        info=feval(procImportFcn,procName);
    else
        info=getProcInfo(reg,procName);
    end

end
