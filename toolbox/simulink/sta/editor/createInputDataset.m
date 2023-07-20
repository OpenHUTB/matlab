function ds=createInputDataset(model,varargin)


























    if nargin>0
        model=convertStringsToChars(model);
    end

    ds=Simulink.SimulationData.Dataset();

    origAutoSaveOptions=get_param(0,'AutoSaveOptions');
    oc1=onCleanup(@()set_param(0,'AutoSaveOptions',origAutoSaveOptions));


    s.SaveOnModelUpdate=0;
    set_param(0,'AutoSaveOptions',s);

    loggingFormat=[];

    if~isempty(varargin)

        p=inputParser;

        addParameter(p,'DatasetSignalFormat',[],@lValidatSignalFormat);
        parse(p,varargin{:});
        inputStruct=p.Results;

        if~isempty(inputStruct.DatasetSignalFormat)

            if isStringScalar(inputStruct.DatasetSignalFormat)
                inputStruct.DatasetSignalFormat=char(inputStruct.DatasetSignalFormat);
            end

            loggingFormat=inputStruct.DatasetSignalFormat;
        end
    end

    if~Simulink.iospecification.InportProperty.checkModelName(model)
        errMsg=MException('sl_sta:editor:modelNotOpen',...
        DAStudio.message('sl_sta:editor:modelNotOpen',model));
        throw(errMsg);

    end


    [allPortH,allPortNames]=getPortHandlesNames(model,false);

    isFCN_CALL=false(1,length(allPortH));
    isSampleTimeInherit=false(1,length(allPortH));

    if isempty(allPortH)
        errMsg=MException('sl_sta:editor:modelNoExternalInterface',...
        DAStudio.message('sl_sta:editor:modelNoExternalInterface',model));
        throw(errMsg);
    end


    compile=isCompileNeeded(allPortH,model);

    UNITS_WARN_STATE_PREV=warning('OFF','Simulink:Unit:UndefinedUnitUsage');
    ocw1=onCleanup(@()warning(UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsage'));



    modelToGenerate=Simulink.sta.editor.generateTempModel(model);
    if~bdIsLoaded(modelToGenerate)
        load_system(modelToGenerate);
    end
    ocm=onCleanup(@()bdclose(modelToGenerate));



    if compile

        warnMaxStepSize=warning('off','Simulink:Engine:UsingDefaultMaxStepSize');
        warnFixedStepSize=warning('off','Simulink:SampleTime:FixedStepSizeHeuristicWarn');
        warnTermDefer=warning('off','Simulink:Engine:SFcnAPITerminationDeferred');
        warnCompiled=warning('off','Simulink:Engine:ModelAlreadyCompiled');
        ocw2=onCleanup(@()warning(warnMaxStepSize.state,'Simulink:Engine:UsingDefaultMaxStepSize'));
        ocw3=onCleanup(@()warning(warnFixedStepSize.state,'Simulink:SampleTime:FixedStepSizeHeuristicWarn'));
        ocw4=onCleanup(@()warning(warnTermDefer.state,'Simulink:Engine:SFcnAPITerminationDeferred'));
        ocw5=onCleanup(@()warning(warnCompiled.state,'Simulink:Engine:ModelAlreadyCompiled'));


        cached_simmode=get(get_param(model,'handle'),'SimulationMode');
        if~strcmp(cached_simmode,'normal')

            set(get_param(model,'handle'),'SimulationMode','normal');

        end

        try

            feval(model,[],[],[],'compile');
            oc2=onCleanup(@()feval(model,[],[],[],'term'));
            ocw6=onCleanup(@()set(get_param(model,'handle'),'SimulationMode',cached_simmode));
        catch ME_Compile

            throw(ME_Compile);
        end
    end

    DID_ADD_PORT=false;

    inportFactory=Simulink.iospecification.InportFactory.getInstance();

    pluginArray=Simulink.iospecification.Inport.empty(0,length(allPortH));
    for inportIndex=1:length(allPortH)

        try
            aInportType=getInportType(inportFactory,allPortH(inportIndex));
        catch ME

            switch(ME.identifier)
            case 'sl_sta:editor:nonsupportinportcreateinds'
                DAStudio.error('sl_sta:editor:nonsupportinportcreateinds',getfullname(allPortH(inportIndex)));
            otherwise
                throw(ME);
            end
        end

        pluginArray(inportIndex)=aInportType;

    end


    for inportIndex=1:length(allPortH)
        [boolOut,err]=copyAndConnect(pluginArray(inportIndex),model,compile,[modelToGenerate,'/',get_param(pluginArray(inportIndex).Handle,'Name')],inportIndex);

        if~boolOut
            throwAsCaller(err);
        end

        if~isa(pluginArray(inportIndex),'Simulink.iospecification.FunctionCallPort')
            DID_ADD_PORT=true;
        end

    end



    originalModel=get_param(get(allPortH(1),'Parent'),'Handle');

    Simulink.sta.editor.setModelLoggingParameters(originalModel,modelToGenerate);


    try

        if DID_ADD_PORT

            if~isempty(loggingFormat)
                set_param(modelToGenerate,'DatasetSignalFormat',loggingFormat);
            end

            simOut=sim(modelToGenerate,'OutputSaveName','out');
        end
    catch ME_SIMULATE

        newMessage=strrep(ME_SIMULATE.message,modelToGenerate,model);

        ME=MSLException([ME_SIMULATE.handles{:}],'sl_sta:editor:errorGeneratingSimInput',newMessage);

        if~isempty(ME_SIMULATE.cause)
            ME.addCause(ME_SIMULATE.cause);
        end

        if~isempty(ME_SIMULATE.Correction)
            ME.addCorrection(ME_SIMULATE.Correction);
        end
        throw(ME);
    end


    r=Simulink.sdi.getCurrentSimulationRun(modelToGenerate,'',false);
    if~isempty(r)
        Simulink.sdi.deleteRun(r.id);
    end



    elCount=1;




    NUM_PLUGIN=length(pluginArray);

    portNums=cell(1,NUM_PLUGIN);
    for kPlugin=1:NUM_PLUGIN

        if isa(pluginArray(kPlugin),'Simulink.iospecification.EnablePort')
            portNums{kPlugin}='Enable';
        elseif isa(pluginArray(kPlugin),'Simulink.iospecification.TriggerPort')
            portNums{kPlugin}='TriggerPort';
        else
            portNums{kPlugin}=get_param(pluginArray(kPlugin).Handle,'Port');
        end
    end

    for k=1:length(pluginArray)


        if~isa(pluginArray(k),'Simulink.iospecification.FunctionCallPort')

            dsEl=simOut.get('out').get(elCount).Values;
            dsEl=setInterpolationValues(dsEl);

            ds=ds.addElement(dsEl,allPortNames{k});
            elCount=elCount+1;
        else








            if compile
                sampleInherit=get_param(pluginArray(k).Handle,'CompiledSampleTime');
                sampleInherit=sampleInherit(1);
            else
                sampleInherit=get_param(pluginArray(k).Handle,'SampleTime');
            end

            if isnumeric(sampleInherit)

                isSampleTimeInherit=sampleInherit==-1';
            else
                try
                    sampleVal=str2num(sampleInherit);
                catch ME

                    sampleVal=evalin('base',sampleInherit);
                end
                isSampleTimeInherit=false;
                if sampleVal==-1
                    isSampleTimeInherit=true;
                end
            end

            if isSampleTimeInherit
                ds=ds.addElement(0,allPortNames{k});
            else





                ds=ds.addElement([],allPortNames{k});
            end
        end

    end

    ds=Simulink.sta.editor.setInterpolationByDataType(ds);

end


function aBool=lValidatSignalFormat(inVar)

    if isStringScalar(inVar)
        inVar=char(inVar);
    end

    aBool=ischar(inVar)&&any(strcmpi({'timeseries','timetable'},inVar));

    if~aBool
        DAStudio.error('sl_sta:editor:signalformaterror');
    end

end