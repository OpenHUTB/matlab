function out=savecodegenerator(action,varargin)











    out=[];
    switch(action)
    case 'saveProgram'
        out=saveProgram(varargin{:});
    case 'saveModelCache'
        out=saveModelCache(varargin{:});
    case 'getModelInfo'
        out=getModelInfo(varargin{:});
    case 'getConfigsetInfo'
        out=getConfigsetInfo(varargin{:});
    end

end

function out=saveProgram(lastProgram,argList,inputs)

    if isempty(lastProgram)||isempty(inputs.stepToRun)||strcmp(inputs.stepArgsToUpdate,'replaceAll')
        steps=inputs.steps;
        if~iscell(steps)
            steps={steps};
        end

        out=struct;
        out.steps=steps;
        out.modelCacheName='';
        out.modelInfo='';
        out.dataCache='';


        modelArg=getModelFromArgList(argList);
        if~isempty(modelArg)
            out.modelCacheName=cacheModel(modelArg,inputs,steps);
            out.modelInfo=getModelInfo(modelArg);
            out.modelName=modelArg.Name;
            out.configset=getConfigsetInfo(modelArg);
        end


        dataArg=inputs.rawdata;
        if~isempty(dataArg)
            out.dataCache=cacheData(dataArg,inputs,steps);
        end


        variantArg=getModifierFromArgList(argList,'SimBiology.Variant');
        if~isempty(variantArg)
            out.variant=getVariantInfo(variantArg);
        end


        dosesArg=getModifierFromArgList(argList,'SimBiology.Dose');
        if~isempty(dosesArg)
            out.dose=getDoseInfo(dosesArg);
        end

    elseif strcmp(inputs.stepArgsToUpdate,'replaceModelAndStep')

        out=replaceStep(lastProgram,inputs.steps,inputs.stepToRun);
        out=replaceStep(out,inputs.steps,'Model');

        steps=inputs.steps;
        if~iscell(steps)
            steps={steps};
        end


        modelArg=getModelFromArgList(argList);
        if~isempty(modelArg)
            out.modelCacheName=cacheModel(modelArg,inputs,steps);
            out.modelInfo=getModelInfo(modelArg);
            out.modelName=modelArg.Name;
            out.configset=getConfigsetInfo(modelArg);
        end


        variantArg=getModifierFromArgList(argList,'SimBiology.Variant');
        if~isempty(variantArg)
            out.variant=getVariantInfo(variantArg);
        end


        dosesArg=getModifierFromArgList(argList,'SimBiology.Dose');
        if~isempty(dosesArg)
            out.dose=getDoseInfo(dosesArg);
        end

    elseif strcmp(inputs.stepArgsToUpdate,'replaceStepOnly')
        out=replaceStep(lastProgram,inputs.steps,inputs.stepToRun);

    elseif strcmp(inputs.stepArgsToUpdate,'replaceDoseAndStep')
        out=replaceStep(lastProgram,inputs.steps,inputs.stepToRun);
        dosesArg=getModifierFromArgList(argList,'SimBiology.Dose');
        if~isempty(dosesArg)
            temp=getDoseInfo(dosesArg);
            if isfield(temp,'doseStep')
                out.dose.doseStep=temp.doseStep;
            end
        end

        modelArg=getModelFromArgList(argList);
        if~isempty(modelArg)
            out.configset=getConfigsetInfo(modelArg);
        end
    end

end

function program=replaceStep(program,newSteps,step)

    index=-1;
    for i=1:length(program.steps)
        if strcmp(program.steps{i}.name,step)
            index=i;
            break;
        end
    end

    if index~=-1
        for i=1:length(newSteps)
            if strcmp(newSteps{i}.name,step)
                program.steps{index}=newSteps{i};
                break;
            end
        end
    end

end

function modelInfo=getModelInfo(model)

    modelInfo.sessionID=model.SessionID;
    modelInfo.transactionID=SimBiology.Transaction.getUndoIndex(model);

end

function cacheName=cacheModel(model,inputs,steps)

    modelStep=getStepByType(steps,'Model');
    cacheModel=modelStep.modelCache;
    modelCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'modelCacheLookup.mat'];
    sessionID=model.SessionID;
    transactionID=SimBiology.Transaction.getUndoIndex(model);
    needToAdd=true;
    cacheName='';
    existingNames={};
    modelCacheLookup=[];

    if exist(modelCacheLookupFile,'file')
        if~inputs.isUsingModelCache&&~isempty(inputs.dataRow)&&~isempty(inputs.dataRow.modelCacheName)
            inputs.modelCacheName=inputs.dataRow.modelCacheName;
            deleteModelCache(inputs);
        end

        if cacheModel
            data=load(modelCacheLookupFile);
            modelCacheLookup=data.modelCacheLookup;
            if~isempty(modelCacheLookup)
                existingNames={modelCacheLookup.name};

                for i=1:numel(modelCacheLookup)
                    nextSessionID=modelCacheLookup(i).sessionID;
                    nextTransactionID=modelCacheLookup(i).transactionID;
                    if(nextSessionID==sessionID)&&(transactionID==nextTransactionID)
                        cacheName=modelCacheLookup(i).name;
                        needToAdd=false;
                        break;
                    end
                end
            end
        end
    end

    if(cacheModel&&needToAdd)
        cacheName=findUniqueNameUsingDelimiter(existingNames,'modelCache');
        data=struct;
        data.sessionID=sessionID;
        data.transactionID=transactionID;
        data.name=cacheName;
        modelCacheLookup=[modelCacheLookup,data];

        saveDataToMATFile(modelCacheLookup,'modelCacheLookup',modelCacheLookupFile);
        saveDataToMATFile(model,'model',[SimBiology.web.internal.desktopTempdir,filesep,cacheName,'.mat']);
    end

end

function cacheName=saveModelCache(model)

    modelCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'modelCacheLookup.mat'];
    existingNames={};
    modelCacheLookup=[];

    if exist(modelCacheLookupFile,'file')
        data=load(modelCacheLookupFile);
        modelCacheLookup=data.modelCacheLookup;
        if~isempty(modelCacheLookup)
            existingNames={modelCacheLookup.name};
        end
    end

    cacheName=findUniqueNameUsingDelimiter(existingNames,'modelCache');
    data=struct;
    data.sessionID=model.SessionID;
    data.transactionID=SimBiology.Transaction.getUndoIndex(model);
    data.name=cacheName;
    modelCacheLookup=[modelCacheLookup,data];

    saveDataToMATFile(modelCacheLookup,'modelCacheLookup',modelCacheLookupFile);
    saveDataToMATFile(model,'model',[SimBiology.web.internal.desktopTempdir,filesep,cacheName,'.mat']);

end

function out=cacheData(data,inputs,steps)

    dataStep=getDataStep(steps);
    cacheData=dataStep.dataCache;
    dataCacheLookupFile=[SimBiology.web.internal.desktopTempdir,filesep,'dataCacheLookup.mat'];
    dataInfo=buildDataInfo(dataStep);
    dataName=getDataName(dataStep);
    out=[];


    if exist(dataCacheLookupFile,'file')
        if~isempty(inputs.dataRow)&&~isempty(inputs.dataRow.dataCache)
            inputs.dataCache=inputs.dataRow.dataCache;
            deleteDataCache(inputs);
        end
    end

    if cacheData

        template=struct('dataName','','dataCacheName','');
        out=repmat(template,1,numel(dataInfo));
        needToWarn=false;


        for i=1:numel(dataInfo)
            needToAdd=true;
            dataCacheLookup=[];
            cacheName='';



            if isstruct(data)
                if isfield(data,dataName{i})
                    dataToSave=data.(dataName{i});
                elseif isfield(data,'results')
                    dataToSave=data.results;
                else
                    dataToSave=[];
                end
            else
                dataToSave=data;
            end

            type=class(dataToSave);

            if exist(dataCacheLookupFile,'file')
                dataCacheLookup=load(dataCacheLookupFile);
                dataCacheLookup=dataCacheLookup.dataCacheLookup;

                if~isempty(dataCacheLookup)
                    for j=1:numel(dataCacheLookup)
                        nextType=dataCacheLookup(j).type;
                        nextDataInfo=dataCacheLookup(j).dataInfo;



                        if strcmp(nextType,type)&&isequal(nextDataInfo,dataInfo(i))
                            cacheName=dataCacheLookup(j).name;
                            cacheFilename=[SimBiology.web.internal.desktopTempdir,filesep,cacheName,'.mat'];
                            if exist(cacheFilename,'file')
                                nextData=load(cacheFilename);
                                nextData=nextData.data;

                                if isequaln(nextData,dataToSave)
                                    needToAdd=false;
                                    break;
                                end
                            else


                                needToWarn=true;
                            end
                        end
                    end
                end
            end


            if needToAdd
                cacheName=saveDataCache(dataCacheLookup,dataCacheLookupFile,dataToSave,type,dataInfo(i));
            end

            out(i).dataName=dataName{i};
            out(i).dataCacheName=cacheName;
        end
        if needToWarn
            SimBiology.web.eventhandler('warning','SimBiology:sbiodesktoperrortranslator:CORRUPTED_PROJECT_STORE');
        end
    end

end

function cacheName=saveDataCache(dataCacheLookup,dataCacheLookupFile,data,type,dataInfo)

    if isempty(dataCacheLookup)
        existingNames={};
    else
        existingNames={dataCacheLookup.name};
    end

    cacheName=findUniqueNameUsingDelimiter(existingNames,'dataCache');
    next=struct;
    next.name=cacheName;
    next.type=type;
    next.dataInfo=dataInfo;
    dataCacheLookup=[dataCacheLookup,next];

    saveDataToMATFile(dataCacheLookup,'dataCacheLookup',dataCacheLookupFile);
    saveDataToMATFile(data,'data',[SimBiology.web.internal.desktopTempdir,filesep,cacheName,'.mat']);

end

function csOut=getConfigsetInfo(model)

    oldWarnState=warning('off','MATLAB:structOnObject');
    cleanup=onCleanup(@()warning(oldWarnState));

    cs=getconfigset(model,'default');
    csOut=struct(cs);
    csOut=rmfield(csOut,'RuntimeOptions');
    csOut=rmfield(csOut,'SensitivityAnalysisOptions');
    csOut.CompileOptions=struct(csOut.CompileOptions);
    csOut.SolverOptions=struct(csOut.SolverOptions);



    allSolverOptions=csOut.AllSolverOptions;
    csOut.AllSolverOptions=cell(1,numel(allSolverOptions));
    for i=1:length(allSolverOptions)
        type=class(allSolverOptions(i));
        next=struct(allSolverOptions(i));
        next.Type=type;
        csOut.AllSolverOptions{i}=next;
    end

end

function out=getVariantInfo(variantArg)


    template=struct;
    template.Name='';
    template.Content={};


    names=fieldnames(variantArg);



    for i=1:numel(names)
        name=names{i};
        next=variantArg.(name);
        if isa(next,'SimBiology.Variant')
            values=repmat(template,1,numel(next));
            for j=1:numel(next)
                values(j).Name=next(j).Name;
                values(j).Content=next(j).Content;
            end
            out.(name)=values;
        end
    end

end

function out=getDoseInfo(doseArg)


    template=struct;
    template.Name='';
    template.Table=[];
    template.TargetName='';
    template.AmountUnits='';
    template.RateUnits='';
    template.TimeUnits='';
    template.LagParameterName='';
    template.DurationParameterName='';
    template.EventMode='';


    names=fieldnames(doseArg);



    for i=1:numel(names)
        name=names{i};
        next=doseArg.(name);
        if isa(next,'SimBiology.Dose')
            values=repmat(template,1,numel(next));
            for j=1:numel(next)
                values(j).Name=next(j).Name;
                values(j).Table=getTable(next(j));
                values(j).TargetName=next(j).TargetName;
                values(j).AmountUnits=next(j).AmountUnits;
                values(j).RateUnits=next(j).RateUnits;
                values(j).TimeUnits=next(j).TimeUnits;
                values(j).LagParameterName=next(j).LagParameterName;
                values(j).DurationParameterName=next(j).DurationParameterName;
                values(j).EventMode=next(j).EventMode;
            end
            out.(name)=values;
        end
    end

end

function out=getModelFromArgList(argList)

    out=[];
    for i=1:numel(argList)
        if isa(argList{i},'SimBiology.Model')
            out=argList{i};
            break;
        end
    end

end

function out=getModifierFromArgList(argList,type)

    out=SimBiology.web.codegenerationutil('getModifierFromArgList',argList,type);

end

function out=getDataStep(steps)

    out=[];
    for i=1:length(steps)
        step=steps{i};
        if step.enabled
            switch(step.type)
            case{'DataNCA','DataFit','DataCI','DataCustom','DataStatistics'}
                out=step;
                break;
            end
        end
    end

end

function out=buildDataInfo(dataStep)

    if strcmp(dataStep.type,'DataCustom')
        template=struct('columnInfo','','rows',0,'columns',0,'exclusions',[]);
        out=repmat(template,1,numel(dataStep.customProgramDataInfo));
        for i=1:numel(out)
            out(i).columnInfo=dataStep.customProgramDataInfo(i).columnInfo;
            out(i).rows=dataStep.customProgramDataInfo(i).rows;
            out(i).columns=dataStep.customProgramDataInfo(i).columns;
            out(i).exclusions=dataStep.customProgramDataInfo(i).exclusions;
        end
    else
        out.columnInfo=dataStep.columnInfo;
        out.rows=dataStep.rows;
        out.columns=dataStep.columns;
        out.exclusions=dataStep.exclusions;
    end

end

function out=getDataName(dataStep)

    if strcmp(dataStep.type,'DataCustom')
        out=cell(1,numel(dataStep.customProgramDataInfo));
        for i=1:numel(out)
            out{i}=dataStep.customProgramDataInfo(i).dataName;
        end
    else
        out={dataStep.dataName};
    end

end

function name=findUniqueNameUsingDelimiter(allNames,nameIn)

    name=SimBiology.web.codegenerationutil('findUniqueNameUsingDelimiter',allNames,nameIn,'',true);

end

function step=getStepByType(steps,type)

    step=SimBiology.web.codegenerationutil('getStepByType',steps,type);


end

function saveDataToMATFile(value,varname,matfile)

    SimBiology.web.datahandler('saveDataToMATFile',value,varname,matfile);

end

function deleteModelCache(inputs)

    SimBiology.web.datahandler('deleteModelCache',inputs);

end

function deleteDataCache(inputs)

    SimBiology.web.datahandler('deleteDataCache',inputs);

end
