function out=runhandler(action,varargin)












    out={action};

    if strcmp(action,'setupChannel')
        out=setupChannel;
        return;
    end


    inputs=varargin{1};
    originalAction=inputs.action;
    if strcmp(originalAction,'testRunSection')
        inputs.action='runSection';
    end

    try
        [code,argList,rawdata]=generateCode(inputs);
        inputs.action=originalAction;
    catch ex

        msgStruct=struct("component",[],...
        "source",'lasterr',...
        "message",SimBiology.web.internal.errortranslator(ex),...
        "messageID",ex.identifier,...
        "isError",true);
        SimBiology.web.eventhandler('message',msgStruct);
        info.Errored=true;
        out={'run',info};
        message.publish('/SimBiology/endProgramRun',info);
        notifyRunComplete;
        return;
    end

    switch(inputs.action)
    case{'run','runSection','runSectionAndAdvance'}
        notification=onCleanup(@()notifyRunComplete());
        inputs.rawdata=rawdata;
        out=runCode(code,argList,inputs);
    case 'exportArguments'
        out=exportArguments(inputs,argList);
    case 'code'
        showCode(code);
    case{'test','testRunSection'}
        out=struct;
        out.code=code;
        out.args=argList;
    end

end

function out=setupChannel

    out.Channel=message.subscribe('/SimBiology/startProgramRun',@runprogram);

end

function runprogram(inputs)

    message.unsubscribe(uint64(inputs.channel));
    SimBiology.web.runhandler('run',inputs);

end

function notifyRunComplete








    message.publish('/SimBiology/endProgramRun',struct('ReadyToRun',true));

end

function[mainFunction,argList,rawdata]=generateCode(inputs)


    mainFunction=readTemplate('runprogram.txt');


    steps=inputs.steps;
    if~iscell(steps)
        inputs.steps={steps};
    end






    for i=1:length(steps)
        steps{i}.sectionEnabled=steps{i}.enabled;
    end

    if strcmp(inputs.action,'runSection')||strcmp(inputs.action,'runSectionAndAdvance')


        for i=1:length(steps)
            if~(steps{i}.internal.isSetup)
                steps{i}.enabled=steps{i}.internal.activeStep;
            end
        end
    end

    inputs.steps=steps;


    [argList,support,rawdata]=getArgs(inputs,steps);
    model=argList{1};


    [mainFunction,argList]=generateStepCode(mainFunction,model,support,inputs,argList);
    mainFunction=cleanupContent(mainFunction);

end

function out=runCode(code,argList,inputs)

    logfile=[SimBiology.web.internal.desktopTempname(),'.xml'];

    try
        matlab.internal.diagnostic.log.open(logfile);
        fileCleanup=onCleanup(@()deleteFile(logfile));
        modelObj=[];
        if length(argList)>1
            if isa(argList{1},'SimBiology.Model')





                modelObj=argList{1};
                transaction=SimBiology.Transaction.create(modelObj);%#ok<NASGU>
            end
        end

        isMultiCmptModel=[];

        if length(argList)>=2
            model=argList{1};
            cs=argList{2};
            if isa(model,'SimBiology.Model')&&isa(cs,'SimBiology.Configset')
                if~any(strcmp(cs.SolverType,{'ssa','expltau','impltau'}))
                    runSensitivity=cs.SolverOptions.SensitivityAnalysis;
                    if runSensitivity
                        sensInputs=get(cs.SensitivityAnalysisOptions,'Inputs');
                        sensOutputs=get(cs.SensitivityAnalysisOptions,'Outputs');

                        sensitivityCleanup=onCleanup(@()restoreSensitivity(cs,sensInputs,sensOutputs));
                        set(cs.SolverOptions,'SensitivityAnalysis',false);
                    end



                    sensitivityStep=getStepByType(inputs.steps,'Sensitivity');
                    if~isempty(sensitivityStep)&&~strcmp(cs.SolverType,'sundials')
                        msgStruct=struct("component",[],...
                        "source",0,...
                        "message",'Programs running sensitivity analysis will use the sundials solver.',...
                        "messageID",'SimBiology:AnalysisApp:InvalidSolver',...
                        "isError",false);
                        SimBiology.web.eventhandler('message',msgStruct);
                    end
                end
            end
            isMultiCmptModel=(numel(model.Compartments)>1);
        end


        fileName=createRunProgramMFile(code);
        htemp=which(fileName);%#ok<NASGU>
        mfileCleanup=onCleanup(@()deleteFile(fileName));


        if inputs.configureLogger
            SimBiology.function.internal.SimulationCallback.set(@incrementScanRun);
            loggerCleanup=onCleanup(@SimBiology.function.internal.SimulationCallback.clear);
        end



        if~isempty(modelObj)
            set(modelObj,'sendEvent',false,'SendSaveNeededEvent',false);
            restoreEventsCleanup=onCleanup(@()set(modelObj,'sendEvent',true,'SendSaveNeededEvent',true));
        end


        [~,name]=fileparts(fileName);
        outputArgs={};

        nout=nargout(name);%#ok<NASGU>
        evalc('[outputArgs{1:nout}] = feval(name, argList{:});');


        data=outputArgs{1};
        data=data.output;


        if inputs.exportData
            assignin('base','output',data);
        end


        if inputs.exportModel&&~isempty(argList)
            model=argList{1};
            if isa(model,'SimBiology.Model')
                assignin('base','mobj',model);
            end
        end


        programInfo.programName=inputs.programName;
        programInfo.programType=inputs.programType;
        programInfo.dataName=inputs.dataName;
        programInfo.matfileName=inputs.matfileName;
        programInfo.overlay=inputs.overlay;
        programInfo.overlayCount=1;
        programInfo.modelCacheName='';
        programInfo.modelInfo='';
        programInfo.dataCache='';


        if~isempty(inputs.matfileName)&&(inputs.overlay)
            loadedData=loadVariable(inputs.matfileName,'data');


            if~isempty(loadedData)
                [data,count]=concatenateData(loadedData,data);
                programInfo.overlayCount=count;
            end
        end


        outputNames=fieldnames(data);
        results=cell(1,length(outputNames));
        dataInfo=struct;
        for i=1:length(outputNames)
            input.next=data.(outputNames{i});
            input.name=outputNames{i};
            if isa(input.next,'SimData')

                if~isempty(isMultiCmptModel)
                    for j=1:numel(input.next)
                        if~isstruct(input.next(j).UserData)
                            input.next(j).UserData=struct('isMultiCpt',isMultiCmptModel);
                        else
                            input.next(j).UserData.isMultiCpt=isMultiCmptModel;
                        end
                    end
                end


                if strcmp(inputs.programTypeStr,'Scan')
                    input.additionalArgs=data;
                end
            end
            [info,dataInfoOut]=SimBiology.web.datahandler('getDataInfo',input);
            results{i}=info;

            if~isempty(dataInfoOut)
                dataInfo.(outputNames{i})=dataInfoOut;
            end
        end


        if~isempty(inputs.matfileName)

            try
                program=loadVariable(inputs.matfileName,'programInfo');
            catch
                program=[];
            end
            program=SimBiology.web.savecodegenerator('saveProgram',program,argList,inputs);
            programInfo.modelCacheName=program.modelCacheName;
            programInfo.modelInfo=program.modelInfo;
            programInfo.dataCache=program.dataCache;
            SimBiology.web.datahandler('saveDatasToMATFile',{data,dataInfo,program},{'data','dataInfo','programInfo'},inputs.matfileName);
        end


        if~isempty(inputs.plots)

            newdatatemplate=struct('dataSource',struct('programName',inputs.programName,'dataName',inputs.dataName,'variableName',[]),...
            'data',{[]},...
            'columnInfo',{[]},...
            'dataInfo',{[]});
            newdata=repmat(newdatatemplate,length(outputNames),1);
            for i=1:length(outputNames)
                newdata(i).dataSource.variableName=outputNames{i};

                newdata(i).data=data.(outputNames{i});

                if isfield(dataInfo,outputNames{i})
                    newdata(i).dataInfo=dataInfo.(outputNames{i});
                end

                info=results{i};


                if(isa(data.(outputNames{i}),'SimData')&&isfield(info,'columnNames'))||...
                    (strcmp(inputs.programTypeStr,'Group Simulation')&&isa(data.(outputNames{i}),'table'))
                    newdata(i).columnInfo=SimBiology.web.datahandler('getColumnInfoFromDataInfo',info,data.(outputNames{i}));
                end
            end

            plotArgs=struct('programInfo',struct,'plots',[]);
            plotArgs.plots=inputs.plots;
            if numel(argList)>1
                plotArgs.programInfo.configset=argList{2};
            else
                plotArgs.programInfo.configset=[];
            end
            plotArgs.programInfo.programName=inputs.programName;
            plotArgs.programInfo.dataName=inputs.dataName;
            plotArgs.programInfo.overlay=inputs.overlay;
            plotArgs.programInfo.newdata=newdata;
            plotResults=SimBiology.web.plothandler('plotAfterRun',plotArgs);
        else
            plotResults=[];
        end

        if inputs.showDataSheet
            dataSheetInfo=inputs.dataSheetInfo;
            variables=struct;
            variables.ColumnName=dataSheetInfo.columnName;
            variables.DataName='LastRun';
            variables.MATFile=inputs.matfileName;
            variables.MATFileDerivedVariableName='deriveddata';
            variables.MATFileVariableName='data';
            variables.ParentType=inputs.programType;
            variables.SourceName=inputs.programName;
            variables.SourceType=dataSheetInfo.sourceType;
            variables.StructFieldName=dataSheetInfo.columnName;
            variables.type=class(data.(dataSheetInfo.columnName));
            variables.vectorize=false;

            args=struct;
            args.mouseOverColumn=-1;
            args.mouseOverRow=-1;
            args.variables=variables;

            dataSheetResults=SimBiology.web.datahandler('getDataWithPostProcessing',args);
            dataSheetOut.data=dataSheetResults(2);
            dataSheetOut.name=variables.ColumnName;
            dataSheetOut.type=variables.type;
        else
            dataSheetOut=[];
        end
    catch ex
        out=cleanupAfterError(inputs,logfile,ex);
        return;
    end


    handleMessagesAfterRun(logfile);


    info.Errored=false;
    info.ProgramInfo=programInfo;
    info.OutputArgs=results;
    info.PlotInfo=plotResults;
    info.DataSheetInfo=dataSheetOut;
    info.Action=inputs.action;
    out={'run',info};


    if~isempty(inputs.matfileName)
        message.publish('/SimBiology/endProgramRun',info);
    else


        out=data;
    end

end

function out=cleanupAfterError(inputs,logfile,ex)

    simbioErrors=sbiolasterror;


    if~strcmp(ex.identifier,'SimBiology:StackedError')&&(isempty(simbioErrors)||~any(strcmp(ex.identifier,{simbioErrors.MessageID})))
        errorMessage=SimBiology.web.internal.errortranslator(ex);

        msgStruct=struct("component",[],...
        "source",'lasterr',...
        "message",errorMessage,...
        "messageID",ex.identifier,...
        "isError",true);
        SimBiology.web.eventhandler('message',msgStruct);
    end


    handleMessagesAfterRun(logfile);



    if strcmp(inputs.action,'run')&&~isempty(inputs.matfileName)&&~isempty(inputs.dataRow)
        deleteDataInputs.variableName=inputs.dataRow.matfileVariableName;
        deleteDataInputs.derivedDataName=inputs.dataRow.matfileDerivedVariableName;
        deleteDataInputs.matfileName=inputs.matfileName;
        deleteDataInputs.deleteMATFile=false;
        SimBiology.web.datahandler('deleteData',deleteDataInputs);
    end


    info.Errored=true;
    info.action=inputs.action;
    out={'run',info};
    message.publish('/SimBiology/endProgramRun',info);

end

function[data1,count]=concatenateData(data1,data2)

    names=fieldnames(data1);
    for i=1:length(names)
        next1=data1.(names{i});
        next2=data2.(names{i});
        data1.(names{i})=[next1;next2];
    end

    count=length(data1.(names{1}));

end

function handleMessagesAfterRun(logfile)

    if exist(logfile,'file')

        matlab.internal.diagnostic.log.close(logfile);


        warningLog=matlab.internal.diagnostic.log.load(logfile);


        simbioWarnings=sbiolastwarning;


        template=struct('component',[],'source',-1,'message','','messageID','','isError',false);
        msgStruct=repmat(template,1,numel(warningLog));
        count=1;

        for i=1:numel(warningLog)

            identifier=warningLog(i).identifier;
            message=warningLog(i).message;

            if~isempty(message)&&~warningLog(i).wasDisabled
                if any(strcmp(identifier,{'MATLAB:Completion:NoEntryPoints','SimBiology:SimFunction:DOSES_NOT_EMPTY'}))

                elseif~isempty(simbioWarnings)&&any(strcmp(identifier,{simbioWarnings.MessageID}))

                else
                    msgStruct(count).message=message;
                    msgStruct(count).messageID=identifier;
                    count=count+1;
                end
            end
        end

        if count>1
            SimBiology.web.eventhandler('message',msgStruct(1:count-1));
        end
    end

end

function showCode(code)

    matlab.desktop.editor.newDocument(code);

end

function[argList,support,rawdata]=getArgs(inputs,steps)

    out=SimBiology.web.codegenerationutil('getArgs',inputs,steps);
    argList=out.argList;
    support=out.support;
    rawdata=out.rawdata;

end

function[mainFunction,argList]=generateStepCode(mainFunction,model,support,inputs,argList)


    steps=inputs.steps;


    stepCalls={};


    stepCode={};


    stepCleanup={};


    modelStep=getStepByType(steps,'Model');
    [mainFunction,cleanup]=generateSetupCode(mainFunction,support,modelStep,steps);

    if~isempty(cleanup)
        stepCleanup{end+1}={cleanup};
    end



    for i=1:length(steps)
        step=steps{i};
        if step.enabled
            switch(step.type)
            case 'Steady State'

                samplesStep=getStepByType(steps,'Generate Samples');
                if samplesStep.sectionEnabled

                    [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateSteadyStateInScanCode(step,support,model);
                else

                    [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateSteadyStateCode(step,support,model);
                end
            case 'Generate Samples'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1},steps{i},argList]=SimBiology.web.generatesamplescodegenerator(step,model,argList,support);%#ok<*AGROW>
            case 'Simulation'




                [steps,argList]=generateCodeNeededBySimulationOnlyRun(steps,model,argList,support);


                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateSimulationCode(model,step,steps,support);
            case 'Sensitivity'




                [steps,argList]=generateCodeNeededBySimulationOnlyRun(steps,model,argList,support);


                samplesStep=getStepByType(steps,'Generate Samples');
                steadyStateStep=getStepByType(steps,'Steady State');
                if samplesStep.sectionEnabled&&~steadyStateStep.sectionEnabled


                    [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateSimulationCode(model,step,steps,support);
                else
                    [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=SimBiology.web.sensitivitycodegenerator(step,model,steps,support);
                end
            case 'Global Sensitivity Analysis'
                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=SimBiology.web.gsacodegenerator(step,steps,argList);
            case 'Add Samples'
                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=SimBiology.web.gsacodegenerator(step,steps,argList);
            case 'MPGSA'
                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=SimBiology.web.gsacodegenerator(step,steps,argList);
            case 'Ensemble Run'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateEnsembleRunCode(step,steps,model);
            case 'NCA'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateNCACode(step,steps);
            case 'Fit'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=SimBiology.web.fitcodegenerator(step,steps,model,argList,support);
            case 'Group Simulation'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=SimBiology.web.fitcodegenerator(step,steps,model,argList,support);
            case 'Confidence Interval'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateConfidenceIntervalCode(step,steps);
            case 'Calculate Observables'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateCalculateObservablesCode(step,steps);
            case 'Custom Code'

                [stepCalls{end+1},stepCode{end+1},stepCleanup{end+1}]=generateCustomCode(step);
            end

            if isRunAction(inputs)&&~step.internal.isSetup
                id=num2str(step.internal.id);
                fullCmd=['SimBiology.web.eventhandler(''runprogram'', ',id,', true);'];
                fullCmd=appendCode(fullCmd,stepCalls{end});
                fullCmd=appendCode(fullCmd,['SimBiology.web.eventhandler(''runprogram'', ',id,', false);']);
                stepCalls{end}=fullCmd;
            end
        end
    end

    if~isempty(support.modelStepParams)||~isempty(support.doseStepParams)
        samplesStep=getStepByType(steps,'Generate Samples');
        if isempty(samplesStep)||~isfield(samplesStep,'paramCode')||((isfield(samplesStep,'paramCode')&&isempty(samplesStep.paramCode)))
            stepCleanup{end+1}={readTemplate('restoreDose.txt')};
        end
    end



    stepCallCode='';
    for i=1:length(stepCalls)
        if~isempty(stepCalls{i})
            stepCallCode=appendCodeInLoop(stepCallCode,stepCalls{i});
            if i~=length(stepCalls)
                stepCallCode=appendCodeInLoop(stepCallCode,'');
            end
        end
    end
    mainFunction=strrep(mainFunction,'$(CALLS_TO_STEP_SUBFUNCTIONS)',stepCallCode);


    stepSubfunctionCode='';
    for i=1:length(stepCode)
        if~isempty(stepCode{i})
            stepSubfunctionCode=appendCodeInLoop(stepSubfunctionCode,stepCode{i});
        end
    end
    mainFunction=strrep(mainFunction,'$(STEP_SUBFUNCTIONS)',stepSubfunctionCode);


    stepCleanupCode='';
    hasCleanupObservables=false;
    for i=1:length(stepCleanup)
        next=stepCleanup{i};
        if~isempty(next)
            for j=1:length(next)
                nextObservables=~isempty(strfind(next{j},'restoreObservables'));
                if(nextObservables&&~hasCleanupObservables)
                    hasCleanupObservables=true;
                    stepCleanupCode=appendCodeInLoop(stepCleanupCode,next{j});
                    stepCleanupCode=appendCodeInLoop(stepCleanupCode,'');
                elseif~nextObservables
                    stepCleanupCode=appendCodeInLoop(stepCleanupCode,next{j});
                    stepCleanupCode=appendCodeInLoop(stepCleanupCode,'');
                end
            end
        end
    end
    mainFunction=strrep(mainFunction,'$(STEP_CLEANUP_CODE)',stepCleanupCode);

end

function[mainFunction,cleanup]=generateSetupCode(mainFunction,support,step,steps)


    mainFunction=generateSignatureCode(mainFunction,support);


    if isfield(step,'accelerate')&&logical(step.accelerate)&&~(step.alwaysAccelerate)
        command='% Prepare the model for accelerated simulation.';
        if(support.doses)
            command=[command,sprintf('\n'),'sbioaccelerate(model, cs, args.input.variants.modelStep, args.input.doses.modelStep);'];%#ok<*SPRINTFN>
        else
            command=[command,sprintf('\n'),'sbioaccelerate(model, cs, args.input.variants.modelStep, []);'];
        end
        mainFunction=strrep(mainFunction,'$(ACCELERATE_MODEL)',command);
    else
        mainFunction=strrep(mainFunction,'$(ACCELERATE_MODEL)','$(REMOVE)');
    end


    [mainFunction,cleanup]=generateStatesToLogCode(mainFunction,step,steps);

end

function mainFunction=generateSignatureCode(mainFunction,support)


    mainFunction=strrep(mainFunction,'$(SIGNATURE)',support.signature);


    names={};
    if(support.model)
        names{end+1}='model';
        names{end+1}='cs';
    end

    if(support.data)
        names{end+1}='data';
    end

    if(support.variants)
        names{end+1}='variants';
    end

    if(support.doses)
        names{end+1}='doses';
    end

    maxLength=max(cellfun('length',names))+1;


    argumentCode='';
    if(support.model)
        argumentCode=['args.input.model',blanks(maxLength-length('model')),'= model;'];
        argumentCode=appendCode(argumentCode,['args.input.cs',blanks(maxLength-length('cs')),'= cs;']);
    end

    if(support.data)||support.customData
        code=['args.input.data',blanks(maxLength-length('data')),'= data;'];
        if isempty(argumentCode)
            argumentCode=code;
        else
            argumentCode=appendCode(argumentCode,code);
        end
    end

    if(support.variants)
        code=['args.input.variants',blanks(maxLength-length('variants')),'= variantsStruct;'];
        argumentCode=appendCode(argumentCode,code);
    end

    if(support.doses)
        code=['args.input.doses',blanks(maxLength-length('doses')),'= dosesStruct;'];
        argumentCode=appendCode(argumentCode,code);
    end

    if(support.output)
        names=support.outputArgs;
        outputCode='% Extract output arguments already generated.';
        for i=1:length(names)
            code=['args.output.',names{i},' = output.',names{i},';'];
            outputCode=appendCode(outputCode,code);
        end

        mainFunction=strrep(mainFunction,'$(OUTPUT)',outputCode);
    else
        mainFunction=strrep(mainFunction,'$(OUTPUT)','$(REMOVE)');
    end

    mainFunction=strrep(mainFunction,'$(INPUT)',argumentCode);

end

function[stepCall,stepCode,stepCleanup]=generateNCACode(step,steps)

    [stepCall,stepCode,stepCleanup]=SimBiology.web.ncacodegenerator(step,steps);

end

function[stepCall,stepCode,stepCleanup]=generateSteadyStateCode(step,support,model)


    stepCall='% Equilibrate the model.';
    stepCall=appendCode(stepCall,'args = runSteadyState(args);');
    stepCleanup={};


    stepCode=readTemplate('runSteadyState.txt');
    stepCode=strrep(stepCode,'$(METHOD)',['''',step.method,'''']);
    stepCode=strrep(stepCode,'$(MIN_STOPTIME)',num2str(step.minStopTime));
    stepCode=strrep(stepCode,'$(MAX_STOPTIME)',num2str(step.maxStopTime));
    stepCode=strrep(stepCode,'$(ABSOLUTE_TOLERANCE)',num2str(step.absoluteTolerance));
    stepCode=strrep(stepCode,'$(RELATIVE_TOLERANCE)',num2str(step.relativeTolerance));

    [stepCode,cleanup]=SimBiology.web.commoncodegenerator('generateParameterizedDoseCode',stepCode,support.modelStepParams);

    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end


    [stepCode,cleanup]=generateTurnOffObservableCode(stepCode,step,model);
    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end

end

function[stepCall,stepCode,stepCleanup]=generateSteadyStateInScanCode(step,support,model)


    stepCall='% Equilibrate the model.';
    stepCall=appendCode(stepCall,'args = runSteadyState(args);');
    stepCleanup={};


    stepCode=readTemplate('runSteadyStateInScan.txt');
    stepCode=strrep(stepCode,'$(METHOD)',['''',step.method,'''']);
    stepCode=strrep(stepCode,'$(MIN_STOPTIME)',num2str(step.minStopTime));
    stepCode=strrep(stepCode,'$(MAX_STOPTIME)',num2str(step.maxStopTime));
    stepCode=strrep(stepCode,'$(ABSOLUTE_TOLERANCE)',num2str(step.absoluteTolerance));
    stepCode=strrep(stepCode,'$(RELATIVE_TOLERANCE)',num2str(step.relativeTolerance));

    [stepCode,cleanup]=SimBiology.web.commoncodegenerator('generateParameterizedDoseCode',stepCode,support.modelStepParams);

    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end


    [stepCode,cleanup]=generateTurnOffObservableCode(stepCode,step,model);
    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end

end

function[steps,argList]=generateCodeNeededBySimulationOnlyRun(steps,model,argList,support)

    samplesIndex=getStepIndexByType(steps,'Generate Samples');
    if samplesIndex~=-1
        samplesStep=steps{samplesIndex};
        if(samplesStep.sectionEnabled&&~samplesStep.enabled)



            [~,~,~,steps{samplesIndex},argList]=SimBiology.web.generatesamplescodegenerator(samplesStep,model,argList,support);
        end
    end

end

function[stepCall,stepCode,stepCleanup]=generateSimulationCode(model,step,steps,support)


    stepCall='% Run simulation.';
    stepCall=appendCode(stepCall,'args = runSimulation(args);');


    stepCode=readTemplate('runSimulation.txt');
    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateSimulationCode',stepCode,step,steps,model,support);

end

function[stepCall,stepCode,stepCleanup]=generateEnsembleRunCode(step,steps,model)


    stepCall='% Run simulation.';
    stepCall=appendCode(stepCall,'args = runSimulation(args);');


    stepCode=readTemplate('runEnsemblerun.txt');
    stepCleanup={};


    stepCode=strrep(stepCode,'$(INTERPOLATION)',step.interpolation);
    stepCode=strrep(stepCode,'$(NUMBER_OF_RUNS)',num2str(step.numberOfRuns));


    [stepCode,cleanup]=generateStopAndOutputTimesCode(stepCode,step,getconfigset(model,'default'));
    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end


    [stepCode,cleanup]=generateSolverTypeCode(stepCode,step);
    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end


    [stepCode,cleanup]=generateLogDecimationCode(stepCode,step);
    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end


    [stepCode,cleanup]=generateTurnOffObservableCode(stepCode,step,model);
    if~isempty(cleanup)
        stepCleanup{end+1}=cleanup;
    end


    observableStep=getStepByType(steps,'Calculate Observables');
    runObservableStep=observableStep.sectionEnabled;

    if runObservableStep&&~isempty(observableStep.statistics)
        [stepCode,cleanup]=generateTurnOnObservableCode(stepCode,observableStep);
        if~isempty(cleanup)
            stepCleanup{end+1}=cleanup;
        end
    else
        stepCode=strrep(stepCode,'$(TURN_ON_OBSERVABLE_CODE)','$(REMOVE)');
    end

end

function[stepCall,stepCode,stepCleanup]=generateConfidenceIntervalCode(step,steps)

    parameterInfo=step.parameter;
    predictionInfo=step.prediction;

    if strcmp(parameterInfo.calculate,'false')&&strcmp(predictionInfo.calculate,'false')
        stepCall='';
        stepCode='';
        stepCleanup={};
        return;
    end


    stepCall='% Compute confidence intervals.';
    stepCall=appendCode(stepCall,'args = runConfidenceInterval(args);');


    stepCode=readTemplate('runConfidenceInterval.txt');
    stepCleanup={};


    fitStep=getStepByType(steps,'Fit');
    if~isempty(fitStep)&&~fitStep.sectionEnabled
        fitStep=[];
    end

    if~isempty(fitStep)
        stepCmd='data = args.output.results;';
        stepCode=strrep(stepCode,'$(EXTRACT_ARGS)',stepCmd);
        useParallel=logical2str(fitStep.runInParallel);
    else
        stepCmd='input = args.input;';
        stepCmd=appendCode(stepCmd,'data  = input.data;');
        stepCode=strrep(stepCode,'$(EXTRACT_ARGS)',stepCmd);
        useParallel=logical2str(step.runInParallel);
    end

    if strcmp(parameterInfo.calculate,'true')
        alpha=num2str((100-parameterInfo.confidenceLevel)/100);
        options={'Alpha','Type'};
        values={alpha,['''',parameterInfo.method,'''']};
        structCommand='';

        if strcmp(parameterInfo.method,'bootstrap')
            options{end+1}='NumSamples';
            values{end+1}=parameterInfo.numSamples;
            options{end+1}='Tolerance';
            values{end+1}=parameterInfo.tolerance;
        elseif strcmp(parameterInfo.method,'profileLikelihood')
            options{end+1}='Tolerance';
            values{end+1}=parameterInfo.tolerance;
            options{end+1}='MaxStepSize';
            values{end+1}=parameterInfo.maxStepSize;
            options{end+1}='UseIntegration';
            values{end+1}=parameterInfo.useIntegration;

            if iscell(parameterInfo.parameters)
                options{end+1}='Parameters';
                values{end+1}=['{',createCommaSeparatedQuotedList(parameterInfo.parameters),'}'];
            end

            if strcmp(parameterInfo.useIntegration,'true')
                options1={'Hessian','InitialStepSize','AbsoluteTolerance','RelativeTolerance'};
                values1={['''',parameterInfo.hessian,''''],parameterInfo.initialStepSize,...
                parameterInfo.absoluteTolerance,parameterInfo.relativeTolerance};

                if strcmp(parameterInfo.hessian,'identity')
                    options1{end+1}='CorrectionFactor';
                    values1{end+1}=parameterInfo.correctionFactor;
                end

                for i=1:length(options1)
                    if isnumeric(values1{i})
                        values1{i}=num2str(values1{i});
                    end
                    structCommand=[structCommand,'''',options1{i},''', ',values1{i},', '];
                end

                structCommand=['integrationOptions      = struct(',structCommand(1:end-2),');'];
            end
        end

        if~isempty(structCommand)
            options{end+1}='IntegrationOptions';
            values{end+1}='integrationOptions';
        end

        options{end+1}='UseParallel';
        values{end+1}=useParallel;

        cmd='sbioparameterci(data, ';
        for i=1:length(options)
            if isnumeric(values{i})
                values{i}=num2str(values{i});
            end
            cmd=[cmd,'''',options{i},''', ',values{i},', '];
        end
        cmd=['args.output.parameterCI = ',cmd(1:end-2),');'];

        if~isempty(structCommand)
            cmd=appendCode(structCommand,cmd);
        end

        stepCmd='% Compute parameter confidence intervals.';
        stepCmd=appendCode(stepCmd,cmd);

        stepCode=strrep(stepCode,'$(PARAMETER_CI)',stepCmd);
    else
        stepCode=strrep(stepCode,'$(PARAMETER_CI)','$(REMOVE)');
    end

    if strcmp(predictionInfo.calculate,'true')
        alpha=num2str((100-predictionInfo.confidenceLevel)/100);
        options={'Alpha','Type'};
        values={alpha,['''',predictionInfo.method,'''']};

        if strcmp(predictionInfo.method,'bootstrap')
            options{end+1}='NumSamples';
            values{end+1}=predictionInfo.numSamples;
        end

        options{end+1}='UseParallel';
        values{end+1}=useParallel;

        cmd='sbiopredictionci(data, ';
        for i=1:length(options)
            if isnumeric(values{i})
                values{i}=num2str(values{i});
            end
            cmd=[cmd,'''',options{i},''', ',values{i},', '];
        end
        cmd=['args.output.predictionCI = ',cmd(1:end-2),');'];

        stepCmd='% Compute prediction confidence intervals.';
        stepCmd=appendCode(stepCmd,cmd);

        stepCode=strrep(stepCode,'$(PREDICTION_CI)',stepCmd);
    else
        stepCode=strrep(stepCode,'$(PREDICTION_CI)','$(REMOVE)');
    end

end

function[stepCall,stepCode,stepCleanup]=generateCalculateObservablesCode(step,steps)

    simulationStep=getStepByType(steps,'Simulation');
    sensitivityStep=getStepByType(steps,'Sensitivity');
    ensembleRunStep=getStepByType(steps,'Ensemble Run');
    fitStep=getStepByType(steps,'Fit');

    if~isempty(simulationStep)||~isempty(sensitivityStep)||~isempty(ensembleRunStep)||~isempty(fitStep)

        stepCall='';
        stepCode='';
        stepCleanup={};
    else
        stepCall='% Compute observables.';
        stepCall=appendCode(stepCall,'args = runCalculateObservables(args);');


        stepCode=readTemplate('runCalculateObservables.txt');
        stepCleanup={};


        tableData=step.statistics;
        if iscell(tableData)
            tableData=[tableData{:}];
        end

        if~isempty(tableData)
            tableData=tableData([tableData.use]);
            tableData=tableData(cellfun('isempty',{tableData.matlabError}));

            if~isempty(tableData)
                obsCode='% Calculate observables.';
                for i=1:length(tableData)
                    name=tableData(i).name;
                    expression=tableData(i).expression;
                    obsCode=appendCode(obsCode,['data = addobservable(data, ''',name,''', ''',expression,''');']);
                end
                stepCode=strrep(stepCode,'$(OBSERVABLES)',obsCode);
            else
                stepCode=strrep(stepCode,'$(OBSERVABLES)','$(REMOVE)');
            end
        else
            stepCode=strrep(stepCode,'$(OBSERVABLES)','$(REMOVE)');
        end
    end

end

function[stepCall,stepCode,stepCleanup]=generateCustomCode(step)

    stepCode='% -------------------------------------------------------------------------';
    stepCode=appendCode(stepCode,step.customCode);
    stepCall='% Run simulation.';
    stepCall=appendCode(stepCall,'args = runCustom(args);');
    stepCleanup={};

end

function out=exportArguments(inputs,argList)

    expr=['exist(','''',inputs.varName,'''',')'];
    varAlreadyExist=evalin('base',expr);
    msg='';

    if(~varAlreadyExist||inputs.overwrite)

        warningID='MATLAB:namelengthmaxexceeded';
        originalWarning=warning('query',warningID);
        warning('off',warningID);


        assignin('base',inputs.varName,argList)


        warning(originalWarning.state,warningID);
    else
        msg=sprintf('Variable ''%s'' exists in the MATLAB workspace.',inputs.varName);
    end

    out.message=msg;

end

function step=getStepByType(steps,type)

    step=SimBiology.web.codegenerationutil('getStepByType',steps,type);

end

function index=getStepIndexByType(steps,type)

    index=SimBiology.web.codegenerationutil('getStepIndexByType',steps,type);

end

function value=logical2str(value)

    value=SimBiology.web.codegenerationutil('logical2str',value);

end

function[stepCode,stepCleanup]=generateStopAndOutputTimesCode(stepCode,step,configset)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateStopAndOutputTimesCode',stepCode,step,configset);

end

function[stepCode,stepCleanup]=generateStatesToLogCode(stepCode,step,steps)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateStatesToLogCode',stepCode,step,steps);

end

function[stepCode,stepCleanup]=generateSolverTypeCode(stepCode,step)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateSolverTypeCode',stepCode,step);

end

function[stepCode,stepCleanup]=generateLogDecimationCode(stepCode,step)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateLogDecimationCode',stepCode,step);

end

function[stepCode,stepCleanup]=generateTurnOffObservableCode(stepCode,step,model)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateTurnOffObservableCode',stepCode,step,model);

end

function[stepCode,stepCleanup]=generateTurnOnObservableCode(stepCode,step)

    [stepCode,stepCleanup]=SimBiology.web.commoncodegenerator('generateTurnOnObservableCode',stepCode,step);

end

function content=cleanupContent(content)

    content=SimBiology.web.codegenerationutil('cleanupContent',content);

end

function filename=createRunProgramMFile(code)

    filename=SimBiology.web.codegenerationutil('createRunProgramMFile',code);

end

function out=createCommaSeparatedQuotedList(value)

    out=SimBiology.web.codegenerationutil('createCommaSeparatedQuotedList',value);

end

function content=readTemplate(name)

    content=SimBiology.web.codegenerationutil('readTemplate',name);

end

function code=appendCode(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCode',code,newCode);

end

function code=appendCodeInLoop(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCodeInLoop',code,newCode);

end

function data=loadVariable(matfile,matfileVarName)

    if SimBiology.internal.variableExistsInMatFile(matfile,matfileVarName)
        data=load(matfile,matfileVarName);
        data=data.(matfileVarName);
    else
        data=[];
    end

end

function out=isRunAction(inputs)

    out=any(strcmp(inputs.action,{'run','runSection','runSectionAndAdvance'}));

end

function incrementScanRun()


    SimBiology.web.eventhandler('incrementScanRun');

end

function deleteFile(name)

    oldWarnState=warning('off','MATLAB:DELETE:Permission');
    cleanup=onCleanup(@()warning(oldWarnState));

    if exist(name,'file')
        oldState=recycle;
        recycle('off');
        delete(name)
        recycle(oldState);
    end

end

function restoreSensitivity(cs,sensInputs,sensOutputs)

    try
        set(cs.SolverOptions,'SensitivityAnalysis',true);
        set(cs.SensitivityAnalysisOptions,'Inputs',sensInputs);
        set(cs.SensitivityAnalysisOptions,'Outputs',sensOutputs);
    catch
    end

end
