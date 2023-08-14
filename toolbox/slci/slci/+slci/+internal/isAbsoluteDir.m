


function result=isAbsoluteDir(fDir)

    result=false;
    if isunix&&strncmp(fDir,'/',1)
        result=true;
    elseif ispc&&...
        (~isempty(regexp(fDir,'^([\w]:[\\/]|\\\\|//)','once')))
        result=true;
    end
end
