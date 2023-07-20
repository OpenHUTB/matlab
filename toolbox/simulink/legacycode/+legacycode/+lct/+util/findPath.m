



function[fullPath,found]=findPath(fullPath,searchPath)

    narginchk(1,2);

    fullPath=convertStringsToChars(fullPath);

    if nargin<2
        searchPath=[];
    else
        if isstring(searchPath)
            searchPath=cellstr(searchPath);
        end
    end


    found=false;

    if legacycode.lct.util.isAbsolutePath(fullPath)==1

        if isfolder(fullPath)
            found=true;
        end
    else

        if isempty(searchPath)
            fullPath=fullfile(pwd,fullPath);
            if legacycode.lct.util.isfile(fullPath)
                found=true;
            end
            return
        end


        for ii=1:length(searchPath)
            thisFullPath=fullfile(searchPath{ii},fullPath);

            if isfolder(thisFullPath)
                found=true;
                fullPath=thisFullPath;
                break
            end
        end
    end
