function out=projecthandler(action,varargin)











    out={action};

    switch(action)
    case 'saveproject'
        out=saveproject(action,varargin{1});
    case 'loadproject'
        out=loadproject(action,varargin{1});
    case 'clearTempDirectory'
        out=clearTempDirectory(action);
    case 'getModelFromProject'
        out=getModelsFromProject(varargin{:});
    end

end

function models=getModelsFromProject(projectName,modelsToLoad,initDiagramSyntax)

    models=[];


    projectObj=SimBiology.internal.sbioproject(projectName,true);
    modelLookupMatFileName=projectObj.loadFilesMatchingRegexp('modelLookup.mat');
    projectObj.getProjectVersion;

    if isempty(modelLookupMatFileName)

        converter=SimBiology.web.internal.projectconverter;
        converter.initDiagramSyntax=initDiagramSyntax;
        converter.isLoadModelsOnly=true;
        converter.modelsToLoad=modelsToLoad;

        converter.convertProjects(projectName);
        modelStruct=converter.project.Models;
        models=cell(1,length(modelsToLoad));

        for i=1:length(modelStruct)
            sessionID=modelStruct(i).obj;
            if~isempty(sessionID)
                models{i}=SimBiology.web.modelhandler('getModelFromSessionID',modelStruct(i).obj);
            end
        end
        models=[models{:}];
    else
        [modelStruct,diagramViews,imageFiles]=loadModelsFrom19bOrLater(projectObj,modelLookupMatFileName);
        modelVarNames=fieldnames(modelStruct);
        models={};

        for i=1:length(modelVarNames)
            nextModelObj=modelStruct.(modelVarNames{i});
            if any(strcmp(nextModelObj.Name,modelsToLoad))
                if initDiagramSyntax||~isempty(diagramViews{i})
                    diagramInputs=struct('model',nextModelObj,'viewFile',diagramViews{i},'imageFile',imageFiles{i},'projectVersion',projectObj.version);
                    SimBiology.web.diagramhandler('initDiagramSyntax',diagramInputs);
                end
                models{end+1}=nextModelObj;
            else
                delete(nextModelObj);
            end
        end

        models=[models{:}];
    end



    if initDiagramSyntax
        for i=1:length(models)
            if~models(i).hasDiagramSyntax
                args=struct('model',models(i),'viewFile','','projectVersion','');
                SimBiology.web.diagramhandler('initDiagramSyntax',args);
            end
        end
    end

end

function out=saveproject(action,varargin)


    inputs=varargin{1};
    name=inputs.ProjectName;
    description=inputs.ProjectDescription;
    models=inputs.Models;
    modelPlots=inputs.ModelPlots;
    programs=inputs.Programs;
    externalData=inputs.ExternalData;
    programData=inputs.ProgramData;
    plotDocuments=inputs.PlotDocuments;
    dataSheets=inputs.DataSheets;
    packageAppInfo=inputs.PackageAppInfo;

    [backupCreated,message]=backupProject(name);
    if(~backupCreated)
        out.message=message;
        return;
    end


    filesToBeZipped={};


    tempDesktopDir=SimBiology.web.internal.desktopTempdir();


    tempProjectFileName=[SimBiology.web.internal.desktopTempname(),'.sbproj'];


    varNames=cell(1,length(models));
    modelLookup=[];
    modelObjs=cell(1,length(models));

    for i=1:length(models)
        next=SimBiology.web.modelhandler('getModelFromSessionID',models(i).sessionID);%#ok<*NASGU>
        nextName=['m',num2str(i)];
        varNames{i}=nextName;
        modelObjs{i}=next;
        eval([nextName,' = next;']);

        modelLookup(i).variableName=nextName;
        modelLookup(i).id=models(i).sessionID;
        modelLookup(i).name=next.Name;
        modelLookup(i).diagramView=models(i).diagramView;
        modelLookup(i).reportInfo=models(i).reportInfo;


        if next.hasDiagramSyntax
            diagramJSON=next.getDiagramSyntax.saveToJSON();
            filename=sprintf('diagram_%d.json',i);
            tempDiagramFileName=fullfile(tempDesktopDir,filename);


            fid=fopen(tempDiagramFileName,'w');
            fprintf(fid,'%s',diagramJSON);
            fclose(fid);

            filesToBeZipped{end+1}=tempDiagramFileName;
            modelLookup(i).diagramView=filename;
        end
    end


    tempMatFile=fullfile(tempDesktopDir,'modelLookup.mat');
    save(tempMatFile,'modelLookup');
    filesToBeZipped{end+1}=tempMatFile;


    warnState=warning('off','SimBiology:sbiosaveproject:InvalidVariable');
    cleanup=onCleanup(@()warning(warnState));



    modelObjs=[modelObjs{:}];
    set(modelObjs,'sendEvent',false,'SendSaveNeededEvent',false);
    restoreEvents=onCleanup(@()set(modelObjs,'sendEvent',true,'SendSaveNeededEvent',true));


    if~isempty(varNames)
        sbiosaveproject(tempProjectFileName,varNames{:});
    else
        sbiosaveproject(tempProjectFileName,'');
    end


    if~isempty(modelPlots)
        tempMatFile=fullfile(tempDesktopDir,'modelPlots.mat');
        save(tempMatFile,'modelPlots');
        filesToBeZipped{end+1}=tempMatFile;
    end

    filesToBeZipped=saveModelCache(filesToBeZipped);
    filesToBeZipped=saveDataCache(filesToBeZipped);


    taskLookup=[];
    for i=1:length(programs)
        task=getProgram(programs,i);
        taskName=task.programName;
        taskLookup(i).id=['task',num2str(i)];
        taskLookup(i).name=taskName;
    end


    tempMatFile=fullfile(tempDesktopDir,'taskLookup.mat');
    save(tempMatFile,'taskLookup');
    filesToBeZipped{end+1}=tempMatFile;


    for i=1:length(programs)
        tempMatFile=fullfile(tempDesktopDir,['task',num2str(i),'.mat']);
        task=getProgram(programs,i);
        save(tempMatFile,'task');
        filesToBeZipped{end+1}=tempMatFile;%#ok<*AGROW>
    end


    if isstruct(externalData)&&~isempty(externalData.data)
        filesToBeZipped{end+1}=externalData.matfile;
        [~,matfileName,ext]=fileparts(externalData.matfile);
        matfileName=[matfileName,ext];
        externalDataLookup=externalData.data;


        tempMatFile=fullfile(tempDesktopDir,'externalDataLookup.mat');
        save(tempMatFile,'externalDataLookup','matfileName');
        filesToBeZipped{end+1}=tempMatFile;
    end


    if isstruct(programData)&&~isempty(programData.data)
        programData.data=updateProgramDataForCaching(programData.data);
        for i=1:length(programData.data)
            if exist(programData.data(i).matfileName,'file')
                filesToBeZipped{end+1}=programData.data(i).matfileName;
                [~,matfileName,ext]=fileparts(programData.data(i).matfileName);
                programData.data(i).matfileName=[matfileName,ext];
            else
                programData.data(i).matfileName='';
            end
        end

        taskDataLookup=programData.data;


        tempMatFile=fullfile(tempDesktopDir,'taskDataLookup.mat');
        save(tempMatFile,'taskDataLookup');
        filesToBeZipped{end+1}=tempMatFile;
    end


    if isstruct(plotDocuments)&&~isempty(plotDocuments)
        tempMatFile=fullfile(tempDesktopDir,'plotDocuments.mat');
        save(tempMatFile,'plotDocuments');
        filesToBeZipped{end+1}=tempMatFile;
    end


    if isstruct(dataSheets)&&~isempty(dataSheets)
        tempMatFile=fullfile(tempDesktopDir,'dataSheets.mat');
        save(tempMatFile,'dataSheets');
        filesToBeZipped{end+1}=tempMatFile;
    end


    description.matlabVersion=sprintf('R%s',version('-release'));


    tempMatFile=fullfile(tempDesktopDir,'description.mat');
    save(tempMatFile,'description');
    filesToBeZipped{end+1}=tempMatFile;


    if~isempty(packageAppInfo)
        tempMatFile=fullfile(tempDesktopDir,'packageAppInfo.mat');
        save(tempMatFile,'packageAppInfo');
        filesToBeZipped{end+1}=tempMatFile;
    end


    projectVersionFile=fullfile(matlabroot,'toolbox','simbio','simbio','+SimBiology','+web','+templates','projectVersion.json');
    filesToBeZipped{end+1}=projectVersionFile;


    filesToBeZipped=unique(filesToBeZipped,'stable');
    SimBiology.web.internal.adddesktopfilestoproject(tempProjectFileName,filesToBeZipped);


    try
        movefile(tempProjectFileName,name,'f');
        out.message='';
    catch ex
        out.message=ex.message;
    end

    if isfield(inputs,'saveAction')
        out.saveAction=inputs.saveAction;
    else
        out.saveAction='';
    end


    [~,x]=fileparts(name);
    out.ProjectName=name;
    out.ProjectNameNoPath=x;
    out.timeStamp=getProjectLastSavedTimeStamp(name);
    out.isJSVersion=true;
    out={action,out};

end

function out=updateProgramDataForCaching(data)

    out=cell(1,numel(data));
    for i=1:numel(data)
        if iscell(data)
            next=data{i};
        else
            next=data(i);
        end

        if~isfield(next,'dataCache')
            next.dataCache='';
        end
        if~isfield(next,'modelCacheName')
            next.modelCacheName='';
        end
        if~isfield(next,'reportInfo')
            next.reportInfo=[];
        end
        out{i}=next;
    end

    out=[out{:}];

end

function out=loadproject(action,varargin)

    out={};


    inputs=varargin{1};
    name=strtrim(inputs.ProjectName);



    if~endsWith(name,'.sbproj')
        name=sprintf('%s.sbproj',name);
    end


    if~exist(name,'file')
        out.error=true;
        out.filename=name;
        out.errors={sprintf('The file %s does not exist',name)};
        out.warnings={};
        out.infos={};

        return;
    end

    if isfield(inputs,'sessionIDs')&&~isempty(inputs.sessionIDs)
        SimBiology.web.modelhandler('cleanupOnProjectClose',inputs);
    end


    sbioprojectObj=SimBiology.internal.sbioproject(name,true);


    newName=sbioprojectObj.loadFilesMatchingRegexp('modelLookup.mat');

    if isempty(newName)

        converter=SimBiology.web.internal.projectconverter();
        converter.initDiagramSyntax=doesDiagramSyntaxNeedToBeInitialized(inputs);
        converter.convertProjects(name);



        out.action=action;
        out.type=action;
        out.error=false;
        out.errors=converter.errors;
        out.warnings=converter.warnings;
        out.infos=converter.infos;
        out.project=converter.project;
        out.filename=converter.filename;
        out.isConverted=true;
        out.project.timeStamp=getProjectLastSavedTimeStamp(name);
        out.project.isJSVersion=false;





        updater=SimBiology.web.internal.projectupdater;
        updater.updateProject(sbioprojectObj,out.project);


        out.errors=vertcat(out.errors,updater.errors);
        out.warnings=vertcat(out.warnings,updater.warnings);


        out.project=updater.projectStruct;

        m=out.project.Models;
        for i=1:length(m)
            mobj=SimBiology.web.modelhandler('getModelFromSessionID',m(i).obj);
            turnOnEvents(mobj);
        end
    else

        updater=SimBiology.web.internal.projectupdater;
        updater.backupIfNeeded(sbioprojectObj,name);


        [models,diagramViews,imageFiles,reportInfo,mapOldIDToVarName]=loadModelsFrom19bOrLater(sbioprojectObj,newName);


        newName=sbioprojectObj.loadFilesMatchingRegexp('description.mat');
        if~isempty(newName)
            d=load(newName{1});
            description=d.description;
        else
            description='';
        end




        packageAppInfo='';
        components=[];
        componentsToPackage=sbioprojectObj.loadFilesMatchingRegexp('packageAppInfo.mat');
        if~isempty(componentsToPackage)
            packageAppInfo=load(componentsToPackage{1});
            packageAppInfo=packageAppInfo.packageAppInfo;


            components=packageAppInfo.components;



            packageAppInfo=rmfield(packageAppInfo,'components');
            delete(componentsToPackage{1});
        end



        modelInfo=[];
        modelVarNames=fieldnames(models);
        mapVarNameToNewID=containers.Map('KeyType','char','ValueType','double');
        initDiagramSyntax=doesDiagramSyntaxNeedToBeInitialized(inputs);
        for i=1:length(modelVarNames)
            nextModelObj=models.(modelVarNames{i});


            modelInfo(i).name=nextModelObj.Name;
            modelInfo(i).obj=nextModelObj.SessionID;
            modelInfo(i).diagramView=diagramViews{i};
            modelInfo(i).reportInfo=reportInfo{i};


            if~isempty(diagramViews{i})||initDiagramSyntax
                args=struct('model',nextModelObj,'viewFile',diagramViews{i},'imageFile',imageFiles{i},'projectVersion',description.version);
                SimBiology.web.diagramhandler('initDiagramSyntax',args);
            end



            usedComponents=[];
            if~isempty(components)
                for j=1:numel(components)
                    if strcmpi(components(j).modelName,nextModelObj.Name)
                        usedComponents=components(j).components;




                        if isempty(usedComponents)
                            usedComponents={''};
                        end
                        break;
                    end
                end
            end

            input.sessionID=nextModelObj.SessionID;
            input.usedComponents=usedComponents;
            tempOut=SimBiology.web.modelhandler('getModelInfo',input);
            modelInfo(i).info=tempOut{2};


            turnOnEvents(nextModelObj);

            mapVarNameToNewID(modelVarNames{i})=nextModelObj.SessionID;
        end


        newName=sbioprojectObj.loadFilesMatchingRegexp('modelPlots.mat');
        modelPlots=[];
        if~isempty(newName)
            d=load(newName{1});
            modelPlots=d.modelPlots;
            deleteFile(newName{1});

            for i=1:numel(modelPlots)
                if mapOldIDToVarName.isKey(modelPlots(i).modelSessionID)
                    varName=mapOldIDToVarName(modelPlots(i).modelSessionID);
                    newSessionID=mapVarNameToNewID(varName);
                else
                    newSessionID=-1;
                end

                modelPlots(i).modelSessionID=newSessionID;
            end
        end


        newName=sbioprojectObj.loadFilesMatchingRegexp('taskLookup.mat');
        d=load(newName{1});
        taskLookup=d.taskLookup;
        deleteFile(newName{1});


        programs=cell(1,length(taskLookup));
        programMATFileNames=cell(1,length(taskLookup));
        for i=1:length(taskLookup)
            matFile=taskLookup(i).id;
            newName=sbioprojectObj.loadFilesMatchingRegexp(matFile);
            d=load(newName{1});
            d=d.task;

            if~iscell(d.steps)
                d.steps={d.steps};
            end


            for j=1:length(d.steps)
                if isfield(d.steps{j},'model')
                    oldSessionID=d.steps{j}.model;
                    newSessionID=-1;
                    if oldSessionID>-1

                        if~mapOldIDToVarName.isKey(oldSessionID)



                            modelSessionIds=mapOldIDToVarName.keys;
                            if~isempty(modelSessionIds)
                                oldSessionID=modelSessionIds{1};
                            end
                        end

                        if mapOldIDToVarName.isKey(oldSessionID)
                            varName=mapOldIDToVarName(oldSessionID);
                            newSessionID=mapVarNameToNewID(varName);
                        end
                    end
                    d.steps{j}.model=newSessionID;
                end
            end

            programs{i}=d;



            programMATFileNames{i}=sprintf('%s.mat',SimBiology.web.internal.desktopTempname());

            deleteFile(newName{1});
        end


        newName=sbioprojectObj.loadFilesMatchingRegexp('externalDataLookup.mat');
        if~isempty(newName)
            d=load(newName{1});
            externalDataLookup=d.externalDataLookup;
            matfileName=d.matfileName;
            deleteFile(newName{1});

            [~,matfileName,ext]=fileparts(matfileName);
            matfileName=[matfileName,ext];




            externalDataMatFile=[SimBiology.web.internal.desktopTempdir,filesep,'externaldata.mat'];
            sbioprojectObj.loadFilesIntoTargetLocations(matfileName,externalDataMatFile);

            dataInfo.matfile=externalDataMatFile;
            dataInfo.data=externalDataLookup;
        else
            dataInfo.matfile='';
            dataInfo.data=[];
        end


        newName=sbioprojectObj.loadFilesMatchingRegexp('taskDataLookup.mat');
        if~isempty(newName)
            d=load(newName{1});
            taskDataLookup=d.taskDataLookup;
            taskDataLookup=updateProgramDataForCaching(taskDataLookup);
            mapObj=containers.Map('KeyType','char','ValueType','char');

            oldWarnState=warning('off','MATLAB:load:variableNotFound');
            loadCleanup=onCleanup(@()warning(oldWarnState));

            for i=1:length(taskDataLookup)
                matfileName=taskDataLookup(i).matfileName;

                if mapObj.isKey(matfileName)

                    taskDataLookup(i).matfile=mapObj(matfileName);
                elseif~isempty(matfileName)



                    taskDataName=sbioprojectObj.loadFilesMatchingRegexp(matfileName);
                    taskDataLookup(i).matfileName=taskDataName{1};
                    mapObj(matfileName)=taskDataName{1};
                else
                    newMATFileName=SimBiology.web.desktophandler('tempfile');
                    newMATFileName=[newMATFileName{2},'.mat'];
                    taskDataLookup(i).matfileName=newMATFileName;
                end
            end

            programDataInfo.data=taskDataLookup;
            deleteFile(newName{1});
        else
            programDataInfo.data=[];
        end


        newName=sbioprojectObj.loadFilesMatchingRegexp('plotDocuments.mat');
        if~isempty(newName)
            d=load(newName{1});
            plotDocuments=d.plotDocuments;
        else
            plotDocuments=[];
        end


        newName=sbioprojectObj.loadFilesMatchingRegexp('dataSheets.mat');
        if~isempty(newName)
            d=load(newName{1});
            dataSheets=d.dataSheets;
        else
            dataSheets=[];
        end


        loadModelCache(sbioprojectObj);


        loadDataCache(sbioprojectObj);


        [~,x]=fileparts(name);
        project.ProjectName=name;
        project.ProjectNameNoPath=x;
        project.ProjectDescription=description;
        project.Models=modelInfo;
        project.ModelPlots=modelPlots;
        project.Programs=programs;
        project.ProgramMATFileNames=programMATFileNames;
        project.ExternalData=dataInfo;
        project.ProgramData=programDataInfo;
        project.PlotDocuments=plotDocuments;
        project.DataSheets=dataSheets;
        project.PackageAppInfo=packageAppInfo;
        project.timeStamp=getProjectLastSavedTimeStamp(name);
        project.isJSVersion=true;


        updater.updateProject(sbioprojectObj,project);

        project=updater.projectStruct;



        out.action=action;
        out.type=action;
        out.project=project;
        out.error=false;
        out.errors=updater.errors;
        out.warnings=updater.warnings;
        out.infos=updater.infos;
        out.isConverted=updater.converted;
    end

    out=addWarningsForDuplicateNames(out);


    delete(sbioprojectObj);

    postToOtherAppForProjectLoad(inputs,out);

end

function out=getProjectLastSavedTimeStamp(fileName)

    finfo=dir(fileName);
    if isempty(finfo)

        out='';
    else
        out=finfo.date;
    end

end

function filesToBeZipped=saveModelCache(filesToBeZipped)

    modelCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'modelCacheLookup.mat'];
    if exist(modelCacheLookupFile,'file')
        filesToBeZipped{end+1}=modelCacheLookupFile;


        modelCacheLookup=load(modelCacheLookupFile);
        modelCacheLookup=modelCacheLookup.modelCacheLookup;

        for i=1:numel(modelCacheLookup)
            modelCacheFile=[SimBiology.web.internal.desktopTempdir,filesep,modelCacheLookup(i).name,'*.mat'];
            filesToBeZipped{end+1}=modelCacheFile;
        end
    end

end

function loadModelCache(sbioprojectObj)


    modelCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'modelCacheLookup.mat'];
    sbioprojectObj.loadFilesIntoTargetLocations('modelCacheLookup.mat',modelCacheLookupFile);

    if exist(modelCacheLookupFile,'file')

        modelCacheLookup=load(modelCacheLookupFile);
        modelCacheLookup=modelCacheLookup.modelCacheLookup;

        for i=1:numel(modelCacheLookup)
            modelCacheLookup(i).sessionID=-1;
            modelCacheLookup(i).transactionID=-1;
            modelCacheFile=[SimBiology.web.internal.desktopTempdir,filesep,modelCacheLookup(i).name,'.mat'];
            sbioprojectObj.loadFilesIntoTargetLocations([modelCacheLookup(i).name,'.mat'],modelCacheFile);
        end

        saveDataToMATFile(modelCacheLookup,'modelCacheLookup',modelCacheLookupFile);
    end

end

function filesToBeZipped=saveDataCache(filesToBeZipped)

    dataCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'dataCacheLookup.mat'];
    if exist(dataCacheLookupFile,'file')
        filesToBeZipped{end+1}=dataCacheLookupFile;


        dataCacheLookup=load(dataCacheLookupFile);
        dataCacheLookup=dataCacheLookup.dataCacheLookup;

        for i=1:numel(dataCacheLookup)
            dataCacheFile=[SimBiology.web.internal.desktopTempdir,filesep,dataCacheLookup(i).name,'*.mat'];
            filesToBeZipped{end+1}=dataCacheFile;
        end
    end

end

function loadDataCache(sbioprojectObj)


    dataCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'dataCacheLookup.mat'];
    sbioprojectObj.loadFilesIntoTargetLocations('dataCacheLookup.mat',dataCacheLookupFile);

    if exist(dataCacheLookupFile,'file')

        dataCacheLookup=load(dataCacheLookupFile);
        dataCacheLookup=dataCacheLookup.dataCacheLookup;

        for i=1:numel(dataCacheLookup)
            dataCacheFile=[SimBiology.web.internal.desktopTempdir,filesep,dataCacheLookup(i).name,'.mat'];
            sbioprojectObj.loadFilesIntoTargetLocations([dataCacheLookup(i).name,'.mat'],dataCacheFile);
        end

        saveDataToMATFile(dataCacheLookup,'dataCacheLookup',dataCacheLookupFile);
    end

end

function[models,diagramViews,imageFiles,reportInfo,mapOldIDToVarName]=loadModelsFrom19bOrLater(sbioprojectObj,modelLookupMatFileName)


    d=load(modelLookupMatFileName{1});
    modelLookup=d.modelLookup;
    deleteFile(modelLookupMatFileName{1});



    mapOldIDToVarName=containers.Map('KeyType','double','ValueType','char');
    for i=1:length(modelLookup)
        oldSessionID=modelLookup(i).id;
        varName=modelLookup(i).variableName;
        mapOldIDToVarName(oldSessionID)=varName;
    end


    diagramViews=cell(1,length(modelLookup));
    imageFiles=cell(1,length(modelLookup));
    reportInfo=cell(1,length(modelLookup));

    for i=1:length(modelLookup)
        diagramView=modelLookup(i).diagramView;

        if isfield(modelLookup(i),'reportInfo')
            reportInfo{i}=modelLookup(i).reportInfo;
        end


        diagramView=strrep(diagramView,'\','/');
        [~,dname,dext]=fileparts(diagramView);

        if~isempty(diagramView)
            value=sbioprojectObj.loadFilesMatchingRegexp([dname,dext]);
            if iscell(value)&&isempty(value)
                diagramViews{i}='';
            else
                diagramViews{i}=value;
            end
        else
            diagramViews{i}='';
        end



        imageFile='';
        if isfield(modelLookup(i),'imageFileName')
            imageFile=modelLookup(i).imageFileName;
        end

        if~isempty(imageFile)
            imageFile=strrep(imageFile,'\','/');
            [~,iname,iext]=fileparts(imageFile);
            value=sbioprojectObj.loadFilesMatchingRegexp([iname,iext]);
            if iscell(value)&&isempty(value)
                imageFiles{i}='';
            else
                imageFiles{i}=value;
            end
        else
            imageFiles{i}='';
        end
    end


    modelLookupMatFileName=sbioprojectObj.loadFilesMatchingRegexp('simbiodata.mat');
    oldWarningState=warning('off');
    models=load(modelLookupMatFileName{1});
    warning(oldWarningState);

    deleteFile(modelLookupMatFileName{1});

end

function postToOtherAppForProjectLoad(inputs,results)


    if strcmp(inputs.appType,'ModelingApp')
        SimBiology.web.desktophandler('postEventToModelAnalyzer',results);
    else
        SimBiology.web.desktophandler('postEventToModelBuilder',results);
    end

end

function out=clearTempDirectory(action)

    tempDir=SimBiology.web.internal.desktopTempdir();
    allFiles=dir(tempDir);



    w=warning('off','all');


    oldState=recycle;
    recycle('off');

    success=true;
    try
        for i=1:numel(allFiles)
            if~allFiles(i).isdir
                delete([allFiles(i).folder,filesep,allFiles(i).name]);
            end
        end
    catch
        success=false;
    end


    recycle(oldState);


    warning(w);

    out={action,success};

end

function program=getProgram(programs,index)

    if iscell(programs)
        program=programs{index};
    else
        program=programs(index);
    end

end

function[backupCreated,message]=backupProject(projectName)


    backupCreated=true;
    message='';


    backupFileName=[projectName,'.bak'];
    index=1;

    if exist(projectName,'file')
        [status,message]=copyfile(projectName,backupFileName,'f');


        if status~=1
            message=sprintf('The following error occurred while saving a backup:\n%s',message);
            backupCreated=false;
        end
    end


end

function saveDataToMATFile(value,varname,matfile)

    SimBiology.web.datahandler('saveDataToMATFile',value,varname,matfile);

end

function out=doesDiagramSyntaxNeedToBeInitialized(input)

    out=SimBiology.web.diagram.inithandler('doesDiagramSyntaxNeedToBeInitialized',input);

end

function deleteFile(name)

    oldState=recycle;
    recycle('off');
    delete(name)
    recycle(oldState);

end

function turnOnEvents(m)

    SimBiology.web.modelhandler('turnOnEvents',m);

end

function out=addWarningsForDuplicateNames(out)

    models=out.project.Models;
    numModels=numel(models);
    newWarnings=cell(numModels,1);
    for i=1:numModels
        model=models(i);
        newWarnings{i}=getAnyDuplicateNamesWarning(model);
    end
    out.warnings=vertcat(out.warnings,newWarnings{:});

end

function msg=getAnyDuplicateNamesWarning(modelInfoStruct)

    mobj=SimBiology.web.modelhandler('getModelFromSessionID',modelInfoStruct.obj);
    lastwarn('');
    warnForDuplicateNames(mobj);
    [msg,id]=lastwarn();
    msg=SimBiology.web.internal.errortranslator(id,msg);

end
