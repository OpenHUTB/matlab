
function cleanupStruct=CRCSCleanupSession(sfunPath)
    cleanupStruct(1:6)=struct('isError',false,'errorMsg','');
    errIdx=1;
    try
        evalin('base',...
        'slproject.closeCurrentProject;clear(''all'');close(''all'');fclose(''all'');bdclose(''all'');');
    catch eCause
        cleanupStruct(errIdx).isError=true;
        if ismethod(eCause,'json')
            cleanupStruct(errIdx).errorMsg=eCause.json;
        else
            cleanupStruct(errIdx).errorMsg=jsonencode(eCause);
        end
    end
    errIdx=errIdx+1;
    try
        evalin('base',...
        'cd(matlabroot);');
    catch eCause
        cleanupStruct(errIdx).isError=true;
        if ismethod(eCause,'json')
            cleanupStruct(errIdx).errorMsg=eCause.json;
        else
            cleanupStruct(errIdx).errorMsg=jsonencode(eCause);
        end
    end
    errIdx=errIdx+1;
    try
        evalin('base',...
        'restoredefaultpath;');
    catch eCause
        cleanupStruct(errIdx).isError=true;
        if ismethod(eCause,'json')
            cleanupStruct(errIdx).errorMsg=eCause.json;
        else
            cleanupStruct(errIdx).errorMsg=jsonencode(eCause);
        end
    end
    errIdx=errIdx+1;
    try
        evalin('base',...
        'matlabrc;');
    catch eCause
        cleanupStruct(errIdx).isError=true;
        if ismethod(eCause,'json')
            cleanupStruct(errIdx).errorMsg=eCause.json;
        else
            cleanupStruct(errIdx).errorMsg=jsonencode(eCause);
        end
    end
    errIdx=errIdx+1;
    try
        evalin('base',...
        'if(which(''startup'')); startup; end;');
    catch eCause
        cleanupStruct(errIdx).isError=true;
        if ismethod(eCause,'json')
            cleanupStruct(errIdx).errorMsg=eCause.json;
        else
            cleanupStruct(errIdx).errorMsg=jsonencode(eCause);
        end
    end
    errIdx=errIdx+1;
    try
        addpath(sfunPath);
    catch eCause
        cleanupStruct(errIdx).isError=true;
        if ismethod(eCause,'json')
            cleanupStruct(errIdx).errorMsg=eCause.json;
        else
            cleanupStruct(errIdx).errorMsg=jsonencode(eCause);
        end
    end
end
