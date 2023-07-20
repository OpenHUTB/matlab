function unregisterProc(reg,procName)





    [procIdx,pitIdx,pitType]=getProcRegIdx(reg,procName);
    if isempty(procIdx)
        return;
    end


    removeProc(reg,pitType,pitIdx,procIdx);


    eval(['pitFile = reg.pit_',pitType,'(',num2str(pitIdx),').pitFileName;']);
    savePIT(reg,pitFile);

end