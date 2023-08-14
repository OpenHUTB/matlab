function blockH=addSignalEditor(blkPath,harnessPath,sigProperties,left,top,width,height,model)







    fileName=matlab.lang.makeValidName(blkPath);
    if exist([fileName,'.mat'],'file')








        filename_postfix=1;
        while(exist(sprintf('%s_%d.mat',fileName,filename_postfix),'file'))
            filename_postfix=filename_postfix+1;
        end
        fileName=sprintf('%s_%d',fileName,filename_postfix);
    end
    fileName=[fileName,'.mat'];


    blockH=add_block('simulink/Sources/Signal Editor',blkPath);



    modelToGenerate='TmpModelForCreatingInportGroundValues';
    existing_models=find_system('type','block_diagram');

    modelToGenerate=matlab.lang.makeUniqueStrings(modelToGenerate,existing_models);
    try
        new_system(modelToGenerate,'FromTemplate','factory_default_model');
        Simulink.sta.editor.setModelLoggingParameters(model,modelToGenerate);


        ddFile=replicateSLDDLinkage(model,modelToGenerate);
        ocdd1=onCleanup(@()cleanupTempDDFile(ddFile));

        set_param(modelToGenerate,'Solver',get_param(model,'Solver'));

        modelWS=get_param(model,'modelworkspace');
        modelToGenerateWS=get_param(modelToGenerate,'modelworkspace');
        if~isempty(modelWS)&&~isempty(modelToGenerateWS)
            data=modelWS.data;
            for d=1:length(data)
                modelToGenerateWS.assignin(data(d).Name,data(d).Value);
            end
        end
    catch ME
        rethrow(ME);
    end

    if~bdIsLoaded(modelToGenerate)
        load_system(modelToGenerate);
    end
    ocm=onCleanup(@()bdclose(modelToGenerate));

    UNITS_WARN_STATE_PREV=warning('OFF','Simulink:Unit:UndefinedUnitUsage');
    ocw1=onCleanup(@()warning(UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsage'));
    DISALLOWED_UNITS_WARN_STATE_PREV=warning('OFF','Simulink:Unit:UndefinedUnitUsageInObj');
    ocw2=onCleanup(@()warning(DISALLOWED_UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsageInObj'));
    DID_ADD_PORT=false;


    for id=1:length(sigProperties)
        prop=sigProperties(id);

        inport_name=['In',num2str(id)];

        inport_name_full=[modelToGenerate,'/In',num2str(id)];
        inportHandle=add_block('built-in/Inport',inport_name_full);

        DID_ADD_PORT=true;


        outport_name=sprintf('%s/Out%d',modelToGenerate,id);
        outportHandle=add_block('built-in/Outport',outport_name);
        if isempty(prop.SampleTime)
            prop.SampleTime='[0,1]';
        end
        if isempty(prop.PortDimensions)
            prop.PortDimensions='-1';
        end
        if isempty(prop.OutDataTypeStr)
            prop.OutDataTypeStr='Inherit: auto';
        end
        if isempty(prop.Interpolate)
            prop.Interpolate='off';
        end
        if isempty(prop.SignalType)
            prop.SignalType='auto';
        end
        sigProperties(id)=prop;
        if contains(prop.OutDataTypeStr,'Bus:')
            set_param(outportHandle,'useBusObject','on',...
            'OutDataTypeStr',prop.OutDataTypeStr);

            set_param(inportHandle,'OutDataTypeStr',prop.OutDataTypeStr,...
            'BusOutputAsStruct','on',...
            'PortDimensions',prop.PortDimensions);
        else
            set_param(inportHandle,...
            'PortDimensions',prop.PortDimensions,...
            'Interpolate',prop.Interpolate,...
            'SignalType',prop.SignalType,...
            'OutDataTypeStr',prop.OutDataTypeStr);
        end

        start_point=[inport_name,'/1'];
        end_point=sprintf('Out%d/1',id);
        add_line(modelToGenerate,start_point,end_point);

    end

    try

        if DID_ADD_PORT
            InputScenario=createInputDataset(modelToGenerate);
        end
    catch ME_SIMULATE
        errMsg=MException('sl_sta:editor:errorGeneratingSimInput',...
        DAStudio.message('sl_sta:editor:errorGeneratingSimInput'));
        throw(errMsg);
    end


    r=Simulink.sdi.getCurrentSimulationRun(modelToGenerate,'',false);
    if~isempty(r)
        Simulink.sdi.deleteRun(r.id);
    end

    for id=1:numElements(InputScenario)
        prop=sigProperties(id);
        InputScenario{id}.Name=prop.Name;
    end

    if~isempty(harnessPath)
        harnessDir=dir(fileparts(harnessPath));
        fileDir=harnessDir(1).folder;
    else
        fileDir=pwd;
    end

    oldPath=path();
    pathcleanUp=onCleanup(@()path(oldPath));
    path(oldPath,fileDir);
    save(fullfile(fileDir,fileName),'InputScenario');
    set_param(blockH,'FileName',fileName);

    pos=[left,top,left+width-1,top+height-1];
    set_param(blockH,'Position',pos);

    for id=1:length(sigProperties)
        prop=sigProperties(id);
        set_param(blockH,'ActiveSignal',prop.Name);
        if contains(prop.SampleTime,'-1')
            isSampleTimeIndependent=strcmp(get_param(model,'SolverType'),'Fixed-step')&&...
            strcmp(get_param(model,'SampleTimeConstraint'),'STIndependent');
            if~isSampleTimeIndependent



                prop.SampleTime='0';
            end
        end
        if~strcmp(get_param(blockH,'SampleTime'),prop.SampleTime)

            set_param(blockH,'SampleTime',prop.SampleTime);
        end
        if contains(prop.OutDataTypeStr,'Bus:')
            set_param(blockH,'IsBus','on',...
            'OutputBusObjectStr',prop.OutDataTypeStr);
        end

    end

end

function ddFile=replicateSLDDLinkage(model,modelToGenerate)



    ddFile=[];
    if isempty(model)||~bdIsLoaded(model)
        return
    end

    allDataDicts=slprivate('getAllDataDictionaries',model);
    numDD=numel(allDataDicts);
    assert(numDD>=0)
    switch numDD
    case 0


        return;
    case 1

        set_param(modelToGenerate,'DataDictionary',allDataDicts{1});
    otherwise





        try
            ddFile=[tempname(pwd),'.sldd'];
            [~,fName,ext]=fileparts(ddFile);
            refDictionaryObj=Simulink.data.dictionary.create(ddFile);
            for idx=1:numDD
                refDictionaryObj.addDataSource(allDataDicts{idx})
            end
            saveChanges(refDictionaryObj)
            close(refDictionaryObj)
            set_param(modelToGenerate,'DataDictionary',[fName,ext]);
        catch ME
            fprintf(ME.message)
        end
    end
end

function cleanupTempDDFile(ddFile)
    if~isempty(ddFile)
        delete(ddFile)
    end
end