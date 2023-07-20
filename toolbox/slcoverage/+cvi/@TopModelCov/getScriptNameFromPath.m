




function scriptName=getScriptNameFromPath(scriptPath)
    [scriptFileDir,scriptFileName,~]=fileparts(scriptPath);
    hasPackageName=false;
    scopeWithPlus=[filesep,'+'];
    scopeWithAt=[filesep,'@'];
    if contains(scriptFileDir,scopeWithPlus)

        sidx=strfind(scriptFileDir,scopeWithPlus);
        sidx=sidx(1);
        scriptFileDir=scriptFileDir(sidx+2:end);

        scriptFileDir=strrep(scriptFileDir,scopeWithPlus,'.');
        hasPackageName=true;
    end
    hasClassName=false;
    if contains(scriptFileDir,scopeWithAt)

        if~hasPackageName
            sidx=strfind(scriptFileDir,scopeWithAt);
            sidx=sidx(end);
            scriptFileDir=scriptFileDir(sidx+2:end);
        end

        scriptFileDir=strrep(scriptFileDir,scopeWithAt,'.');
        hasClassName=true;
    end
    if(hasPackageName||hasClassName)
        if strcmp(scriptFileDir,scriptFileName)

            scriptName=scriptFileName;
        else
            sidx=length(scriptFileDir)-length(scriptFileName);
            if(sidx>0)&&strcmp(scriptFileDir(sidx:end),['.',scriptFileName])

                scriptName=scriptFileDir;
            else

                scriptName=[scriptFileDir,'.',scriptFileName];
            end
        end
    else

        scriptName=scriptFileName;
    end

end

