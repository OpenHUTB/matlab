function info=nesl_getfunctioninfo(stringSpec)













    info=struct('FunctionName','',...
    'FileName','',...
    'IsFile',false,...
    'IsSimscapeType',false,...
    'IsOnPath',false,...
    'IsShadowed',false,...
    'ShadowFile','');


    stringSpec=strtrim(stringSpec);
    stringSpec=strrep(stringSpec,'\',filesep);
    stringSpec=strrep(stringSpec,'/',filesep);
    fileResult=which(stringSpec);

    if~isempty(fileResult)


        [~,~,ext]=fileparts(fileResult);
        info.FunctionName=functionNameFromFileName(fileResult);
        info.FileName=fileResult;
        info.IsFile=true;
        info.IsSimscapeType=lIsSimscapeExt(ext);
        info.IsOnPath=true;
        whichFile=which(info.FunctionName);
        if strcmp(whichFile,info.FileName)||...
            strcmp(whichFile,strcat(info.FileName,'p'))
            info.IsShadowed=false;
            info.ShadowFile='';
        else
            info.IsShadowed=true;
            info.ShadowFile=whichFile;
        end

    else

        if lAssumeFileSpec(stringSpec)

            info.IsOnPath=false;
            [info.IsFile,...
            info.IsSimscapeType,...
            info.FileName]=lFileExists(stringSpec);
            info.FunctionName=functionNameFromFileName(info.FileName);
            whichFile=which(info.FunctionName);
            info.ShadowFile=whichFile;
            info.IsShadowed=~isempty(info.ShadowFile);
        else

            info.FunctionName=stringSpec;
            info.FileName=stringSpec;
            info.IsFile=false;
            info.IsSimscapeType=false;
            info.IsOnPath=false;
            info.IsShadowed=false;
            info.ShadowFile='';
        end
    end

end

function result=lAssumeFileSpec(stringSpec)
    [~,~,ext]=fileparts(stringSpec);
    result=any(strfind(stringSpec,filesep))||lIsSimscapeExt(ext);
end

function[functionName,isSimscapeExt]=functionNameFromFileName(filePath)




    [selectedPath,fileName,ext]=fileparts(filePath);
    isSimscapeExt=lIsSimscapeExt(ext);

    pkg=regexp(selectedPath,'\+.*','match','once');
    if~isempty(pkg)
        pkg=strrep(pkg(2:end),'+','.');
        pkg=strrep(pkg,filesep,'');
        pkg=[pkg,'.'];
    end
    functionName=[pkg,fileName];
end


function result=lIsSimscapeExt(theExt)
    result=any(strcmp(theExt,{'.ssc','.sscp','.m','.p'}));
end

function[result,isSimscape,name]=lFileExists(fileSpec)

    result=false;
    isSimscape=false;
    name=fileSpec;

    [~,~,ext]=fileparts(fileSpec);
    if isempty(ext)
        okExtensions={'.ssc','.sscp','.m','.p'};
        for idx=1:numel(okExtensions)
            ext=okExtensions{idx};
            stringSpec=[fileSpec,ext];
            dirVal=dir(stringSpec);
            if~isempty(dirVal)
                result=true;
                name=fullfile(dirVal.folder,dirVal.name);
                isSimscape=true;
                break
            else
                result=false;
            end
        end
    else
        isSimscape=lIsSimscapeExt(ext);
        dirVal=dir(fileSpec);
        if~isempty(dirVal)
            result=true;
            name=fullfile(dirVal.folder,dirVal.name);
        else
            whichVal=which(fileSpec);
            if~isempty(whichVal)
                result=true;
                name=whichVal;
            end
        end
    end
end
