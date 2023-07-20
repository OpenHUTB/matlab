function[relPath,success]=relative_path(fullFilePath,refPath)







    if ispc
        fullFilePath=strrep(fullFilePath,'/','\');
        refPath=strrep(refPath,'/','\');
    end


    if refPath(end)==filesep
        refPath(end)=[];
    end

    [myPath,name,ext]=fileparts(fullFilePath);

    first=true;
    while true
        [refPart,refRest]=strtok(refPath,filesep);
        [pathPart,pathRest]=strtok(myPath,filesep);
        if strcmpi(refPart,pathPart)
            if first
                first=false;
            end
            if isempty(refRest)&&isempty(pathRest)
                relPath=[name,ext];
            elseif isempty(refRest)
                relPath=fullfile(['.',pathRest],[name,ext]);
            elseif isempty(pathRest)
                filesepCount=length(strfind(refRest,filesep));
                relPath=fullfile(upPrefix(filesepCount),[name,ext]);
            else
                refPath=refRest;
                myPath=pathRest;
                continue;
            end
        else
            if first
                relPath=fullFilePath;
                break;
            end
            if isempty(refRest)&&isempty(pathRest)
                relPath=fullfile('..',pathPart,[name,ext]);
            elseif isempty(refRest)
                relPath=fullfile('..',pathPart,pathRest,[name,ext]);
            elseif isempty(pathRest)
                filesepCount=length(strfind(refRest,filesep));
                relPath=fullfile(upPrefix(filesepCount),'..',pathPart,[name,ext]);
            else
                filesepCount=length(strfind(refRest,filesep));
                relPath=fullfile(upPrefix(filesepCount),'..',pathPart,pathRest,[name,ext]);
            end
        end
        break;
    end


    success=length(relPath)>2&&~(relPath(1)==filesep||relPath(2)==':');
end

function prefix=upPrefix(count)
    upOne={['..',filesep]};
    upAll=upOne(ones(1,count));
    prefix=[upAll{:}];
end

