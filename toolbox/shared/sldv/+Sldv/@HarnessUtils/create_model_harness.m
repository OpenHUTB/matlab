function[harnessH,outputHarnessSource,testSubsysH]=create_model_harness(objH,harnessFilePath,...
    time,data,groups,...
    sldvData,modelRefHarness,...
    fundts,reconsParams,...
    posShift,outputPosShift,...
    fromMdlFlag,mode,harnessOpts,...
    existHarnMdlH,harnessSource)




    harnessH=[];
    outputHarnessSource=[];
    testSubsysH=[];

    if~isempty(existHarnMdlH)
        harnessH=existHarnMdlH;
        outputHarnessSource=harnessSource;
        appendMode=true;
    else
        appendMode=false;
    end

    if isa(harnessSource,'Sldv.harnesssource.SignalBuilder')...
        ||isa(harnessSource,'Sldv.harnesssource.TestSequence')||isempty(harnessSource)
        [flatSLDVData,inputSignalNames,outputSignalNames,inputSignalComplexity]=flatDataForHarness(data,sldvData,harnessOpts);
    end

    if appendMode
        if isa(harnessSource,'Sldv.harnesssource.SignalBuilder')
            signalbuilder(harnessSource.blockH,'append',time,flatSLDVData,inputSignalNames,groups);
        elseif isa(harnessSource,'Sldv.harnesssource.SignalEditor')
            usedSignals='';
            harnessSource.addTestcases(sldvData,appendMode,usedSignals);
        else

        end
        curStopTime=get_param(harnessH,'StopTime');
        setSimulationStopTimeOnHarnessModel(str2double(curStopTime));
        return;
    end

    [~,harnessName]=fileparts(harnessFilePath);


    isXIL=Sldv.DataUtils.isXilSldvData(sldvData);

    srcModelH=objH;


    testunitName=getfullname(srcModelH);

    testSubsysName=deriveTestUnitName;




    obsMdlNames=Simulink.observer.internal.getObserverModelNamesInBD(srcModelH);

    if slfeature('UnifiedMakeHarness')
        if harnessOpts.usedSignalsOnly
            sldvData=Sldv.DataUtils.addMinMaxToInputs(objH,sldvData,true);
        end
        DVData.sldvData=sldvData;
        DVData.harnessOpts=harnessOpts;
        DVData.modelRefHarness=modelRefHarness;
        DVData.harnessFromMdl=fromMdlFlag;
        [harnessH,outputHarnessSource,testSubsysH]=Simulink.harness.internal.makeHarness(objH,harnessName,harnessFilePath,DVData);

        configureTestSubsystemUnit;
    else
        if~modelRefHarness&&~isempty(obsMdlNames)&&isequal(slfeature('ObserverSLDV'),1)
            [~,~,ext]=fileparts(harnessFilePath);
            slInternal(['snapshot_',ext(2:end)],get_param(srcModelH,'Name'),harnessFilePath);
            Sldv.load_system_no_callbacks(harnessFilePath);
        else
            Sldv.new_system(harnessName,'Model');
        end

        harnessH=get_param(harnessName,'Handle');





        param1Name='TestUnitModel';
        param1Value=get_param(objH,'Name');

        modelParam=sprintf('%s=%s|',param1Name,param1Value);
        add_param(harnessH,'SldvGeneratedHarnessModel',modelParam);


        fontName=get_param(objH,'DefaultBlockFontName');
        set_param(harnessH,'DefaultBlockFontName',fontName);



        [harnessMaxX,harnessMaxY]=deriveHarnessModelLocation;

        fundamentalSampleTime=fundts;

        srcName=getfullname(srcModelH);

        [outportBlkHandles,outportBlkNames]=getConsolidatedSourceModelOutportBlocks;

        testSubsysH=constructTestSubsystemUnit;


        configureTestSubsystemUnit;


        [height,width,left,top]=setPositionTestSubsys;

        if harnessOpts.xilModelWrapperOnly
            createInPortsForXilModelUnderTest;
        else
            switch(harnessOpts.harnessSource)
            case 'Signal Builder'

                outputHarnessSource=constructSigBuilderBlock;
            case 'Signal Editor'

                outputHarnessSource=constructSigEditorBlock(sldvData);
            case 'Test Sequence'

                testSequenceData.dataValues=flatSLDVData;
                testSequenceData.timeStep=time;
                testSequenceData.inputSignalNames=inputSignalNames;
                testSequenceData.inputSignalComplexity=inputSignalComplexity;
                testSequenceData.Mode=sldvData.AnalysisInformation.Options.Mode;
                outputHarnessSource=constructTestSequenceBlock(testSequenceData);
            otherwise
                createInPortsForHarness;
            end
        end
        if strcmp(harnessOpts.harnessSource,'Signal Editor')
            if~isempty(outputHarnessSource)
                sige_sig_count=0;
                numOfInputs=length(sldvData.AnalysisInformation.InputPortInfo);
                for id=1:numOfInputs
                    portInfo=sldvData.AnalysisInformation.InputPortInfo{id};
                    if iscell(portInfo)




                        sldv_data_with_compiledbustype=isfield(portInfo{1,1},'CompiledBusType')&&...
                        strcmp(portInfo{1,1}.CompiledBusType,'NON_VIRTUAL_BUS');
                        sldv_data_with_isvirtualbus=isfield(portInfo{1,1},'IsVirtualBus')&&...
                        ~portInfo{1,1}.IsVirtualBus;
                        isNonVirtualBus=sldv_data_with_compiledbustype||...
                        sldv_data_with_isvirtualbus;
                        if isNonVirtualBus
                            sige_sig_count=sige_sig_count+1;
                            set_param(outputHarnessSource,'ActiveSignal',sige_sig_count);
                            BusObjectName=portInfo{1,1}.BusObject;
                            SampleTimeStr='-1';
                            if isfield(portInfo{1,1},'SampleTimeStr')
                                SampleTimeStr=portInfo{1,1}.SampleTimeStr;
                            end
                            set_param(outputHarnessSource,'IsBus','on',...
                            'OutputBusObjectStr',['Bus: ',BusObjectName],...
                            'SampleTime',SampleTimeStr);
                        end
                    elseif portInfo.Used==1
                        sige_sig_count=sige_sig_count+1;
                        set_param(outputHarnessSource,'ActiveSignal',sige_sig_count);
                        set_param(outputHarnessSource,'SampleTime',portInfo.SampleTimeStr,...
                        'OutputAfterFinalValue','Holding final value');
                    else


                    end
                end
            end
            if harnessOpts.createReshapeOutputsSubsystem
                outReshapeSubSysH=constructOutputReshapeAndCastSubsystem;%#ok<NASGU>
            else
                createOutPortsForTestSubsystem;
            end

        else
            if~harnessOpts.xilModelWrapperOnly
                subSysH=constructReshapeAndCastSubsystem;
            end

            if harnessOpts.createReshapeOutputsSubsystem
                outReshapeSubSysH=constructOutputReshapeAndCastSubsystem;%#ok<NASGU>
            else
                createOutPortsForTestSubsystem;
            end

            if strcmp(harnessOpts.harnessSource,'Signal Builder')||strcmp(harnessOpts.harnessSource,'Test Sequence')

                align_top_bottom(testSubsysH,outputHarnessSource,subSysH);
            end

            if~harnessOpts.xilModelWrapperOnly
                adj_dest_2_v_align_ports(subSysH,testSubsysH);
            end
        end
        resizeHarness;

        setTestSubsystemReadOnly;

    end


    Sldv.utils.copyConfigSet(srcModelH,harnessH);
    modelWorkspaceUtils=Simulink.ModelReference.Conversion.ModelWorkspaceUtils(srcModelH,harnessH);
    modelWorkspaceUtils.copy;


    Sldv.utils.copySfTargetsDebugSettings(srcModelH,harnessH);



    Sldv.utils.configureSourceAndHarnessModelCoverage(srcModelH,harnessH,...
    fromMdlFlag,modelRefHarness,sldvData.AnalysisInformation.Options,testSubsysName);

    if~fromMdlFlag
        if strcmpi(sldvData.AnalysisInformation.Options.CovFilter,'on')
            if isfield(sldvData.ModelInformation,'ExtractedModel')&&~isempty(sldvData.ModelInformation.ExtractedModel)
                CovFilterFile=get_param(srcModelH,'DVCovFilterFileName');
            else
                CovFilterFile=sldvData.AnalysisInformation.Options.CovFilterFileName;
            end
            setCovFilter(CovFilterFile);
        end
    else
        setCovFilter(get_param(srcModelH,'CovFilter'));
    end
    opts={'SearchDepth',1};
    aBlks=find_system(srcModelH,opts{:});
    aBlks(1)=[];
    outportHandles=aBlks(strcmp(get_param(aBlks,'BlockType'),'Outport'));
    compositeInpHandles=strcmp(get_param(outportHandles,'IsBusElementPort'),'on');
    srcHasRootLvlOutBEP=any(compositeInpHandles);
    Sldv.utils.configureInportExportFormatOnHarnessModel(srcModelH,harnessH,srcHasRootLvlOutBEP);
    Sldv.utils.setSharedAttributesWithSldvruntest(harnessH,fromMdlFlag,modelRefHarness,fundts);
    if~fromMdlFlag
        setSimulationStopTimeOnHarnessModel(0.0);
    end


    if strcmpi(sldvData.AnalysisInformation.Options.DetectDSMAccessViolations,'on')
        set_param(harnessH,'ReadBeforeWriteMsg','EnableAllAsWarning');
        set_param(harnessH,'WriteAfterWriteMsg','EnableAllAsWarning');
        set_param(harnessH,'WriteAfterReadMsg','EnableAllAsWarning');
    end



    function[harnessMaxX,harnessMaxY]=deriveHarnessModelLocation
        originalLoc=get_param(harnessName,'Location');
        harnessMaxX=originalLoc(3)-originalLoc(1);
        harnessMaxY=originalLoc(4)-originalLoc(2);
    end

    function[inportBlks,inportNames]=getSourceModelInportBlocks
        inportBlks=find_system(srcModelH,'SearchDepth',1,'BlockType','Inport');
        inportNames=get_param(inportBlks,'Name');
        if~iscell(inportNames)
            inportNames={inportNames};
        end
    end

    function[outportBlkHandles,outportNames]=getConsolidatedSourceModelOutportBlocks











        nonConsolidatedoutportBlks=find_system(srcModelH,'SearchDepth',1,'BlockType','Outport');

        testSubsysOutPortsH=unique(str2double(get_param(nonConsolidatedoutportBlks,'Port')));
        if isempty(testSubsysOutPortsH)
            outportBlkHandles=[];
            outportNames={};
            return;
        end
        outportBlkHandles(length(testSubsysOutPortsH))=0;
        outportNames=cell(1,length(testSubsysOutPortsH));



        for idx=1:length(nonConsolidatedoutportBlks)
            portHandle=str2double(get_param(nonConsolidatedoutportBlks(idx),'Port'));
            if~(outportBlkHandles(portHandle)>0)
                outportBlkHandles(portHandle)=nonConsolidatedoutportBlks(idx);
                if(strcmp(get_param(nonConsolidatedoutportBlks(idx),'IsBusElementPort'),'on'))
                    outportNames{portHandle}=get_param(nonConsolidatedoutportBlks(idx),'PortName');
                else

                    outportNames{portHandle}=get_param(nonConsolidatedoutportBlks(idx),'Name');
                end
            end
        end
        if~iscell(outportNames)
            outportNames={outportNames};
        end
    end

    function testSubsysName=deriveTestUnitName()
        if modelRefHarness
            unitName='Test_Unit';
        else
            unitName=['Test_Unit (copied from ',testunitName,')'];
        end
        testSubsysName=[harnessName,'/',unitName];
    end

    function configureTestSubsystemUnit
        if modelRefHarness
            if isXIL&&~Sldv.DataUtils.isBDExtractedModel(sldvData)





                if Sldv.utils.Options.isTestgenTargetForCode(sldvData.AnalysisInformation.Options)
                    codeIf='Top model';
                else
                    codeIf='Model reference';
                end
                simMode=SlCov.CovMode.toSimulationMode('SIL');
                set_param(testSubsysH,...
                'SimulationMode',simMode,...
                'CodeInterface',codeIf);
            else
                set_param(testSubsysH,'SimulationMode','Normal');

            end




            mdl_Ref=find_mdlrefs(testSubsysH,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

            load_system(mdl_Ref);
            for idx=1:numel(mdl_Ref)
                Simulink.ModelReference.Conversion.ModelWorkspaceUtils.setupInstanceParameterValuesOnModelBlocks(mdl_Ref{1},testSubsysName);
            end
        else

        end
    end

    function deleteInpAndOutAtRootLvl(rootLvlH)

        assert(srcModelH~=rootLvlH);

        harnessIns=find_system(rootLvlH,'searchdepth',1,'BlockType','Inport');
        for idx=1:numel(harnessIns)
            inpName=harnessIns(idx);
            delete_block(inpName);
        end


        harnessOuts=find_system(rootLvlH,'searchdepth',1,'BlockType','Outport');
        for idx=1:numel(harnessOuts)
            outName=harnessOuts(idx);
            delete_block(outName);
        end

        delete_line(find_system(get_param(rootLvlH,'name'),...
        'searchdepth',1,'FindAll','on','Type','line','Connected','off'));
    end

    function cacheMdlToObsPortEntityMapping(modelH,mdlObsEntityAndPortInfos)




        obsModelHs=Simulink.observer.internal.getObserverModelsForBD(modelH);

        for obsMdlNo=1:numel(obsModelHs)
            obsPortHs=Simulink.observer.internal.getObserverPortsInsideObserverModel(obsModelHs(obsMdlNo));

            for obsPortNo=1:numel(obsPortHs)




                currObsPortH=obsPortHs(obsPortNo);
                currObsPath=getfullname(currObsPortH);
                obsEntityFullSpec=Simulink.observer.internal.getObservedEntity(currObsPortH);
                obsEntitySplitSpec=string(split(obsEntityFullSpec,'|'));

                obsEntityInfo.fullname=getfullname(obsEntitySplitSpec(2));




                if strcmp(get_param(obsEntityInfo.fullname,'BlockType'),'Inport')
                    obsEntityInfo.type=Simulink.observer.internal.getObservedEntityType(currObsPortH);
                    obsEntityInfo.portID=str2double(obsEntitySplitSpec(end));

                    mdlObsEntityAndPortInfos(currObsPath)=obsEntityInfo;
                end
            end
        end
    end

    function reconfigureObsPortMappings(mdlObsEntityAndPortInfos,rootInpToSubsysInpMap)


        for k=keys(mdlObsEntityAndPortInfos)
            obsPortPath=k{1};
            obsPortHandle=getSimulinkBlockHandle(obsPortPath);

            if rootInpToSubsysInpMap.isKey(mdlObsEntityAndPortInfos(obsPortPath).fullname)
                newObsEntityPath=rootInpToSubsysInpMap(mdlObsEntityAndPortInfos(obsPortPath).fullname);
                newObsEntityH=getSimulinkBlockHandle(newObsEntityPath);

                Simulink.observer.internal.configureObserverPort(obsPortHandle,...
                mdlObsEntityAndPortInfos(obsPortPath).type,newObsEntityH,mdlObsEntityAndPortInfos(obsPortPath).portID);
            end
        end
    end

    function cacheRootInpToSubsysInp(modelH,subsysName,rootInpToSubsysInpMap)
        inpPortsInMdl=find_system(modelH,'searchdepth',1,'BlockType','Inport');

        for inpIdx=1:numel(inpPortsInMdl)

            inpElemPath=getfullname(inpPortsInMdl(inpIdx));



            [mdlName,elemName]=fileparts(inpElemPath);




            subsysInpPath=[mdlName,'/',subsysName,'/',elemName];

            rootInpToSubsysInpMap(inpElemPath)=subsysInpPath;
        end
    end

    function testSubsysH=constructTestSubsystemUnit
        if modelRefHarness
            add_block('built-in/ModelReference',testSubsysName);
            testSubsysH=get_param(testSubsysName,'Handle');
            set_param(testSubsysH,'ModelName',testunitName);
        elseif~modelRefHarness&&~isempty(obsMdlNames)&&isequal(slfeature('ObserverSLDV'),1)

            obsModelHs=Simulink.observer.internal.getObserverModelsForBD(harnessH);
            load_system(obsModelHs);


            Sldv.utils.switchObsMdlsToStandaloneMode(srcModelH);
            standaloneMode=false;
            Simulink.observer.internal.loadObserverModelsForBD(harnessH,standaloneMode);


            [~,testsubsysBlkName]=fileparts(testSubsysName);

            mdlObsEntityAndPortInfos=containers.Map('KeyType','char','ValueType','any');
            rootInpToSubsysInpMap=containers.Map('KeyType','char','ValueType','char');





            cacheMdlToObsPortEntityMapping(harnessH,mdlObsEntityAndPortInfos);






            blkFilter=Simulink.FindOptions('MatchFilter',@Sldv.utils.findObsBlks,'SearchDepth',1);
            blks=Simulink.findBlocks(harnessName,blkFilter);
            Simulink.BlockDiagram.createSubsystem(blks);



            newSubsys=find_system(harnessH,'SearchDepth',1,'BlockType','SubSystem');

            set_param(getfullname(newSubsys),'Name',testsubsysBlkName);




            cacheRootInpToSubsysInp(harnessH,testsubsysBlkName,rootInpToSubsysInpMap);



            deleteInpAndOutAtRootLvl(harnessH);

            if~isempty(mdlObsEntityAndPortInfos)
                reconfigureObsPortMappings(mdlObsEntityAndPortInfos,rootInpToSubsysInpMap);
            end

            testSubsysH=get_param(testSubsysName,'Handle');
        else
            set_param(harnessH,'SIDAllowCopied','on');
            set_param(harnessH,'SIDNewHighWatermark',...
            get_param(srcModelH,'SIDHighWatermark'));
            add_block('built-in/SubSystem',testSubsysName);
            testSubsysH=get_param(testSubsysName,'Handle');



            Simulink.BlockDiagram.copyContentsToSubSystem(srcModelH,testSubsysH);
            set_param(harnessH,'SIDAllowCopied','off');
        end
    end

    function[height,width,left,top]=setPositionTestSubsys
        portHandles=get_param(testSubsysH,'PortHandles');
        if harnessOpts.xilModelWrapperOnly
            rowCnt=length(portHandles.Inport);
        else
            [rowCnt,~]=size(flatSLDVData);
        end
        outCnt=length(portHandles.Outport);
        height=20+20*max(rowCnt,outCnt);
        width=160;
        left=350;
        top=50;
        pos=[left,top,left+width,top+height];
        set_param(testSubsysH,'Position',range_check_position(pos));
    end

    function setCovFilter(filterFileName)
        if~isempty(filterFileName)
            if~modelRefHarness
                newFilterFileName=SlCov.FilterEditor.convertCovFilter(filterFileName,...
                srcModelH,testSubsysH,'_covfilter',...
                fileparts(harnessFilePath));
            else
                newFilterFileName=filterFileName;
            end
            set_param(harnessH,'CovFilter',newFilterFileName);
        end
    end

    function setSimulationStopTimeOnHarnessModel(minStopTime)


        stopTime=minStopTime;
        for test_time_set=time(:)'
            stopTime=max(stopTime,max(test_time_set{:}));
        end
        set_param(harnessH,'StopTime',sldvshareprivate('util_double2str',stopTime));


        set_param(harnessH,'StartTime','0');
    end

    function sigbH=constructSigBuilderBlock
        if~isempty(flatSLDVData)
            sigbName='Inputs';
            sigbpath=[harnessName,'/',sigbName];
            left=50;
            pos=[left,top,left+width,top+height];
            [m,n]=size(flatSLDVData);
            for idx=1:m
                for inneridx=1:n
                    flatSLDVData{idx,inneridx}=double(flatSLDVData{idx,inneridx});
                end
            end
            signalbuilder(sigbpath,'create',time,flatSLDVData,inputSignalNames,groups,[],pos);
            sigbH=get_param(sigbpath,'Handle');
        else
            sigbH=[];
        end
    end

    function sigEH=constructSigEditorBlock(sldvData)










        foundUsedSignals=false;
        sigEH=[];
        numOfInputs=length(sldvData.AnalysisInformation.InputPortInfo);
        for idx=1:numOfInputs
            if iscell(sldvData.AnalysisInformation.InputPortInfo{idx})

                foundUsedSignals=true;
                break;
            elseif isstruct(sldvData.AnalysisInformation.InputPortInfo{idx})&&...
                isfield(sldvData.AnalysisInformation.InputPortInfo{idx},'Used')&&...
                sldvData.AnalysisInformation.InputPortInfo{idx}.Used
                foundUsedSignals=true;
                break;
            else
                continue;
            end
        end


        left=50;
        pos=[left,top,left+width,top+height];

        if foundUsedSignals




            baseFileName=matlab.lang.makeValidName([harnessName,'_HarnessInputs']);
            harnessFileDir=fileparts(harnessFilePath);
            if isempty(harnessFileDir)
                harnessFileDir=pwd;
            end
            fullfileName=fullfile(harnessFileDir,[baseFileName,'.mat']);
            filename_postfix=0;
            while exist(fullfileName,'file')


                filename_postfix=filename_postfix+1;
                fileName=sprintf('%s_%d',baseFileName,filename_postfix);
                fullfileName=fullfile(harnessFileDir,[fileName,'.mat']);
            end
            ds=Simulink.SimulationData.Dataset;
            ds{1}=timeseries(1:10);
            scenario_base=Sldv.harnesssource.Source.getTestCasePrefix(sldvData.AnalysisInformation.Options.Mode);
            scenario_name=sprintf('%s_%d',scenario_base,1);
            saveStruct.(scenario_name)=ds;
            save(fullfileName,'-struct','saveStruct');
            sigEName='Inputs';
            sigepath=[harnessName,'/',sigEName];

            add_block('SignalEditorBlockLib/Signal Editor',sigepath,'FileName',fullfileName);
            [harnessSource,errorMsg]=Sldv.harnesssource.Source.getSource(harnessName);
            if isempty(errorMsg)
                appendModeSE=false;
                usedSignalsSE={};
                usedSignalsSE=Simulink.harness.internal.populateUsedSignals(sldvData.AnalysisInformation.InputPortInfo,usedSignalsSE);
                usedSignalsSE=usedSignalsSE{:};
                harnessSource.addTestcases(sldvData,appendModeSE,usedSignalsSE);
            end
            set_param(sigepath,'Position',pos);
            sigEH=getSimulinkBlockHandle(sigepath);
        end



        subSysH=add_block('built-in/SubSystem',[harnessName,'/','Size-Type'],...
        'NamePlacement','Alternate');
        left=270;
        pos=[left,top,left+20,top+height];
        set_param(subSysH,'Position',range_check_position(pos));
        set_param(subSysH,'BackgroundColor','black');


        inputs=sldvData.AnalysisInformation.InputPortInfo;
        for idx=1:length(inputs)
            signalConversionH=[];
            if isstruct(sldvData.AnalysisInformation.InputPortInfo{idx})&&...
                sldvData.AnalysisInformation.InputPortInfo{idx}.Used==0


                sldvData=Sldv.DataUtils.addMinMaxToInputs(objH,sldvData,true);
                [isEnum,className]=sldvshareprivate('util_is_enum_type',...
                sldvData.AnalysisInformation.InputPortInfo{idx}.DataType);
                [~,dataTypeStr]=getDataTypeParam(sldvData.AnalysisInformation.InputPortInfo{idx}.DataType,...
                mode,objH);
                if isfield(sldvData.AnalysisInformation.InputPortInfo{idx},'Min')
                    const_value=sldvData.AnalysisInformation.InputPortInfo{idx}.Min;
                elseif isfield(sldvData.AnalysisInformation.InputPortInfo{idx},'Max')
                    const_value=sldvData.AnalysisInformation.InputPortInfo{idx}.Max;
                else
                    const_value=[];
                end
                if strcmp(const_value,'[]')



                    if isEnum
                        sedata=sldvshareprivate('util_get_enum_defaultvalue',className);
                        const_value=sprintf('%s(%d)',className,int32(sedata));
                    else
                        const_value='0';
                    end
                end
                dimension=sldvData.AnalysisInformation.InputPortInfo{idx}.Dimensions;
                if any(dimension~=1)
                    if isscalar(dimension)
                        dimension(end+1)=1;%#ok<AGROW>
                    end
                    const_value=sprintf('repmat(%d,%s)',const_value,mat2str(dimension));
                end
                inH=add_block('built-in/Constant',...
                [getfullname(subSysH),'/','In1'],'MakeNameUnique','On',...
                'Value',const_value,...
                'OutDataTypeStr',dataTypeStr);

            else

                inH=add_block('built-in/Inport',...
                [getfullname(subSysH),'/','In1'],'MakeNameUnique','On');



                if iscell(sldvData.AnalysisInformation.InputPortInfo{idx})&&...
                    isfield(sldvData.AnalysisInformation.InputPortInfo{idx}{1},'IsVirtualBus')&&...
                    sldvData.AnalysisInformation.InputPortInfo{idx}{1}.IsVirtualBus
                    signalConversionH=add_block('simulink/Signal Attributes/Signal Conversion',...
                    [getfullname(subSysH),'/','SignalConversion'],'MakeNameUnique','On',...
                    'ConversionOutput','Virtual bus');
                end
            end

            blockTop=reconsParams.winBufferV+((idx-1-posShift(idx).prevCount)*(reconsParams.inportHeight+reconsParams.inportVertSep));
            blockPos=[reconsParams.winBufferH+posShift(idx).column...
            ,blockTop...
            ,reconsParams.winBufferH+posShift(idx).column+reconsParams.inportWidth...
            ,blockTop+reconsParams.inportHeight];
            set_param(inH,'Position',blockPos);

            distanceBetweenInportAndOutport=150;


            if~isempty(signalConversionH)
                sigConvBlockPos=blockPos;
                sigConvBlockWidth=reconsParams.inportWidth;
                sigConvBlockPos(1)=sigConvBlockPos(1)+...
                distanceBetweenInportAndOutport/2;
                sigConvBlockPos(3)=sigConvBlockPos(1)+sigConvBlockWidth;
                set_param(signalConversionH,'Position',sigConvBlockPos);
            end


            outBlockPos=blockPos;
            outBlockPos(1)=outBlockPos(1)+distanceBetweenInportAndOutport;
            outBlockPos(3)=outBlockPos(1)+reconsParams.inportWidth;
            outH=add_block('built-in/Outport',...
            sprintf('%s/Out%d',getfullname(subSysH),idx),'Position',...
            outBlockPos);


            if isempty(signalConversionH)


                inPH=get_param(inH,'PortHandles');
                outPH=get_param(outH,'PortHandles');
                add_line(subSysH,inPH.Outport(1),outPH.Inport(1));
            else


                inPH=get_param(inH,'PortHandles');
                sigPH=get_param(signalConversionH,'PortHandles');
                outPH=get_param(outH,'PortHandles');
                add_line(subSysH,inPH.Outport(1),sigPH.Inport(1));
                add_line(subSysH,sigPH.Outport(1),outPH.Inport(1));
            end
        end


        subSysPortH=get_param(subSysH,'PortHandles');
        if foundUsedSignals
            sigEPortH=get_param(sigepath,'PortHandles');
            for outIdx=1:length(sigEPortH.Outport)
                add_line(harnessH,sigEPortH.Outport(outIdx),subSysPortH.Inport(outIdx));
            end
        end
        testSubsysPortH=get_param(testSubsysH,'PortHandles');
        for outIdx=1:length(subSysPortH.Outport)
            add_line(harnessH,subSysPortH.Outport(outIdx),testSubsysPortH.Inport(outIdx));
        end



        set_param(sigEH,'PreserveSignalName','off');
    end

    function tstSeqH=constructTestSequenceBlock(testSequenceData)



        numOfInputs=length(testSequenceData.inputSignalNames);
        left=50;
        pos=[left,top,left+width,top+height];

        tstSeqName='Inputs';
        tstseqpath=[harnessName,'/',tstSeqName];
        add_block('sltestlib/Test Sequence',tstseqpath);
        [harnessSource,errorMsg]=Sldv.harnesssource.Source.getSource(harnessName);
        if isempty(errorMsg)
            harnessSource.addTestcases(testSequenceData,false,{});
        end
        set_param(tstseqpath,'Position',pos);
        tstSeqH=getSimulinkBlockHandle(tstseqpath);
    end

    function subSysH=constructReshapeAndCastSubsystem
        subSysH=add_block('built-in/SubSystem',[harnessName,'/','Size-Type'],...
        'NamePlacement','Alternate');
        left=270;
        pos=[left,top,left+20,top+height];
        set_param(subSysH,'Position',range_check_position(pos));
        set_param(subSysH,'BackgroundColor','black');

        if harnessOpts.usedSignalsOnly
            sldvData=Sldv.DataUtils.addMinMaxToInputs(objH,sldvData,true);
        end
        isBDExtractedModel=Sldv.DataUtils.isBDExtractedModel(sldvData);
        [outSignalCnt,compiledSignalInfo]=busElementLength(sldvData.AnalysisInformation.InputPortInfo,harnessOpts);

        inportInfo=sldvData.AnalysisInformation.InputPortInfo;
        inPortIdx=1;
        sigbOutPortIdx=1;
        sigOffset=0;
        outCnt=length(outSignalCnt);

        for outIdx=1:outCnt
            isBus=outSignalCnt(outIdx)~=-1;

            sigCnt=abs(outSignalCnt(outIdx));
            sigPort=zeros(1,sigCnt);

            for sigIdx=1:sigCnt
                cumSigIdx=sigIdx+sigOffset;

                numOfInps=prod(compiledSignalInfo{cumSigIdx}.Dimensions);
                isUsed.flag=compiledSignalInfo{cumSigIdx}.Used;

                temp='[]';
                if isfield(compiledSignalInfo{cumSigIdx},'Min')
                    temp=compiledSignalInfo{cumSigIdx}.Min;
                elseif isfield(compiledSignalInfo{cumSigIdx},'Max')
                    temp=compiledSignalInfo{cumSigIdx}.Max;
                end
                isUsed.ConstBlkVal=temp;

                if numOfInps>1
                    [muxOutPort,inPortIdx,sigbOutPortIdx]=addInportAndMux(numOfInps,isUsed,inPortIdx,sigbOutPortIdx,...
                    cumSigIdx,subSysH,outIdx,...
                    compiledSignalInfo{cumSigIdx}.DataType);
                    reshapeOutPort=addReshape(muxOutPort,compiledSignalInfo{cumSigIdx}.Dimensions,cumSigIdx,subSysH,outIdx);
                    sigPort(sigIdx)=addCastAndRateTrans(reshapeOutPort,cumSigIdx,compiledSignalInfo{cumSigIdx},...
                    subSysH,outIdx,isBDExtractedModel);
                else
                    [outPort,inPortIdx,sigbOutPortIdx]=addInPort(inPortIdx,sigbOutPortIdx,isUsed,subSysH,outIdx,...
                    compiledSignalInfo{cumSigIdx}.DataType);
                    sigPort(sigIdx)=addCastAndRateTrans(outPort,cumSigIdx,compiledSignalInfo{cumSigIdx},...
                    subSysH,outIdx,isBDExtractedModel);
                end
            end


            if isBus
                isRootInportNonVirtual=~inportInfo{outIdx}{1}.IsVirtualBus;

                busCreatePos=[reconsParams.busCreateLeft+posShift(outIdx).column...
                ,reconsParams.busTopV...
                ,reconsParams.busCreateLeft+posShift(outIdx).column+reconsParams.busCreateWidth...
                ,reconsParams.busBottomV];

                busCreatePath=[getfullname(subSysH),'/Bus',num2str(outIdx)];
                busCreateSysH=add_block('built-in/SubSystem',busCreatePath,'Position',range_check_position(busCreatePos));


                Sldv.HarnessUtils.build_bus_hierarchy(busCreateSysH,inportInfo{outIdx},isRootInportNonVirtual,false,harnessOpts);


                busSubSysPorts=get_param(busCreateSysH,'PortHandles');

                for sigIdx=1:sigCnt
                    add_line(subSysH,sigPort(sigIdx),busSubSysPorts.Inport(sigIdx),'autorouting','off');
                end


                portHorzAlign(busCreateSysH,true);
                lastOutPort=busSubSysPorts.Outport(1);
            else
                lastOutPort=sigPort;
            end


            portPos=get_param(lastOutPort,'Position');
            blockPos=[reconsParams.outportLeft+posShift(outIdx).column...
            ,portPos(2)-0.5*reconsParams.inportHeight...
            ,reconsParams.outportLeft+posShift(outIdx).column+reconsParams.inportWidth...
            ,portPos(2)+0.5*reconsParams.inportHeight];

            outH=add_block('built-in/Outport',[getfullname(subSysH),'/','Out',num2str(outIdx)],...
            'Position',range_check_position(blockPos));

            outPortH=get_param(outH,'PortHandles');
            add_line(subSysH,lastOutPort,outPortH.Inport);

            testSubsysPortH=get_param(testSubsysH,'PortHandles');
            subSysPortH=get_param(subSysH,'PortHandles');
            add_line(harnessH,subSysPortH.Outport(outIdx),testSubsysPortH.Inport(outIdx));

            if harnessOpts.logInputsAndOutputs
                if isBus



                    if inportInfo{outIdx}{1}.hasArrayOfBuses
                        busSubSysPorts=find_system(busCreateSysH,'SearchDepth',1,'BlockType','Inport');
                        for sigIdx=1:length(sigPort)
                            set_param(sigPort(sigIdx),'DataLogging','on');
                            set_param(sigPort(sigIdx),'DataLoggingNameMode','SignalName');
                            set_param(sigPort(sigIdx),'DataLoggingDecimateData','off');
                            set_param(sigPort(sigIdx),'DataLoggingLimitDataPoints','off');
                            if isempty(get_param(sigPort(sigIdx),'Name'))
                                portName=get_param(busSubSysPorts(sigIdx),'Name');
                                set_param(sigPort(sigIdx),'Name',portName);
                            end
                        end
                    else
                        set_param(subSysPortH.Outport(outIdx),'DataLogging','on');
                        set_param(subSysPortH.Outport(outIdx),'DataLoggingNameMode','SignalName');
                        if isempty(get_param(subSysPortH.Outport(outIdx),'Name'))
                            set_param(subSysPortH.Outport(outIdx),'Name',inportInfo{outIdx}{1}.SignalPath);
                        end
                        set_param(subSysPortH.Outport(outIdx),'DataLoggingDecimateData','off');
                        set_param(subSysPortH.Outport(outIdx),'DataLoggingLimitDataPoints','off');
                    end
                else
                    set_param(subSysPortH.Outport(outIdx),'DataLogging','on');
                    set_param(subSysPortH.Outport(outIdx),'DataLoggingNameMode','SignalName');
                    if isempty(get_param(subSysPortH.Outport(outIdx),'Name'))
                        set_param(subSysPortH.Outport(outIdx),'Name',inportInfo{outIdx}.SignalLabels);
                    end
                    set_param(subSysPortH.Outport(outIdx),'DataLoggingDecimateData','off');
                    set_param(subSysPortH.Outport(outIdx),'DataLoggingLimitDataPoints','off');
                end
            end

            sigOffset=sigOffset+sigCnt;

        end





    end

    function outPort=addReshape(muxOutPort,dimension,outPortIdx,subSysH,outIdx)
        inPortPos=get_param(muxOutPort,'Position');
        midLine=inPortPos(2);

        blockPos=[reconsParams.reshapeLeft+posShift(outIdx).column...
        ,midLine-0.5*reconsParams.reshapeHeight...
        ,reconsParams.reshapeLeft+reconsParams.reshapeWidth+posShift(outIdx).column...
        ,midLine+0.5*reconsParams.reshapeHeight];

        reshapeH=add_block('built-in/Reshape',[getfullname(subSysH),'/','Reshape',num2str(outPortIdx)],...
        'Position',range_check_position(blockPos));
        set_param(reshapeH,'OutputDimensionality','Customize')

        if isscalar(dimension)
            dim=num2str(dimension);
        else
            if iscolumn(dimension)
                dim=sprintf('[%s]''',num2str(dimension'));
            else
                dim=sprintf('[%s]',num2str(dimension));
            end
        end

        set_param(reshapeH,'OutputDimensions',dim);
        reshPortH=get_param(reshapeH,'PortHandles');

        add_line(subSysH,muxOutPort,reshPortH.Inport);

        outPort=reshPortH.Outport;
    end

    function[outPort,inPortIdx,sigbOutPortIdx]=addInportAndMux(numOfInps,isUsed,inPortIdx,sigbOutPortIdx,...
        outPortIdx,subSysH,outIdx,dataType)
        blockTop=reconsParams.winBufferV+((inPortIdx-1-posShift(outIdx).prevCount)*(reconsParams.inportHeight+reconsParams.inportVertSep));

        blockPos=[reconsParams.muxLeft+posShift(outIdx).column...
        ,blockTop...
        ,reconsParams.muxLeft+posShift(outIdx).column+reconsParams.muxWidth...
        ,blockTop+numOfInps*(reconsParams.inportHeight+reconsParams.inportVertSep)-reconsParams.inportVertSep];

        muxH=add_block('built-in/Mux',[getfullname(subSysH),'/','Mux',num2str(outPortIdx)],...
        'Position',range_check_position(blockPos),...
        'BackGroundColor','black');

        set_param(muxH,'Inputs',num2str(numOfInps));

        muxPortH=get_param(muxH,'PortHandles');
        for s=1:numOfInps
            [inPort,inPortIdx,sigbOutPortIdx]=addInPort(inPortIdx,sigbOutPortIdx,isUsed,subSysH,outIdx,dataType);
            add_line(subSysH,inPort,muxPortH.Inport(s));
        end
        portHorzAlign(muxH,true)
        portHorzAlign(muxH,true)
        outPort=muxPortH.Outport;
    end

    function[outPort,inPortIdx,sigbOutPortIdx]=addInPort(inPortIdx,sigbOutPortIdx,isUsed,subSysH,outIdx,dataType)
        if isUsed.flag
            inH=add_block('built-in/Inport',[getfullname(subSysH),'/','In',num2str(inPortIdx)]);
        else
            inH=add_block('built-in/Constant',[getfullname(subSysH),'/','In',num2str(inPortIdx)]);
            [isEnum,className]=sldvshareprivate('util_is_enum_type',dataType);
            if isEnum
                data=sldvshareprivate('util_get_enum_defaultvalue',className);
                set_param(inH,'Value',num2str(int32(data)));
            else
                temp=isUsed.ConstBlkVal;
                if isempty(temp)||strcmp(temp,'[]')
                    set_param(inH,'Value','0');
                else
                    set_param(inH,'Value',temp);
                end
            end
            set_param(inH,'OutDataTypeStr','double');
        end

        blockTop=reconsParams.winBufferV+((inPortIdx-1-posShift(outIdx).prevCount)*(reconsParams.inportHeight+reconsParams.inportVertSep));

        blockPos=[reconsParams.winBufferH+posShift(outIdx).column...
        ,blockTop...
        ,reconsParams.winBufferH+posShift(outIdx).column+reconsParams.inportWidth...
        ,blockTop+reconsParams.inportHeight];

        set_param(inH,'Position',range_check_position(blockPos));
        if isUsed.flag
            if strcmp(harnessOpts.harnessSource,'Signal Builder')||...
                strcmp(harnessOpts.harnessSource,'Signal Editor')||...
                strcmp(harnessOpts.harnessSource,'Test Sequence')
                sigbPortH=get_param(outputHarnessSource,'PortHandles');
                subSysPortH=get_param(subSysH,'PortHandles');
                add_line(harnessH,sigbPortH.Outport(sigbOutPortIdx),subSysPortH.Inport(sigbOutPortIdx));
                sigbOutPortIdx=sigbOutPortIdx+1;
            else
                subSysPortH=get_param(subSysH,'PortHandles');
                harnessPorts=find_system(harnessH,'SearchDepth',1,'BlockType','Inport');
                hPortH=get_param(harnessPorts(sigbOutPortIdx),'PortHandles');
                add_line(harnessH,hPortH.Outport(1),subSysPortH.Inport(sigbOutPortIdx));
                sigbOutPortIdx=sigbOutPortIdx+1;
            end
        end

        portH=get_param(inH,'PortHandles');
        outPort=portH.Outport;

        inPortIdx=inPortIdx+1;
    end

    function lastOutPort=addCastAndRateTrans(inPort,outPortIdx,compLeafInfo,subSysH,outIdx,isBDExtractedModel)

        inPortPos=get_param(inPort,'Position');
        midLine=inPortPos(2);

        blockPos=[reconsParams.castLeft+posShift(outIdx).column...
        ,midLine-0.5*reconsParams.castHeight...
        ,reconsParams.castLeft+reconsParams.castWidth+posShift(outIdx).column...
        ,midLine+0.5*reconsParams.castHeight];

        [isEnum,outDataType]=getDataTypeParam(compLeafInfo.DataType,mode,objH);
        dtcH=add_block('built-in/DataTypeConversion',[getfullname(subSysH),'/','Cast',num2str(outPortIdx)],...
        'Position',range_check_position(blockPos));
        set_param(dtcH,'OutDataTypeStr',outDataType);
        set_param(dtcH,'RndMeth','Nearest');


        if(isEnum)
            blockPos_w=blockPos(3)-blockPos(1);
            blockPos_enum=[blockPos(1)-blockPos_w-0.25*blockPos_w...
            ,blockPos(2)...
            ,blockPos(3)-blockPos_w-0.25*blockPos_w...
            ,blockPos(4)];
            dtcH_enum=add_block('built-in/DataTypeConversion',[getfullname(subSysH),'/','Cast',strcat(num2str(outPortIdx),'_toInt')],...
            'Position',range_check_position(blockPos_enum));
            set_param(dtcH_enum,'OutDataTypeStr','int32');
            dtcPortH_enum=get_param(dtcH_enum,'PortHandles');
            add_line(subSysH,inPort,dtcPortH_enum.Inport);
            dtcPortH=get_param(dtcH,'PortHandles');
            add_line(subSysH,dtcPortH_enum.Outport,dtcPortH.Inport);
        else
            dtcPortH=get_param(dtcH,'PortHandles');
            add_line(subSysH,inPort,dtcPortH.Inport);
        end


        required=isRateTransitionRequired(fundamentalSampleTime,compLeafInfo.ParentSampleTime,mode)&&~isBDExtractedModel;
        if required
            blockPos=[reconsParams.rateTranLeft+posShift(outIdx).column...
            ,midLine-0.5*reconsParams.rateTranHeight...
            ,reconsParams.rateTranLeft+reconsParams.rateTranWidth+posShift(outIdx).column...
            ,midLine+0.5*reconsParams.rateTranHeight];

            dtrtH=add_block('built-in/RateTransition',[getfullname(subSysH),'/','Sync',num2str(outPortIdx)],...
            'Position',range_check_position(blockPos));











            if(length(compLeafInfo.ParentSampleTime)==2&&compLeafInfo.ParentSampleTime(2)<0)||...
                (length(compLeafInfo.SampleTime)==2&&compLeafInfo.SampleTime(2)<0)
                set_param(dtrtH,'Deterministic','off');
            else
                set_param(dtrtH,'OutPortSampleTime',compLeafInfo.SampleTimeStr);
            end
            dtrtPortH=get_param(dtrtH,'PortHandles');
            add_line(subSysH,dtcPortH.Outport,dtrtPortH.Inport);
            lastOutPort=dtrtPortH.Outport;
        else
            lastOutPort=dtcPortH.Outport;
        end

        if isfield(compLeafInfo,'SamplingMode')&&strcmp(compLeafInfo.SamplingMode,'Frame based')
            blockPos=[reconsParams.frameConvLeft+posShift(outIdx).column...
            ,midLine-0.5*reconsParams.frameConvHeight...
            ,reconsParams.frameConvLeft+reconsParams.frameConvWidth+posShift(outIdx).column...
            ,midLine+0.5*reconsParams.frameConvHeight];


            frameBlkH=add_block('built-in/FrameConversion',[getfullname(subSysH),'/','toFrame',num2str(outPortIdx)],...
            'Position',range_check_position(blockPos));
            set_param(frameBlkH,'OutFrame','Frame-based');
            framePortH=get_param(frameBlkH,'PortHandles');
            add_line(subSysH,lastOutPort,framePortH.Inport);
            lastOutPort=framePortH.Outport;
        end
    end

    function createInPortsForXilModelUnderTest



        testSubsysPorts=get_param(testSubsysH,'PortHandles');
        testSubsysInPortsH=testSubsysPorts.Inport;
        [~,inportNames]=getSourceModelInportBlocks;
        if~isempty(testSubsysInPortsH)
            firstPos=get_param(testSubsysInPortsH(1),'Position');
            delta_x=5;
            gap=max(60,20+delta_x*length(inportNames));
            x=firstPos(1)-gap;
            y=firstPos(2);
            for i=1:length(inportNames)
                quotedName=strrep(inportNames{i},'/','//');
                inH=add_block([srcName,'/',quotedName],[harnessName,'/',quotedName]);

                bPos=get_param(inH,'Position');
                dx=bPos(3)-bPos(1);
                dy=ceil((bPos(4)-bPos(2))/2);
                bPos=[x,(y-dy),(x+dx),(y+dy)];
                set_param(inH,'Position',range_check_position(bPos));

                y=y+dy+30;
                harnessMaxX=max(harnessMaxX,x+dx+30);
                harnessMaxY=max(harnessMaxY,y);

                inportH=get_param(inH,'PortHandles');
                add_line(harnessH,inportH.Outport(1),testSubsysInPortsH(i));
            end
            if harnessOpts.logInputsAndOutputs
                inportInfo=sldvData.AnalysisInformation.InputPortInfo;
                for i=1:length(testSubsysInPortsH)
                    if iscell(inportInfo{i})&&isfield(inportInfo{i}{1},'hasArrayOfBuses')&&inportInfo{i}{1}.hasArrayOfBuses


                    else
                        set_param(testSubsysInPortsH(i),'DataLogging','on');
                        set_param(testSubsysInPortsH(i),'DataLoggingDecimateData','off');
                        set_param(testSubsysInPortsH(i),'DataLoggingLimitDataPoints','off');
                        set_param(testSubsysInPortsH(i),'DataLoggingNameMode','SignalName');
                        if isempty(get_param(testSubsysInPortsH(i),'Name'))
                            set_param(testSubsysInPortsH(i),'Name',inportNames{i})
                        end
                    end
                end
            end
        end
    end

    function createOutPortsForTestSubsystem


        testSubsysPorts=get_param(testSubsysH,'PortHandles');
        testSubsysOutPortsH=testSubsysPorts.Outport;
        if~isempty(testSubsysOutPortsH)
            firstPos=get_param(testSubsysOutPortsH(1),'Position');
            delta_x=5;
            gap=max(60,20+delta_x*length(outportBlkNames));
            x=firstPos(1)+gap;
            y=firstPos(2);
            for idx=1:length(testSubsysOutPortsH)
                quotedName=strrep(outportBlkNames{idx},'/','//');




                if~strcmp(get_param(outportBlkHandles(idx),'IsBusElementPort'),'on')
                    outH=add_block([srcName,'/',quotedName],[harnessName,'/',quotedName]);
                else



                    outH=add_block('simulink/Sinks/Out Bus Element',[harnessName,'/Out Bus Element'],...
                    'MakeNameUnique','on');


                    set_param(outH,'Element','');
                    set_param(outH,'PortName',outportBlkNames{idx});
                end

                bPos=get_param(outH,'Position');
                dx=bPos(3)-bPos(1);
                dy=ceil((bPos(4)-bPos(2))/2);
                bPos=[x,(y-dy),(x+dx),(y+dy)];
                set_param(outH,'Position',range_check_position(bPos));

                y=y+dy+30;
                harnessMaxX=max(harnessMaxX,x+dx+30);
                harnessMaxY=max(harnessMaxY,y);

                outportH=get_param(outH,'PortHandles');
                ssPortPos=get_param(testSubsysOutPortsH(idx),'Position');
                portPos=get_param(outportH.Inport,'Position');
                break_x=ssPortPos(1)+gap-10-(idx*delta_x);
                add_line(harnessH,[ssPortPos;break_x,ssPortPos(2);break_x,portPos(2);portPos]);
            end
            if harnessOpts.logInputsAndOutputs
                outportInfo=sldvData.AnalysisInformation.OutputPortInfo;
                for idx=1:length(testSubsysOutPortsH)
                    if iscell(outportInfo{idx})&&isfield(outportInfo{idx}{1},'hasArrayOfBuses')&&outportInfo{idx}{1}.hasArrayOfBuses


                    else
                        set_param(testSubsysOutPortsH(idx),'DataLogging','on');
                        set_param(testSubsysOutPortsH(idx),'DataLoggingDecimateData','off');
                        set_param(testSubsysOutPortsH(idx),'DataLoggingLimitDataPoints','off');
                        set_param(testSubsysOutPortsH(idx),'DataLoggingNameMode','SignalName');
                        if isempty(get_param(testSubsysOutPortsH(idx),'Name'))
                            set_param(testSubsysOutPortsH(idx),'Name',outportBlkNames{idx});
                        end
                    end
                end
            end
        end
    end

    function resizeHarness


        loc=get_param(harnessH,'Location');
        set_param(harnessH,'Location',[loc(1),loc(2),(min(harnessMaxX,1200)+loc(1)),(min(harnessMaxY,1000)+loc(2))]);
    end

    function setTestSubsystemReadOnly



        if~modelRefHarness


            r=sfroot();
            c=r.find('-isa','Stateflow.Chart');
            for i=1:length(c)
                if strfind(c(i).Path,testSubsysName)
                    c(i).Locked=true;
                end
            end


            set_param(testSubsysH,'Permissions','ReadOnly');
        end
    end

    function createInPortsForHarness




        useReconsParam=isfield(reconsParams,'inportWidth')&&isfield(reconsParams,'inportHeight');
        if~isempty(inputSignalNames)
            firstPos=[50,50,50,50];


            gap=0;
            x=firstPos(1)+gap;
            y=firstPos(2);
            for i=1:length(inputSignalNames)
                quotedName=strrep(inputSignalNames{i},'/','//');
                inH=add_block('built-in/Inport',[harnessName,'/',quotedName]);

                if useReconsParam
                    dx=reconsParams.inportWidth;
                    dy=ceil(reconsParams.inportHeight/2);
                else
                    bPos=get_param(inH,'Position');
                    dx=bPos(3)-bPos(1);
                    dy=ceil((bPos(4)-bPos(2))/2);
                end
                bPos=[x,(y-dy),(x+dx),(y+dy)];
                set_param(inH,'Position',range_check_position(bPos));



                set_param(inH,'PortDimensions','1');

                y=y+dy+30;
                harnessMaxX=max(harnessMaxX,x+dx+30);
                harnessMaxY=max(harnessMaxY,y);



                if(numel(flatSLDVData)<i)&&harnessOpts.ignoreEmptyData&&isXIL

                elseif strcmp(class(flatSLDVData{i}),'embedded.fi')%#ok<STISA>
                    set_param(inH,'OutDataTypeStr','double');
                elseif islogical(flatSLDVData{i})
                    set_param(inH,'OutDataTypeStr','boolean');


                elseif isobject(flatSLDVData{i})
                    set_param(inH,'OutDataTypeStr','int32');
                else
                    set_param(inH,'OutDataTypeStr',class(flatSLDVData{i}));
                end
            end
        end
    end

    function subSysH=constructOutputReshapeAndCastSubsystem
        subSysH=add_block('built-in/SubSystem',[harnessName,'/','Size_Type_Output'],...
        'NamePlacement','Alternate');
        left=575;
        pos=[left,top,left+20,top+height];
        set_param(subSysH,'Position',range_check_position(pos));
        set_param(subSysH,'BackgroundColor','black');

        [outSignalCnt,compiledSignalInfo]=busElementLength(sldvData.AnalysisInformation.OutputPortInfo,harnessOpts);

        outportInfo=sldvData.AnalysisInformation.OutputPortInfo;
        totSigCnt=0;
        outPortIdx=1;
        sigOffset=0;
        outCnt=length(outSignalCnt);


        for outIdx=1:outCnt





            isBus=(outSignalCnt(outIdx)>1)||...
            (outSignalCnt(outIdx)==1&&isfield(outportInfo{outIdx}{1},'BusObject')...
            &&~isempty(outportInfo{outIdx}{1}.BusObject));

            sigCnt=abs(outSignalCnt(outIdx));
            sigPort=zeros(1,sigCnt);
            if harnessOpts.logInputsAndOutputs
                logSigPort=zeros(1,sigCnt);
            end


            for sigIdx=1:sigCnt
                cumSigIdx=sigIdx+sigOffset;

                numOfOutputs=prod(compiledSignalInfo{cumSigIdx}.Dimensions);
                totSigCnt=totSigCnt+numOfOutputs;

                if numOfOutputs>1
                    [muxOutPort,outPortIdx]=addOutportAndDeMux(numOfOutputs,outPortIdx,cumSigIdx,subSysH,outIdx);
                    reshapeOutPort=addOutputReshape(muxOutPort,compiledSignalInfo{cumSigIdx}.Dimensions,cumSigIdx,subSysH,outIdx);
                    sigPort(sigIdx)=addOutputCastAndRateTrans(reshapeOutPort,cumSigIdx,compiledSignalInfo{cumSigIdx},subSysH,outIdx);
                    if harnessOpts.logInputsAndOutputs
                        logSigPort(sigIdx)=muxOutPort;
                    end
                else

                    [outPort,outPortIdx]=addOutPort(outPortIdx,subSysH,outIdx);

                    sigPort(sigIdx)=addOutputCastAndRateTrans(outPort,cumSigIdx,compiledSignalInfo{cumSigIdx},subSysH,outIdx);
                    if harnessOpts.logInputsAndOutputs
                        logSigPort(sigIdx)=outPort;
                    end
                end
            end


            if isBus

                isRootOutportNonVirtual=false;

                busSelectPos=[reconsParams.output.busSelectorLeft+outputPosShift(outIdx).column...
                ,reconsParams.busTopV...
                ,reconsParams.output.busSelectorLeft+outputPosShift(outIdx).column+reconsParams.busCreateWidth...
                ,reconsParams.busBottomV];

                busSelectPath=[getfullname(subSysH),'/Bus',num2str(outIdx)];
                busSelectSysH=add_block('built-in/SubSystem',busSelectPath,'Position',range_check_position(busSelectPos));
                Sldv.HarnessUtils.build_bus_hierarchy(busSelectSysH,outportInfo{outIdx},isRootOutportNonVirtual,true,harnessOpts);



                busSubSysPorts=get_param(busSelectSysH,'PortHandles');

                for sigIdx=1:sigCnt
                    add_line(subSysH,busSubSysPorts.Outport(sigIdx),sigPort(sigIdx),'autorouting','off');
                end


                portHorzAlign(busSelectSysH,false);
                lastInPort=busSubSysPorts.Inport(1);
            else
                lastInPort=sigPort;
            end


            portPos=get_param(lastInPort,'Position');
            blockPos=[reconsParams.output.inportLeft+outputPosShift(outIdx).column...
            ,portPos(2)-0.5*reconsParams.inportHeight...
            ,reconsParams.output.inportLeft+outputPosShift(outIdx).column+reconsParams.inportWidth...
            ,portPos(2)+0.5*reconsParams.inportHeight];

            inH=add_block('built-in/Inport',[getfullname(subSysH),'/','In',num2str(outIdx)],...
            'Position',range_check_position(blockPos));

            inPortH=get_param(inH,'PortHandles');
            add_line(subSysH,inPortH.Outport,lastInPort);

            testSubsysPortH=get_param(testSubsysH,'PortHandles');
            subSysPortH=get_param(subSysH,'PortHandles');
            add_line(harnessH,testSubsysPortH.Outport(outIdx),subSysPortH.Inport(outIdx));

            if harnessOpts.logInputsAndOutputs

                if isBus



                    if outportInfo{outIdx}{1}.hasArrayOfBuses
                        busSubSysPorts=find_system(busSelectSysH,'SearchDepth',1,'BlockType','Outport');
                        for sigIdx=1:length(sigPort)
                            hPort=get_param(get_param(logSigPort(sigIdx),'Line'),'SrcPortHandle');
                            set_param(hPort,'DataLogging','on');
                            set_param(hPort,'DataLoggingNameMode','SignalName');
                            if isempty(get_param(hPort,'Name'))
                                portName=get_param(busSubSysPorts(sigIdx),'Name');
                                set_param(hPort,'Name',portName);
                            end
                            set_param(hPort,'DataLoggingDecimateData','off');
                            set_param(hPort,'DataLoggingLimitDataPoints','off');
                        end
                    else
                        set_param(testSubsysPortH.Outport(outIdx),'DataLogging','on');
                        set_param(testSubsysPortH.Outport(outIdx),'DataLoggingNameMode','SignalName');
                        if isempty(get_param(testSubsysPortH.Outport(outIdx),'Name'))
                            set_param(testSubsysPortH.Outport(outIdx),'Name',outportInfo{outIdx}{1}.SignalPath);
                        end
                        set_param(testSubsysPortH.Outport(outIdx),'DataLoggingDecimateData','off');
                        set_param(testSubsysPortH.Outport(outIdx),'DataLoggingLimitDataPoints','off');
                    end
                else
                    set_param(testSubsysPortH.Outport(outIdx),'DataLogging','on')
                    set_param(testSubsysPortH.Outport(outIdx),'DataLoggingNameMode','SignalName')
                    if isempty(get_param(testSubsysPortH.Outport(outIdx),'Name'))
                        set_param(testSubsysPortH.Outport(outIdx),'Name',sldvData.AnalysisInformation.OutputPortInfo{outIdx}.SignalLabels)
                    end
                    set_param(testSubsysPortH.Outport(outIdx),'DataLoggingDecimateData','off');
                    set_param(testSubsysPortH.Outport(outIdx),'DataLoggingLimitDataPoints','off');
                end
            end
            sigOffset=sigOffset+sigCnt;
        end
    end

    function outPort=addOutputReshape(muxInPort,~,outPortIdx,subSysH,outIdx)
        inPortPos=get_param(muxInPort,'Position');
        midLine=inPortPos(2);

        blockPos=[reconsParams.output.reshapeLeft+outputPosShift(outIdx).column...
        ,midLine-0.5*reconsParams.reshapeHeight...
        ,reconsParams.output.reshapeLeft+reconsParams.reshapeWidth+outputPosShift(outIdx).column...
        ,midLine+0.5*reconsParams.reshapeHeight];

        reshapeH=add_block('built-in/Reshape',[getfullname(subSysH),'/','Reshape',num2str(outPortIdx)],...
        'Position',range_check_position(blockPos));
        reshPortH=get_param(reshapeH,'PortHandles');
        set_param(reshapeH,'OutputDimensionality','1-D array')

        add_line(subSysH,reshPortH.Outport,muxInPort);

        outPort=reshPortH.Inport;
    end

    function[outPort,inPortIdx]=addOutportAndDeMux(numOfOutputs,inPortIdx,outPortIdx,subSysH,outIdx)
        blockTop=reconsParams.winBufferV+((inPortIdx-1-outputPosShift(outIdx).prevCount)*(reconsParams.inportHeight+reconsParams.inportVertSep));

        blockPos=[reconsParams.output.muxLeft+outputPosShift(outIdx).column...
        ,blockTop...
        ,reconsParams.output.muxLeft+outputPosShift(outIdx).column+reconsParams.muxWidth...
        ,blockTop+numOfOutputs*(reconsParams.inportHeight+reconsParams.inportVertSep)-reconsParams.inportVertSep];


        blockPos=min(blockPos,32767);
        deMuxH=add_block('built-in/Demux',[getfullname(subSysH),'/','Demux',num2str(outPortIdx)],...
        'Position',range_check_position(blockPos),...
        'BackGroundColor','black');

        set_param(deMuxH,'Outputs',num2str(numOfOutputs));

        deMuxPortH=get_param(deMuxH,'PortHandles');
        for s=1:numOfOutputs
            [outPort,inPortIdx]=addOutPort(inPortIdx,subSysH,outIdx);
            add_line(subSysH,deMuxPortH.Outport(s),outPort);
        end
        portHorzAlign(deMuxH,false)
        portHorzAlign(deMuxH,false)
        outPort=deMuxPortH.Inport;
    end

    function[outPort,outPortIdx]=addOutPort(outPortIdx,subSysH,outIdx)
        ssOutH=add_block('built-in/Outport',[getfullname(subSysH),'/',outputSignalNames{outPortIdx}]);
        ssOutPortPH=get_param(ssOutH,'PortHandles');
        outPort=ssOutPortPH.Inport;

        blockTop=50+((outPortIdx-1-outputPosShift(outIdx).prevCount)*(reconsParams.inportHeight+reconsParams.inportVertSep));

        blockPos=[reconsParams.output.outportLeft+outputPosShift(outIdx).column...
        ,blockTop...
        ,reconsParams.output.outportLeft+outputPosShift(outIdx).column+reconsParams.inportWidth...
        ,blockTop+reconsParams.inportHeight];

        set_param(ssOutH,'Position',range_check_position(blockPos));



        outH=add_block('built-in/Outport',[getfullname(harnessH),'/',outputSignalNames{outPortIdx}]);
        sizeTypeOutputPos=get_param([getfullname(harnessH),'/Size_Type_Output'],'Position');
        blockPos=[sizeTypeOutputPos(3)+150+outputPosShift(outIdx).column...
        ,blockTop...
        ,sizeTypeOutputPos(3)+150+outputPosShift(outIdx).column+reconsParams.inportWidth...
        ,blockTop+reconsParams.inportHeight];
        set_param(outH,'Position',range_check_position(blockPos));
        add_line(harnessH,['Size_Type_Output/',num2str(outPortIdx)],[outputSignalNames{outPortIdx},'/1']);

        outPortIdx=outPortIdx+1;
        fprintf(1,'.');
        if~mod(outPortIdx,100)
            fprintf(1,' %d\n',outPortIdx);
        end
    end

    function firstInPort=addOutputCastAndRateTrans(outPort,outPortIdx,compLeafInfo,subSysH,outIdx)




        firstInPort=[];
        lastOutPort=[];
        dtrtPortH=[];
        outPortPos=get_param(outPort,'Position');
        midLine=outPortPos(2);


        required=isRateTransitionRequired(fundamentalSampleTime,compLeafInfo.ParentSampleTime,mode);
        if required
            blockPos=[reconsParams.output.rateTranLeft+outputPosShift(outIdx).column...
            ,midLine-0.5*reconsParams.rateTranHeight...
            ,reconsParams.output.rateTranLeft+reconsParams.rateTranWidth+outputPosShift(outIdx).column...
            ,midLine+0.5*reconsParams.rateTranHeight];

            dtrtH=add_block('built-in/RateTransition',[getfullname(subSysH),'/','Sync',num2str(outPortIdx)],...
            'Position',range_check_position(blockPos));
            set_param(dtrtH,'OutPortSampleTime',compLeafInfo.SampleTimeStr);
            dtrtPortH=get_param(dtrtH,'PortHandles');

            firstInPort=dtrtPortH.Inport;
            lastOutPort=dtrtPortH.Outport;
        end

        [isEnum,outDataType]=getDataTypeParam(compLeafInfo.DataType,mode,objH);

        if(isEnum)
            blockPos=[reconsParams.output.enumcastLeft+outputPosShift(outIdx).column...
            ,midLine-0.5*reconsParams.castHeight...
            ,reconsParams.output.enumcastLeft+reconsParams.castWidth+outputPosShift(outIdx).column...
            ,midLine+0.5*reconsParams.castHeight];
            dtcH_enum=add_block('built-in/DataTypeConversion',[getfullname(subSysH),'/','Cast',strcat(num2str(outPortIdx),'_toInt')],...
            'Position',range_check_position(blockPos));
            set_param(dtcH_enum,'OutDataTypeStr','int32');
            dtcPortH_enum=get_param(dtcH_enum,'PortHandles');
            lastOutPort=dtcPortH_enum.Outport;
            if isempty(firstInPort)
                firstInPort=dtcPortH_enum.Inport;
            end
            if~isempty(dtrtPortH)

                add_line(subSysH,dtrtPortH.Outport,dtcPortH_enum.Inport);
            end
        end


        blockPos=[reconsParams.output.castLeft+outputPosShift(outIdx).column...
        ,midLine-0.5*reconsParams.castHeight...
        ,reconsParams.output.castLeft+reconsParams.castWidth+outputPosShift(outIdx).column...
        ,midLine+0.5*reconsParams.castHeight];

        dtcH=add_block('built-in/DataTypeConversion',[getfullname(subSysH),'/','Cast',num2str(outPortIdx)],...
        'Position',range_check_position(blockPos));

        if~isempty(regexp(outDataType,'^fixdt','once'))
            outDataType='double';
        end
        set_param(dtcH,'OutDataTypeStr',outDataType);
        dtcPortH=get_param(dtcH,'PortHandles');

        if isempty(firstInPort)
            firstInPort=dtcPortH.Inport;
        end
        if~isempty(lastOutPort)

            add_line(subSysH,lastOutPort,dtcPortH.Inport);
        end



        add_line(subSysH,dtcPortH.Outport,outPort);
    end
end

function status=isRateTransitionRequired(~,compiledPortSampleTime,mode)
    if length(compiledPortSampleTime)==1


        if isinf(compiledPortSampleTime)
            status=true;
        elseif compiledPortSampleTime==0
            status=false;
        else
            error([mode,':HarnessUtils:CreateModelHarness:UnrecognizedSampleTime'],...
            getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:SampleTimeNotRecognised',num2str(compiledPortSampleTime))));
        end
    else




        if compiledPortSampleTime(1)>0





            status=true;
        elseif compiledPortSampleTime(1)==0&&compiledPortSampleTime(2)==1
            status=true;
        elseif compiledPortSampleTime(1)==-2&&compiledPortSampleTime(2)==0
            status=false;
        else
            error([mode,':HarnessUtils:CreateModelHarness:UnrecognizedSampleTime'],...
            getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:SampleTimeNotRecognised',num2str(compiledPortSampleTime))));
        end
    end
end





function portHorzAlign(blockH,busCreator)
    blkPorts=get_param(blockH,'PortHandles');
    blkStartPos=get_param(blockH,'Position');

    if busCreator
        listOfPorts=blkPorts.Inport;
        srcPort1=get_param(get_param(listOfPorts(1),'Line'),'SrcPortHandle');
    else
        listOfPorts=blkPorts.Outport;
        srcPort1=get_param(get_param(listOfPorts(1),'Line'),'DstPortHandle');
    end
    port1Pos=get_param(listOfPorts(1),'Position');
    srcPort1Pos=get_param(srcPort1,'Position');

    if length(listOfPorts)>1
        inPortNPos=get_param(listOfPorts(end),'Position');
        if busCreator
            srcPortN=get_param(get_param(listOfPorts(end),'Line'),'SrcPortHandle');
        else
            srcPortN=get_param(get_param(listOfPorts(end),'Line'),'DstPortHandle');
        end
        srcPortNPos=get_param(srcPortN,'Position');

        growFactor=(srcPortNPos(2)-srcPort1Pos(2))/(inPortNPos(2)-port1Pos(2));

        blockHeight=blkStartPos(4)-blkStartPos(2);
        newHeight=blockHeight*growFactor;


        set_param(blockH,'Position',range_check_position([blkStartPos(1:3),blkStartPos(2)+newHeight]));

        port1Pos=get_param(listOfPorts(1),'Position');
    else
        newHeight=blkStartPos*[0,-1,0,1]';
    end


    moveDown=srcPort1Pos(2)-port1Pos(2);

    finalPosition=[blkStartPos(1),...
    blkStartPos(2)+moveDown,...
    blkStartPos(3),...
    blkStartPos(2)+moveDown+newHeight];

    set_param(blockH,'Position',range_check_position(finalPosition));
end

function[outSignalCnt,compiledSignalInfo]=busElementLength(portInfo,harnessOpts)






    numPorts=length(portInfo);
    numSignals=0;
    for i=1:numPorts
        numSignals=getTotalNumSignals(portInfo{i},numSignals,harnessOpts);
    end

    outSignalCnt=zeros(1,numPorts);
    compiledSignalInfo=cell(1,numSignals);

    index=1;
    for i=1:numPorts
        [outSignalCnt(i),compiledSignalInfo,index]=getInpInfo(portInfo{i},compiledSignalInfo,...
        -1,index,harnessOpts);
    end
end

function numSignals=getTotalNumSignals(inportInfo,numSignals,harnessOpts)
    if iscell(inportInfo)
        numArrayOfBuses=1;
        if isfield(inportInfo{1},'Dimensions')
            numArrayOfBuses=prod(inportInfo{1}.Dimensions);
        end
        for k=1:numArrayOfBuses
            for i=2:length(inportInfo)
                numSignals=getTotalNumSignals(inportInfo{i},numSignals,harnessOpts);
            end
        end
    else
        numSignals=numSignals+1;
    end
end

function[outSignalCnt,compiledSignalInfo,index]=getInpInfo(inportInfo,compiledSignalInfo,...
    outSignalCnt,index,harnessOpts)
    if iscell(inportInfo)
        if outSignalCnt==-1
            outSignalCnt=0;
        end

        numArrayOfBuses=1;
        if isfield(inportInfo{1},'Dimensions')
            numArrayOfBuses=prod(inportInfo{1}.Dimensions);
        end

        for k=1:numArrayOfBuses
            for i=2:length(inportInfo)
                [outSignalCnt,compiledSignalInfo,index]=getInpInfo(inportInfo{i},compiledSignalInfo,...
                outSignalCnt,index,harnessOpts);
            end
        end
    else
        if outSignalCnt~=-1
            outSignalCnt=outSignalCnt+1;
        end
        compiledSignalInfo{index}=inportInfo;
        index=index+1;
    end
end

function align_top_bottom(block1,varargin)
    startPos=get_param(block1,'Position');
    top=startPos(2);
    bottom=startPos(4);

    for idx=1:length(varargin)
        bh=varargin{idx};
        if~isempty(bh)
            bPos=get_param(bh,'Position');
            blockPos=[bPos(1),top,bPos(3),bottom];
            set_param(bh,'Position',range_check_position(blockPos));
        end
    end
end

function adj_dest_2_v_align_ports(srcBlk,destBlk)
    srcPorts=get_param(srcBlk,'PortHandles');
    srcOut1Pos=get_param(srcPorts.Outport(1),'Position');

    destPorts=get_param(destBlk,'PortHandles');
    destIn1Pos=get_param(destPorts.Inport(1),'Position');

    deltaH=srcOut1Pos(2)-destIn1Pos(2);

    startPos=get_param(destBlk,'Position');
    blockPos=startPos+[0,1,0,1]*deltaH;
    set_param(destBlk,'Position',range_check_position(blockPos));
end

function[flatSLDVData,inputSignalNames,outputSignalNames,inputSignalComplexity]=flatDataForHarness(data,sldvData,harnessOpts)
    inputsInfo=sldvData.AnalysisInformation.InputPortInfo;

    [numInports,numTC]=size(data);
    numSignals=0;
    for i=1:numInports
        numSignals=numSignals+length(data{i,1});
    end

    flatSLDVData=cell(numSignals,numTC);

    index=0;
    for i=1:numInports
        [im,~]=size(data{i,1});
        for j=1:numTC
            sigData=data{i,j};
            [jm,~]=size(sigData);
            for k=1:jm
                flatSLDVData{index+k,j}=sigData{k,:};
            end
        end
        index=index+im;
    end

    leaf=1;
    sigPath='';
    inputSignalInfo=struct;
    inputSignalInfo.names=cell(1,numSignals);
    inputSignalInfo.complexity=cell(1,numSignals);
    for i=1:length(inputsInfo)
        [inputSignalInfo,leaf]=generateSignalInfo(inputsInfo{i},inputSignalInfo,leaf,sigPath,true);
    end

    inputSignalComplexity=inputSignalInfo.complexity;
    inputSignalNames=inputSignalInfo.names;


    outputsInfo=sldvData.AnalysisInformation.OutputPortInfo;
    numOutports=length(outputsInfo);
    outputSignalInfo=struct;
    outputSignalInfo.names=[];
    outputSignalInfo.complexity=[];
    leaf=1;
    sigPath='';
    for i=1:numOutports
        [outputSignalInfo,leaf]=generateSignalInfo(outputsInfo{i},outputSignalInfo,leaf,sigPath,true);
    end

    outputSignalNames=outputSignalInfo.names;


    harnessOpts.testObj.FlattenedModelInports=inputSignalNames;
    harnessOpts.testObj.FlattenedModelOutports=outputSignalNames;

    if harnessOpts.useUnderscores






        inputSignalNames=regexprep(inputSignalNames,'\(','_');
        inputSignalNames=regexprep(inputSignalNames,'\)','');
        inputSignalNames=regexprep(inputSignalNames,'\,','_');
        inputSignalNames=regexprep(inputSignalNames,'\.','_');

        outputSignalNames=regexprep(outputSignalNames,'\(','_');
        outputSignalNames=regexprep(outputSignalNames,'\)','');
        outputSignalNames=regexprep(outputSignalNames,'\,','_');
        outputSignalNames=regexprep(outputSignalNames,'\.','_');
    end
end

function[signalInfo,leaf]=generateSignalInfo(InputInfo,signalInfo,leaf,sigPath,isTopLevelCall)



    if iscell(InputInfo)
        locl=getSignalNameFromPath(InputInfo,isTopLevelCall);
        sigPath=[sigPath,locl.sName];

        myDims=1;
        if isfield(InputInfo{1},'Dimensions')
            myDims=InputInfo{1}.Dimensions;
        end

        if all(myDims==1)
            for i=2:length(InputInfo)
                [signalInfo,leaf]=generateSignalInfo(InputInfo{i},signalInfo,leaf,sigPath,false);
            end
        else
            totalDim=length(myDims);
            totalElem=prod(myDims);
            idxVec=getIndexVec(myDims,1:totalElem);
            for i=1:totalElem
                idx=idxVec(i,:);
                tPath=[sigPath,'('];
                for j=1:totalDim
                    tPath=[tPath,num2str(idx(j))];%#ok<AGROW>
                    if j~=totalDim
                        tPath=[tPath,','];%#ok<AGROW>
                    end
                end
                tPath=[tPath,')'];%#ok<AGROW>
                for k=2:length(InputInfo)
                    [signalInfo,leaf]=generateSignalInfo(InputInfo{k},signalInfo,leaf,tPath,false);
                end
            end
        end
    elseif InputInfo.Used
        myDims=InputInfo.Dimensions;
        complexity='real';
        if(isfield(InputInfo,'Complexity'))&&strcmp(InputInfo.Complexity,'complex')
            complexity='complex';
        end
        if all(myDims==1)
            locl=getSignalNameFromLabel(InputInfo,isTopLevelCall);
            str=[sigPath,locl.sName];
            signalInfo.names{leaf}=str;
            signalInfo.complexity{leaf}=complexity;
            leaf=leaf+1;
        else
            totalDim=length(myDims);
            totalElem=prod(myDims);
            idxVec=getIndexVec(myDims,1:totalElem);
            for i=1:totalElem
                idx=idxVec(i,:);


                locl=getSignalNameFromLabel(InputInfo,isTopLevelCall);
                str=[sigPath,locl.sName,'('];
                for j=1:totalDim
                    str=[str,num2str(idx(j))];%#ok<AGROW>
                    if j~=totalDim
                        str=[str,','];%#ok<AGROW>
                    end
                end
                str=[str,')'];%#ok<AGROW>
                signalInfo.names{leaf}=str;
                signalInfo.complexity{leaf}=complexity;
                leaf=leaf+1;
            end
        end
    end
end

function locl=getSignalNameFromPath(InputInfo,isTopLevelCall)






    if isTopLevelCall&&~isempty(strfind(InputInfo{1}.SignalPath,'.'))
        elemsInBlockPath=regexp(InputInfo{1}.BlockPath,'/','split');
        blockNameInModel=elemsInBlockPath{end};
        blockNameWithOutDot=strrep(blockNameInModel,'.','_');
        signalPath=strrep(InputInfo{1}.SignalPath,blockNameInModel,blockNameWithOutDot);
        locl=regexp(signalPath,'(?<sName>[\.\s*]*[^\.]*$)','names');
        locl.sName=strrep(locl.sName,blockNameWithOutDot,blockNameInModel);
    else
        locl=regexp(InputInfo{1}.SignalPath,'(?<sName>[\.\s*]*[^\.]*$)','names');
    end
end

function locl=getSignalNameFromLabel(InputInfo,isTopLevelCall)




    if isTopLevelCall&&~isempty(strfind(InputInfo.SignalLabels,'.'))
        elemsInBlockPath=regexp(InputInfo.BlockPath,'/','split');
        blockNameInModel=elemsInBlockPath{end};
        blockNameWithOutDot=strrep(blockNameInModel,'.','_');
        signalLabel=strrep(InputInfo.SignalLabels,blockNameInModel,blockNameWithOutDot);
        locl=regexp(signalLabel,'(?<sName>[\.\s*]*[^\.]*$)','names');
        locl.sName=strrep(locl.sName,blockNameWithOutDot,blockNameInModel);
    else
        locl=regexp(InputInfo.SignalLabels,'(?<sName>[\.\s*]*[^\.]*$)','names');
    end
end

function idxVec=getIndexVec(siz,ndx)
    n=length(siz);
    k=[1,cumprod(siz(1:end-1))];
    idxVec=zeros(length(ndx),n);
    for i=n:-1:1
        vi=rem(ndx-1,k(i))+1;
        vj=(ndx-vi)/k(i)+1;
        idxVec(:,i)=vj';
        ndx=vi;
    end
end

function[isEnum,dataTypeParam]=getDataTypeParam(DataTypeStr,mode,modelH)
    isEnum=false;


    if sldvshareprivate('util_is_simulink_builtin',DataTypeStr)
        dataTypeParam=DataTypeStr;
    elseif fixed.internal.type.isNameOfTraditionalFixedPointType(DataTypeStr)






        dataTypeParam=sprintf('fixdt(''%s'')',DataTypeStr);
    elseif strncmp(DataTypeStr,'fixdt',5)||strncmp(DataTypeStr,'numerictype',11)
        dataTypeParam=DataTypeStr;
    else
        [isEnum,enumCls]=sldvshareprivate('util_is_enum_type',DataTypeStr);
        [isFxp,~]=sldvshareprivate('util_is_fxp_type',DataTypeStr,modelH);

        if(isFxp)
            dataTypeParam=DataTypeStr;
        else
            if(isEnum)
                dataTypeParam=strcat('Enum: ',enumCls);
            else
                error([mode,':HarnessUtils:CreateModelHarness:UnrecognizedDataType'],...
                getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:DataTypeNotRecognized',DataTypeStr)));
            end
        end
    end
end

function pos=range_check_position(inPos)

    pos=min(inPos,32767);
    pos=max(pos,-32768);

    if pos(1)>pos(3)
        pos(1)=pos(3);
    end

    if pos(2)>pos(4)
        pos(2)=pos(4);
    end
end


