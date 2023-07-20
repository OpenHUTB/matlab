function fulpath=computeFullPath(relpath,projpath)



    if nargin<2
        projpath=pwd;
    end

    projpath=strip(projpath,'"');
    if(isempty(relpath))
        fulpath="";
        return;
    end

    relpath=strip(relpath,'"');
    if contains(relpath,' ')
        if isstring(relpath)
            relpath=relpath.char;
        end
        relpath=['"',relpath,'"'];
    end

    fulpath=loc_getFullPath(projpath,relpath);
end

function fullPath=loc_getFullPath(rootDirectory,relativePath)

    if isunix
        wrongFilesepChar='\';
        filesepChar='/';
    else
        wrongFilesepChar='/';
        filesepChar='\';
    end

    seps=find(relativePath==wrongFilesepChar);
    if(~isempty(seps))
        relativePath(seps)=filesepChar;
    end






    token=regexprep(relativePath,'^[\s"]*(.*?)[\s\\/"]*$','$1');

    if(~isempty(token))
        if ispc

            isAnAbsolutePath=length(token)>=2&&((token(2)==':')||(token(1)=='\'&&token(2)=='\'));
        else

            isAnAbsolutePath=token(1)=='/';
        end

        if(~isAnAbsolutePath)
            token=fullfile(rootDirectory,token);
        end
    end
    fullPath=token;
end