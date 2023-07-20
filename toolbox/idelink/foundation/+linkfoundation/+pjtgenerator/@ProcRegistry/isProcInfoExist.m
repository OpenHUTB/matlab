function ret=isProcInfoExist(reg,procName,pitType)






    if(nargin>2)
        [procIdx,pitIdx,pitType]=getProcRegIdx(reg,procName,pitType);
    else
        [procIdx,pitIdx,pitType]=getProcRegIdx(reg,procName);
    end
    if isempty(procIdx)
        ret=false;
        return;
    end


    eval(['pitPath = fileparts(reg.pit_',pitType,'(',num2str(pitIdx)...
    ,').pitFileName);']);
    eval(['procDefFile = reg.pit_',pitType,'(',num2str(pitIdx)...
    ,').pit(',num2str(procIdx),').procDefFile;']);
    eval(['toolDefFile = reg.pit_',pitType,'(',num2str(pitIdx)...
    ,').pit(',num2str(procIdx),').toolDefFile;']);

    ret=exist(fullfile(pitPath,procDefFile),'file')&&...
    exist(fullfile(pitPath,toolDefFile),'file');

end
