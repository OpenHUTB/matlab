function[fileToDisp,files,traceStyle,error]=getGeneratedHDLFiles(reportPath,modelName,isRef)




    error=[];
    [fileFolder,~]=fileparts(reportPath);
    fileToDisp=[];
    traceStyle=[];

    if~isfolder(fileFolder)
        files=[];
        error.generatedBlks=[];
        error.message=message('RTW:report:invalidBuildFolder',pwd).getString;
        return;
    end

    if isRef
        genFilesFolder=fullfile(fileFolder,modelName);
        codeViewInfoFile=fullfile(genFilesFolder,'hcv');
    else
        genFilesFolder=fileFolder;
        codeViewInfoFile=fullfile(genFilesFolder,'hcv');
    end


    s=simulinkcoder.internal.util.getSource(modelName);
    studio=s.studio;
    currentView=getCurrentView(studio);

    if~isfile(codeViewInfoFile)
        files=[];
        error.generatedBlks=[];
        error.message=message('hdlcoder:report:HCVFileNotFound').getString;
        return;
    end

    load(codeViewInfoFile,'codeViewInfo','-mat');


    traceStyle=codeViewInfo.traceStyleFromBuild;


    fileToDisp=getFileMapping(currentView,codeViewInfo);

    codeFor=checkCodeFor(codeViewInfo.codeForPath,currentView);
    if isempty(codeFor)
        files=[];
        error.generatedBlks={codeViewInfo.codeForPath};
        error.message=message('hdlcoder:report:noCodeGenForCurrentView').getString;
        return;
    end

    codeInfo=codeViewInfo.codeInfo;
    scriptInfo=codeViewInfo.scripts;

    files=cell(1,(length(codeInfo)+length(scriptInfo)));

    i=1;
    while i<length(codeInfo)+1
        entity=codeInfo{i};
        fileListItem.name=entity.enFileName;
        fileListItem.type='source';
        fileListItem.group=codeFor;
        fileListItem.path=entity.enCodePath;
        fileListItem.tag='';
        fileListItem.groupDisplay=codeFor;


        fid=fopen(fullfile(genFilesFolder,entity.enFileName),'r','n','UTF-8');
        if fid~=-1
            code=fscanf(fid,'%c');
            fclose(fid);
            fileListItem.code=code;
        end

        files{i}=fileListItem;
        i=i+1;

    end


    for j=1:length(scriptInfo)
        script=scriptInfo{j};
        if~isfile(fullfile(genFilesFolder,script.name))
            continue;
        end
        scriptListItem.name=script.name;
        scriptListItem.type='scripts';
        scriptListItem.group='scripts';
        scriptListItem.path=script.loc;
        scriptListItem.tag='';
        scriptListItem.groupDisplay='scripts';


        fid=fopen(fullfile(genFilesFolder,script.name),'r','n','UTF-8');
        if fid~=-1
            code=fscanf(fid,'%c');
            fclose(fid);
            scriptListItem.code=code;
        end

        files{i}=scriptListItem;
        i=i+1;
    end
end


function out=getCurrentView(studio)

    editor=studio.App.getActiveEditor;
    hId=editor.getHierarchyId;
    path=GLUE2.HierarchyService.getPaths(hId);
    out=path{end};
end


function result=checkCodeFor(lastBuiltSys,codeFor)


    if~any(strcmp(lastBuiltSys,codeFor))
        slashIndexes=strfind(codeFor,'/');
        if isempty(slashIndexes)
            result=[];
            return;
        end
        codeFor=extractBefore(codeFor,slashIndexes(end));
        result=checkCodeFor(lastBuiltSys,codeFor);
        return;
    else
        result=codeFor;
    end
end

function toDisplay=getFileMapping(codeFor,codeViewInfo)
    toDisplay=[];
    codeInfo=codeViewInfo.codeInfo;
    for i=1:length(codeInfo)
        code=codeInfo{i};
        if strcmp(codeFor,code.subsysPath)
            toDisplay=code.enFileName;
            return;
        end
    end

end


