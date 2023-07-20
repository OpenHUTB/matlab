function candidates=recommendForModelWorkspaceMigration(modelsToCheck,varargin)



























    validInput=@(x)iscell(x)||isstring(x);
    defaulttypesOfVars={};
    p=inputParser;
    p.addRequired('modelsToCheck',validInput);
    p.addOptional('typeOfVars',defaulttypesOfVars,validInput);
    p.addOptional('includeParameters',true,@islogical);

    p.parse(modelsToCheck,varargin{:});

    if isstring(p.Results.typeOfVars)
        typeOfVars=cellstr(p.Results.typeOfVars);
    else
        typeOfVars=p.Results.typeOfVars;
    end

    if isstring(p.Results.modelsToCheck)
        modelsToCheck=p.Results.modelsToCheck;
    end

    includeParameters=p.Results.includeParameters;

    modelStartList=Simulink.allBlockDiagrams;
    errHappened=false;
    errMsg='';

    try
        [modelsInProject,closePrj]=findOtherModelsInProjectsWith(modelsToCheck);

        if~isempty(modelsInProject)
            modelsToCheck=unique(cat(1,modelsToCheck,modelsInProject'))';
        end

        variableMap=getVariableUsageFromModels(modelsToCheck);

        candidates=checkUsage(variableMap,typeOfVars,includeParameters);
    catch exception
        errMsg=exception.message;
        errHappened=true;
    end


    modelCurrentList=Simulink.allBlockDiagrams;
    modelCloseList=setdiff(modelCurrentList,modelStartList);
    close_system(modelCloseList);

    if closePrj
        prj.close
    end

    if errHappened
        error(errMsg);
    end

end

function[modelInProject,closePrj]=findOtherModelsInProjectsWith(modelsToCheck)
    closePrj=false;
    modelInProject=string.empty;
    for modelIndex=1:numel(modelsToCheck)

        modelName=modelsToCheck{modelIndex};
        file2projectMapper=matlab.internal.project.util.FileToProjectMapper(modelName);
        if file2projectMapper.InAProject
            if~file2projectMapper.InRootOfALoadedProject
                if~isempty(matlab.project.rootProject)
                    error('Can only evaluate models from one project at time');
                end
                prj=openProject(file2projectMapper.ProjectRoot);
                closePrj=true;
            else
                prj=file2projectMapper.findLoadedProjectWithRoot;
            end
            for file=prj.Files
                [~,~,ext]=fileparts(file.Path);
                if strcmpi(ext,".slx")||strcmpi(ext,".mdl")
                    modelInProject(end+1)=string(file.Path);%#ok<AGROW> 
                end
            end
        end
    end
end

function variableMap=getVariableUsageFromModels(modelsToCheck)
    variableMap=containers.Map;
    for modelIndex=1:numel(modelsToCheck)

        modelName=modelsToCheck{modelIndex};
        [~,f,~]=fileparts(modelName);

        if~bdIsLoaded(f)
            mdlinfo=Simulink.MDLInfo(f);
            if mdlinfo.IsLibrary
                continue
            end

            load_system(modelName);
        elseif bdIsLibrary(f)
            continue
        end

        variableUsageToCheck=Simulink.findVars(f,'SearchReferencedModels','on');

        for variableIndex=1:numel(variableUsageToCheck)
            currentVariableUsage=variableUsageToCheck(variableIndex);


            if(strcmp(currentVariableUsage.SourceType,'model workspace'))||...
                (strcmp(currentVariableUsage.SourceType,'mask workspace'))
                continue;
            end

            for userIndex=1:numel(currentVariableUsage.Users)
                use=currentVariableUsage.Users{userIndex};
                handle=getSimulinkBlockHandle(use);
                key=[currentVariableUsage.Name,'::',currentVariableUsage.Source];
                if handle>0
                    parentBlock=get_param(bdroot(handle),'Name');
                    if isKey(variableMap,key)
                        modelset=variableMap(key);
                    else
                        modelset=containers.Map;
                    end
                    modelset(parentBlock)=currentVariableUsage;
                    variableMap(key)=modelset;
                end
            end
        end
    end
end

function candidates=checkUsage(variableMap,typeOfVars,includeParameters)
    candidates=containers.Map;
    keys=variableMap.keys;
    for mapIndex=1:variableMap.Count

        modelListMap=variableMap(keys{mapIndex});
        if modelListMap.Count~=1
            continue;
        end

        keyList=modelListMap.keys;
        currentModel=keyList{1};
        currentVariableUsage=modelListMap(currentModel);

        matched=false;
        variable=evalinGlobalScope(currentModel,currentVariableUsage.Name);

        if includeParameters
            if isnumeric(variable)||...
                isa(variable,'Simulink.Parameter')||...
                isa(variable,'Simulink.LookupTable')||...
                isa(variable,'Simulink.Breakpoint')
                matched=true;
            end
        end

        if~matched
            for paramTypeIndex=1:numel(typeOfVars)
                paramType=typeOfVars{paramTypeIndex};
                if isa(variable,paramType)
                    matched=true;
                    break;
                end
            end
        end

        if~matched
            continue;
        end

        variableAnswer.Name=currentVariableUsage.Name;
        variableAnswer.Source=currentVariableUsage.Source;

        if candidates.isKey(currentModel)
            objectsToMove=candidates(currentModel);
            objectsToMove(end+1)=variableAnswer;%#ok<AGROW> 
        else
            objectsToMove=struct(variableAnswer);
        end

        candidates(currentModel)=objectsToMove;
    end
end

