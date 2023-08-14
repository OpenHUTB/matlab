function PIT=getPITFileName(reg,procName)




    PIT=[];
    [procIdx,pitIdx,pitType]=getProcRegIdx(reg,procName);
    eval(['pitArray = reg.pit_',pitType,';']);
    PIT=pitArray(pitIdx).pitFileName;

end