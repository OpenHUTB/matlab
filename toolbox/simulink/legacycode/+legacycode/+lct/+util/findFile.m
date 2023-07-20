



function[fullName,found]=findFile(fullName,searchPath)

    if nargin>0
        fullName=convertStringsToChars(fullName);
    end
    if nargin>1
        if isstring(searchPath)
            searchPath=cellstr(searchPath);
        end
    end

    if nargin<2
        searchPath=[];
    end


    found=false;


    [fPath,fName,fExt]=fileparts(fullName);

    if legacycode.lct.util.isAbsolutePath(fPath)

        if isempty(fExt)
            fExt=legacycode.lct.util.findFileExt(fullfile(fPath,fName));
            fullName=fullfile(fPath,[fullName,fExt]);
        end

        if legacycode.lct.util.isfile(fullName)
            found=true;
        end
    else

        if isempty(searchPath)
            fullName=fullfile(pwd,fullName);
            if legacycode.lct.util.isfile(fullName)
                found=true;
            end
            return
        end


        for ii=1:length(searchPath)
            thisFullName=fullfile(searchPath{ii},fullName);

            if isempty(fExt)
                fExt=legacycode.lct.util.findFileExt(thisFullName);
                thisFullName=[thisFullName,fExt];%#ok
            end

            if legacycode.lct.util.isfile(thisFullName)
                fullName=thisFullName;
                found=true;
                break
            end
        end
    end
