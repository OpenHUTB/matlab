function mCommand=pathToCmd(fPath)
    [fDir,mCommand,ext]=fileparts(fPath);

    if~strcmp(ext,'.m')

        mCommand=[mCommand,ext];
        return;
    end

    if isempty(fDir)
        return;
    end

    if ispc
        fDir(fDir=='/')=filesep;
    end

    if fDir(end)==filesep
        return;
    end

    allFileSeps=find(fDir==filesep);
    if isempty(allFileSeps)
        return;
    end

    for i=length(allFileSeps):-1:1
        position=allFileSeps(i);
        if fDir(position+1)=='@'||fDir(position+1)=='+'
            if~strcmp(fDir(position+2:end),mCommand)
                mCommand=[fDir(position+2:end),'.',mCommand];%#ok<AGROW>
            end
            fDir=fDir(1:position-1);
        else
            break;
        end
    end

end

