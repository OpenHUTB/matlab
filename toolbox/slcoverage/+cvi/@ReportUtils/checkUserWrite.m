function[succ,res]=checkUserWrite(filePath)




    res=true;
    [succ,attr]=fileattrib(filePath);
    if~succ
        return;
    end
    if~attr.UserWrite
        res=false;
        if ispc
            res=chekPC(filePath);
        end
    end


    function res=chekPC(filePath)
        persistent userFolders;

        [filePath,~,ext]=fileparts(filePath);

        if~isempty(ext)
            res=false;
            return;
        end
        if isempty(userFolders)
            env=getenv("USERPROFILE");
            dirlist=dir(env);
            for i=1:numel(dirlist)
                userFolders=[userFolders,';',dirlist(i).folder,'\',dirlist(i).name];%#ok<AGROW>
            end
        end
        res=contains(userFolders,filePath);

