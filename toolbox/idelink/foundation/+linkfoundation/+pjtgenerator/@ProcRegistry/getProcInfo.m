function info=getProcInfo(reg,procName)





    [procIdx,pitIdx,pitType]=getProcRegIdx(reg,procName);
    if isempty(procIdx)

        DAStudio.error('ERRORHANDLER:pjtgenerator:ProcIsNotRegistered',procName);
    end




    eval(['pitPath = fileparts(reg.pit_',pitType,'(',num2str(pitIdx)...
    ,').pitFileName);']);
    eval(['procDefFile = reg.pit_',pitType,'(',num2str(pitIdx)...
    ,').pit(',num2str(procIdx),').procDefFile;']);
    eval(['toolDefFile = reg.pit_',pitType,'(',num2str(pitIdx)...
    ,').pit(',num2str(procIdx),').toolDefFile;']);

    if(~exist(fullfile(pitPath,procDefFile),'file')||...
        ~exist(fullfile(pitPath,toolDefFile),'file'))

        procImportFcn=[reg.tag,'_importProc'];
        if exist(procImportFcn,'file')
            ret=feval(procImportFcn,procName);
        end
    end
    info=loadDefFiles(reg,...
    fullfile(pitPath,procDefFile),...
    fullfile(pitPath,toolDefFile));

end
