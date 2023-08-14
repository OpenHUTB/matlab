classdef SFBase<hdlimplbase.EmlImplBase





























    methods
        function this=SFBase
            this.setPublish(false);
        end

    end

    methods

        function val=mustElaborateInPhase1(~,~,~)


















            val=true;

        end


        function params=hideImplParams(~,~,~)

            params={'usematrixtypesinhdl'};


            if strcmp(hdlfeature('EnableFlattenSFComp'),'off')
                params=[params,{'flattenhierarchy'}];
            end
        end
    end


    methods(Hidden)

        function hNewC=baseSFElaborate(this,hN,hC)








            [chartId,machine,isSFChart,isInitOutput,...
            generateResetLogic,...
            concurrencyMaximization,retiming,...
            constMultMode,ramMapping,guardIndex,...
            simIndexCheck,loopOptimization,persistentWarning,...
            variablePipeline,sharingFactor,instantiateFcns,...
            matrixTypes,hasInputEvents,compactSwitch]=this.getBlockInfo(hC);

            hdlcoder=hdlcurrentdriver;
            shandle=hC.SimulinkHandle;



            if hdlcoder.DUTMdlRefHandle>0
                snnH=get_param(hdlcoder.OrigStartNodeName,'handle');
                if isprop(get_param(snnH,'Object'),'BlockType')&&~strcmp(get_param(snnH,'BlockType'),'ModelReference')
                    obj=get_param(shandle,'Object');
                    origFullPath=regexprep(obj.getFullName,hdlcoder.ModelName,hdlcoder.OrigStartNodeName,'once');
                    shandle=get_param(origFullPath,'handle');
                end
            end


            annotations=find(idToHandle(sfroot,chartId),'-isa','Stateflow.Annotation');
            if~isempty(annotations)
                all_comments_in_the_chart=strjoin(arrayfun(@(x)x.PlainText,annotations,'UniformOut',false),newline);
                hN.addComment(all_comments_in_the_chart);
            end

            [TunableParamStrs,TunableParamTypes,TunableDataIds]=getTunableProperty(this,hC.SimulinkHandle);


            sf('set',chartId,'chart.hdlInfo.rtwSubsystemId',getSysId(shandle));
            sf('set',chartId,'chart.hdlInfo.HDLTraceability',hdlgetparameter('TraceabilityProcessing'));
            sf('set',chartId,'chart.hdlInfo.emitRequirementComments',hdlgetparameter('emitRequirementComments'));
            sf('set',chartId,'chart.hdlInfo.tunableDataIds',TunableDataIds);

            hC.Name=getEntityName(hC.Name,hC.SimulinkHandle);

            hNewC=hN.addComponent2(...
            'kind','sf_comp',...
            'name',hC.Name,...
            'InputSignals',hC.PirInputSignals,...
            'OutputSignals',hC.PirOutputSignals,...
            'ChartID',hC.SimulinkHandle,...
            'Machine',machine,...
            'StateflowChart',isSFChart,...
            'InitOutput',isInitOutput,...
            'GenerateResetLogic',generateResetLogic,...
            'Retiming',retiming,...
            'ConstMultMode',constMultMode,...
            'RamMapping',ramMapping,...
            'GuardIndexVariables',guardIndex,...
            'VariablePipeline',variablePipeline,...
            'SharingFactor',sharingFactor,...
            'InstantiateFunctions',instantiateFcns,...
            'MatrixTypes',matrixTypes,...
            'TunableParamStrs',TunableParamStrs,...
            'CompactSwitch',compactSwitch,...
            'SimIndexCheck',simIndexCheck);
            hNewC.SimulinkHandle=hC.SimulinkHandle;
            hNewC.setHasInputEvents(hasInputEvents);


            if isSFChart
                chartH=idToHandle(sfroot,chartId);
                chartType=chartH.stateMachineType;


                this.setChartType(hNewC,chartType);


                if strcmp(hdlfeature('EnableClockDrivenOutput'),'on')...
                    &&strcmp(chartType,'Moore')...
                    &&strcmp(getImplParams(this,'ClockDrivenOutput'),'on')

                    hNewC.setClockDrivenOutput(true);
                end
            end

            if strcmp(hdlfeature('EnableFlattenSFComp'),'on')




                if hN.getFlattenSFHolderNetwork

                    if~isempty(hC.PirInputPorts)&&~strcmp(hC.PirInputPorts(end).Kind,'data')
                        hN.setFlattenSFHolderNetwork(false);
                    else
                        hNewC.copyComment(hC);
                    end
                end
            else
                if hdlgetparameter('inlinematlabblockcode')
                    hNewC.copyComment(hC);
                end
            end

            if~isempty(TunableParamStrs)
                hNewC.setTunableParamTypes(TunableParamTypes);
            end
            loopUnrolling=strcmpi(loopOptimization,'Unrolling');
            loopStreaming=strcmpi(loopOptimization,'Streaming');
            hNewC.runLoopUnrolling(loopUnrolling);
            hNewC.runLoopStreaming(loopStreaming);


            totalOuts=length(hNewC.PirOutputPorts);
            for ii=1:totalOuts
                hNewC.PirOutputPorts(ii).copySLDataFrom(hC.PirOutputPorts(ii));
            end
            for ii=1:length(hNewC.PirInputPorts)
                hNewC.PirInputPorts(ii).copySLDataFrom(hC.PirInputPorts(ii));
            end

            hNewC.resetNone(~generateResetLogic);
            hNewC.runConcurrencyMaximizer(concurrencyMaximization);
            hNewC.emitPersistentWarning(persistentWarning);


            hNewC.runWebRenaming(true);
            hNewC.createCGIR();
        end



        function setChartType(~,hNewC,chartType)

            switch chartType
            case 'Moore'
                hNewC.setIsMooreChart;
            case 'Mealy'
                hNewC.setIsMealyChart;
            case 'Classic'
                hNewC.setIsClassicChart;
            otherwise
                hNewC.setIsNotAChart;
            end
        end


        function[v]=baseSFValidate(this,hC)

            v=validateImplParams(this,hC);




            v_settings=this.get_validate_settings(hC);
            if v_settings.checkretimeincompatibility
                v=[v,validateRetimingCompatibility(this,hC.Owner)];
            end

            if(v_settings.checkretimeblackbox)
                v=[v,validateRetimingBlackbox(this,hC.Owner)];
            end

            if(v_settings.incompatibleforxilinx)
                v=[v,validateXilinxCoregenCompatibility(this,hC)];
            end

            if(v_settings.incompatibleforaltera)
                v=[v,validateAlteraMegafunctionCompatibility(this,hC)];
            end

            if(v_settings.checkmatrices)
                v=[v,validateMatrices(this,hC,v_settings.maxsupporteddimension)];
            end


            maxOversampling=hdlgetparameter('maxoversampling');
            if(maxOversampling>0&&maxOversampling~=inf&&v_settings.checksingleratesharing)
                v=[v,validateSinglerateSharing(this,hC.Owner,hC)];
            end





            if strcmp(hdlfeature('EnableFlattenSFComp'),'on')&&hC.Owner.getFlattenSFHolderNetwork&&~isempty(hC.PirInputPorts)&&~strcmp(hC.PirInputPorts(end).Kind,'data')
                v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:CannotInlineChartsWithEvents'));
            end




            chartId=sfprivate('block2chart',hC.simulinkHandle);
            rt=sfroot;
            chartH=rt.idToHandle(chartId);
            v=[v,checkChartSettings(this,chartH)];
            v=[v,checkChartParameters(chartH,hC.simulinkHandle)];
            v=[v,checkForAtomicSubcharts(chartH)];
            v=[v,checkForSimulinkFunctions(chartH)];
            try


                hdldefaults.abstractRegister.findSingleRateSignal(hC);
            catch



                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:singlerate'));
            end

            if this.isStateflowChart(chartH)
                v=checkStateflowSettings(this,v);
            end

            if hdlgetparameter('EnableTestpoints')
                v=warnIfStateFlowTestpointsPresent(this,chartH,v);
            end




            phan=get_param(hC.SimulinkHandle,'PortHandles');
            triggerPortWidth=get_param(phan.Trigger,'CompiledPortWidth');

            distPipe=getImplParams(this,'DistributedPipelining');
            distPipe=~isempty(distPipe)&&strcmp(distPipe,'on');
            if~isempty(triggerPortWidth)
                if distPipe
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:SFInEventDistPipe'));
                end

                if triggerPortWidth>1
                    v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:MultipleInputEvents'));
                end

                triggerIdx=length(hC.PirInputSignals);
                if(triggerIdx>0)
                    triggerSig=hC.PirInputSignals(triggerIdx);
                    triggerType=triggerSig.Type;
                    if triggerType.isArrayType


                        triggerType=triggerType.BaseType;
                    end
                    if~triggerType.isBooleanType&&~triggerType.isUnsignedType(1)
                        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:stateflow:InputEventType'));
                    end
                end

                hNIC=hC.Owner.instances;
                result=checkRates(hNIC);
                if~isempty(result)
                    for j=1:length(result)
                        v(end+1)=result;
                    end
                end
            end



            sharingFactor=getImplParams(this,'SharingFactor');
            loopOpt=getImplParams(this,'LoopOptimization');
            mapRam=getImplParams(this,'MapPersistentVarsToRAM');
            guardIndex=getImplParams(this,'GuardIndexVariables');
            varPipe=getImplParams(this,'VariablesToPipeline');
            inputPipe=getImplParams(this,'InputPipeline');
            outputPipe=getImplParams(this,'outputPipeline');







            if~isempty(triggerPortWidth)
                if~isempty(inputPipe)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:stateflow:triggerPortInPipeConflict',...
                    'InputPipeline',inputPipe));
                end

                if~isempty(outputPipe)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:stateflow:triggerPortOutPipeConflict',...
                    'OutputPipeline',outputPipe));
                end
            end



            if~isempty(triggerPortWidth)||hC.Owner.hasTriggeredInstances
                if(~isempty(sharingFactor)&&(sharingFactor>0))
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:stateflow:triggerPortSharingConflict',...
                    'SharingFactor',sharingFactor));
                end

                badParamName=[];

                if(~isempty(loopOpt)&&strcmp(loopOpt,'Streaming'))
                    badParamName='LoopOptimization';
                end

                if(~isempty(mapRam)&&strcmp(mapRam,'on'))
                    badParamName='MapPersistentVarsToRAM';
                end

                if(~isempty(guardIndex)&&strcmp(guardIndex,'on'))
                    badParamName='GuardIndexVariables';
                end

                if~isempty(varPipe)
                    badParamName='VariablesToPipeline';
                end

                if~isempty(badParamName)
                    v(end+1)=hdlvalidatestruct(1,...
                    message('hdlcoder:stateflow:triggerPortOptimConflict',...
                    badParamName,getImplParams(this,badParamName)));
                end
            end


            msgObj=validateForFloatPorts(this,hC);
            if~isempty(msgObj)
                v(end+1)=hdlvalidatestruct(1,msgObj);
            end


            r=sfroot;
            chartUddH=r.idToHandle(chartId);
            chartParams=chartUddH.find('-isa','Stateflow.Data','Scope','Parameter');
            for ii=1:numel(chartParams)
                paramName=chartParams(ii).Name;
                [~,v1]=hdlimplbase.EmlImplBase.getTunableParameter(hC.SimulinkHandle,paramName);
                if~isempty(v1)
                    v(end+1)=v1;
                end
            end
        end




        function v=baseValidateImplParams(this,hC)





            v=hdlvalidatestruct;

            if~isempty(this.implParams)&&iscell(this.implParams)
                names=this.implParamNames;

                if mod(length(this.implParams),2)~=0
                    v(end+1)=hdlvalidatestruct(2,...
                    message('hdlcoder:stateflow:oddnumimplparams'));
                    this.implParams(end)=[];
                end


                if~isempty(this.implParams)

                    props=this.implParams(1:2:end);
                    notstrings=not(cellfun(@ischar,props));
                    if~isempty(find(notstrings,1))
                        v(end+1)=hdlvalidatestruct(1,...
                        message('hdlcoder:stateflow:nonstringproperty'));
                    end
                end

                for ii=1:2:length(this.implParams)
                    m=strcmpi(names,this.implParams{ii});
                    if~any(m)
                        v(end+1)=hdlvalidatestruct(1,...
                        message('hdlcoder:stateflow:unknownproperty',this.implParams{ii}));
                    elseif sum(m)>1
                        v(end+1)=hdlvalidatestruct(1,...
                        message('hdlcoder:stateflow:nonuniqueproperty'));%#ok<*AGROW>
                    end
                end
            end


            useMatrixTypes=this.getImplParams('UseMatrixTypesInHDL');
            if isempty(useMatrixTypes)
                useMatrixTypes=hdlgetparameter('usematrixtypesineml');
            else
                useMatrixTypes=strcmpi(useMatrixTypes,'on');
            end
            haveMatrixPort=checkMatrixPort(hC.PirInputSignals);
            if~haveMatrixPort
                haveMatrixPort=checkMatrixPort(hC.PirOutputSignals);
            end
            if haveMatrixPort&&~useMatrixTypes
                v(end+1)=hdlvalidatestruct(2,...
                message('hdlcoder:matrix:InconsistentMatrixSettings',hC.Name));
                newParams=[this.implParams,'UseMatrixTypesInHDL','on'];
                this.setImplParams(newParams);
            end
        end




        function v_settings=block_validate_settings(~,~)

            v_settings=struct;

            v_settings.checkretimeblackbox=true;


            v_settings.checksharing=true;


            v_settings.checkserialization=true;

            v_settings.incompatibleforxilinx=true;
            v_settings.incompatibleforaltera=true;
            v_settings.checksingleratesharing=true;
        end


        function hNewC=elaborate(this,hN,hC)

            hNewC=baseSFElaborate(this,hN,hC);
        end


        function generateSLBlock(this,hC,targetBlkPath)













            originalBlkPath=getfullname(hC.SimulinkHandle);

            outputPipelineDelay=getImplParams(this,'OutputPipeline');
            inputPipelineDelay=getImplParams(this,'InputPipeline');

            outDelay=hC.getOptimizationLatency;
            if outDelay>0


                generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,outDelay);
            else

                addBlockAndHilite(this,hC,originalBlkPath,targetBlkPath,...
                inputPipelineDelay,outputPipelineDelay);
            end

            origBdName=bdroot(originalBlkPath);
            origBd=get_param(origBdName,'Object');
            src_machine=origBd.find('-isa','Stateflow.Machine','Name',origBdName,'-depth',1);
            src_target=origBd.find('-isa','Stateflow.Target','Name','sfun','-depth',1);

            targetBdName=bdroot(targetBlkPath);
            targetBd=get_param(targetBdName,'Object');
            gm_machine=targetBd.find('-isa','Stateflow.Machine','Name',targetBdName,'-depth',1);
            gm_target=targetBd.find('-isa','Stateflow.Target','Name','sfun','-depth',1);


            gm_machine.Debug.RunTimeCheck.StateInconsistencies=src_machine.Debug.RunTimeCheck.StateInconsistencies;
            gm_machine.Debug.RunTimeCheck.DataRangeChecks=src_machine.Debug.RunTimeCheck.DataRangeChecks;
            gm_machine.Debug.RunTimeCheck.CycleDetection=src_machine.Debug.RunTimeCheck.CycleDetection;
            gm_machine.Debug.DisableAllBreakpoints=src_machine.Debug.DisableAllBreakpoints;
            gm_machine.Debug.BreakOn.StateEntry=src_machine.Debug.BreakOn.StateEntry;
            gm_machine.Debug.BreakOn.EventBroadcast=src_machine.Debug.BreakOn.EventBroadcast;
            gm_machine.Debug.BreakOn.ChartEntry=src_machine.Debug.BreakOn.ChartEntry;
            gm_machine.Debug.Animation.Delay=src_machine.Debug.Animation.Delay;
            gm_machine.Debug.Animation.Enabled=src_machine.Debug.Animation.Enabled;


            gm_target.ApplyToAllLibs=src_target.ApplyToAllLibs;
            gm_target.ApplyToAllLibs=src_target.ApplyToAllLibs;
            gm_target.CustomCode=src_target.CustomCode;
            gm_target.CustomInitializer=src_target.CustomInitializer;
            gm_target.CustomTerminator=src_target.CustomTerminator;
            gm_target.UserIncludeDirs=src_target.UserIncludeDirs;
            gm_target.UserLibraries=src_target.UserLibraries;
            gm_target.UserSources=src_target.UserSources;
            gm_target.setCodeFlag('debug',src_target.getCodeFlag('debug'));
            gm_target.setCodeFlag('overflow',src_target.getCodeFlag('overflow'));
        end




        function[chartId,machine,isSFChart,isInitOutput,...
            generateResetLogic,concurrencyMaximization,...
            retiming,constMultMode,ramMapping,guardIndex,...
            simIndexCheck,loopOptimization,emitPersistentWarning,...
            variablePipeline,sharingFactor,instantiateFcns,...
            matrixTypes,hasInputEvents,compactSwitch]=getBlockInfo(this,hC)










            chartId=sfprivate('block2chart',hC.simulinkHandle);
            machine=validateAndGetMachine(hC);

            phan=get_param(hC.SimulinkHandle,'PortHandles');



            hasInputEvents=~isempty(phan.Trigger);

            chartH=idToHandle(sfroot,chartId);
            isSFChart=this.isStateflowChart(chartH);
            isInitOutput=isSFChart&&chartH.initializeOutput;
            generateResetLogic=~strcmpi(getImplParams(this,'ResetType'),'None');

            concurrencyMaximization=sf('feature','Attempt fully concurrent code generation for sf/eML blocks');
            emitPersistentWarning=sf('feature','Emit warnings on improper use of persistent vars for HDL code generation');


            constMultiplierOptimMode=getImplParams(this,'ConstMultiplierOptimization');
            if~isempty(constMultiplierOptimMode)
                if strcmpi(constMultiplierOptimMode,'none')
                    constMultMode=0;
                elseif strcmpi(constMultiplierOptimMode,'csd')
                    constMultMode=1;
                elseif strcmpi(constMultiplierOptimMode,'fcsd')
                    constMultMode=2;
                elseif strcmpi(constMultiplierOptimMode,'auto')
                    constMultMode=3;
                else
                    constMultMode=0;
                end
            else
                constMultMode=0;
            end


            retiming=getImplParams(this,'DistributedPipelining');
            retiming=strcmpi(retiming,'on');

            ramMapping=getImplParams(this,'MapPersistentVarsToRAM');
            ramMapping=strcmpi(ramMapping,'on');

            guardIndex=getImplParams(this,'GuardIndex');
            guardIndex=strcmpi(guardIndex,'on');

            loopOptimization=getImplParams(this,'LoopOptimization');

            variablePipeline=getImplParams(this,'VariablesToPipeline');

            sharingFactor=getImplParams(this,'SharingFactor');

            instantiateFcns=getImplParams(this,'InstantiateFunctions');
            instantiateFcns=strcmpi(instantiateFcns,'on');

            simIndexCheck=hdlgetparameter('SimIndexCheck');

            matrixTypes=getImplParams(this,'UseMatrixTypesInHDL');
            if isempty(matrixTypes)
                matrixTypes=hdlgetparameter('usematrixtypesineml');
            else
                matrixTypes=strcmpi(matrixTypes,'on');
            end
            compactSwitch=hdlgetparameter('CompactSwitch');
        end



        function[TunableParamStrs,TunableParamTypes,TunableDataIds]=getTunableProperty(~,chartHandle)

            TunableParamStrs={};
            TunableParamTypes=[];
            TunableDataIds=[];
            chartID=sfprivate('block2chart',chartHandle);
            r=sfroot;
            chartUddH=r.idToHandle(chartID);
            chartParams=chartUddH.find('-isa','Stateflow.Data','Scope','Parameter');
            for ii=1:numel(chartParams)
                paramName=chartParams(ii).Name;
                TunableParamStr=hdlimplbase.EmlImplBase.getTunableParameter(chartHandle,paramName);
                if~isempty(TunableParamStr)
                    if sfprivate('is_eml_chart_block',chartHandle)&&...
                        ~chartParams(ii).Tunable
                        error(message('hdlcoder:validate:TunableParamNotMarked',paramName));
                    end
                    TunableParamStrs{end+1}=TunableParamStr;

                    TunableParamType=getPIRType(chartHandle,chartParams(ii));

                    TunableParamTypes=[TunableParamTypes,TunableParamType];
                    TunableDataIds=[TunableDataIds,chartParams(ii).Id];
                else
                    if sfprivate('is_eml_chart_block',chartHandle)&&...
                        chartParams(ii).Tunable

                        error(message('hdlcoder:validate:SimulinkParamUsage',paramName,chartParams(ii).Path));
                    end
                end
            end
        end

        function[NonTunableParamStrs,NonTunableParamTypes,NonTunableDataIds]=getNonTunableProperty(this,chartHandle)



            filterFcn=@(h,n)isempty(hdlimplbase.EmlImplBase.getTunableParameter(h,n));

            [NonTunableParamStrs,NonTunableParamTypes,NonTunableDataIds]=...
            this.getChartData(chartHandle,'Parameter',filterFcn);

        end

        function[InputStrs,InputTypes,InputIds]=getInputData(this,chartHandle)

            [InputStrs,InputTypes,InputIds]=this.getChartData(chartHandle,'Input');
        end

        function[OutputStrs,OutputTypes,OutputIds]=getOutputData(this,chartHandle)

            [OutputStrs,OutputTypes,OutputIds]=this.getChartData(chartHandle,'Output');
        end

        function[DataStrs,DataTypes,DataIds]=getChartData(~,chartHandle,scopeStr,filterFcn)
            if nargin<4

                filterFcn=@(h,n)true;
            end

            DataStrs={};
            DataTypes=[];
            DataIds=[];
            chartID=sfprivate('block2chart',chartHandle);
            r=sfroot;
            chartUddH=r.idToHandle(chartID);
            chartData=chartUddH.find('-isa','Stateflow.Data','Scope',scopeStr);
            for ii=1:numel(chartData)
                name=chartData(ii).Name;
                if filterFcn(chartHandle,name)
                    DataStrs{end+1}=name;

                    DataType=getPIRType(chartHandle,chartData(ii));

                    DataTypes=[DataTypes,DataType];
                    DataIds=[DataIds,chartData(ii).Id];
                end
            end
        end





        function val=isStateflowChart(~,chartHandle)


            val=isa(chartHandle,'Stateflow.Chart')||isa(chartHandle,'Stateflow.StateTransitionTableChart');

        end



        function optimize=optimizeForModelGen(this,~,~)






            autoPipelineMode=getImplParams(this,'DistributedPipelining');
            if isempty(autoPipelineMode)||strcmpi(autoPipelineMode,'off')
                optimize=true;
            else
                optimize=false;
            end
        end


        function postElab(this,~,hPreElabC,hPostElabC)
            setDelayTags(this,hPreElabC,hPostElabC);
        end


        function registerImplParamInfo(this)

            baseRegisterImplParamInfo(this);
            this.addImplParamInfo('ResetType','ENUM','default',{'default','none'});
            this.addImplParamInfo('DistributedPipelining','ENUM','off',{'on','off'});
            this.addImplParamInfo('MapPersistentVarsToRAM','ENUM','off',{'on','off'});
            this.addImplParamInfo('GuardIndexVariables','ENUM','off',{'on','off'});
            this.addImplParamInfo('ConstMultiplierOptimization','ENUM','none',{'csd','fcsd','auto','none'});
            this.addImplParamInfo('LoopOptimization','ENUM','none',{'none','Unrolling','Streaming'});
            this.addImplParamInfo('VariablesToPipeline','STRING','');
            this.addImplParamInfo('SharingFactor','POSINT',0);
            this.addImplParamInfo('InstantiateFunctions','ENUM','off',{'on','off'});
            this.addImplParamInfo('UseMatrixTypesInHDL','ENUM','on',{'on','off'});
            if strcmpi(hdlfeature('CustomBlockElabScript'),'on')
                this.addImplParamInfo('CustomBlockElabScript','STRING','');
            end






            this.addImplParamInfo('FlattenHierarchy','ENUM','off',{'on','off'});
        end





        function[v]=validate(this,hC)

            v=baseSFValidate(this,hC);

        end


        function[msgObj]=validateForFloatPorts(~,hC)



            msgObj=[];
            if targetcodegen.targetCodeGenerationUtils.isNFPMode
                allPorts=[hC.PirInputSignals;hC.PirOutputSignals];
                for itr=1:numel(allPorts)
                    refType=allPorts(itr).Type.getLeafType;
                    if refType.isFloatType
                        msgObj=message('hdlcommon:nativefloatingpoint:Nfp_unsupported_block',getfullname(hC.SimulinkHandle));


                        return;
                    elseif refType.isRecordType
                        memberTypes=refType.MemberTypesFlattened;
                        for ii=1:numel(memberTypes)
                            if memberTypes(ii).getLeafType.isFloatType
                                msgObj=message('hdlcommon:nativefloatingpoint:Nfp_unsupported_block',getfullname(hC.SimulinkHandle));


                                return;
                            end
                        end
                    end
                end
            end
        end


        function v=validateSinglerateSharing(this,~,~)

            maxOversampling=hdlgetparameter('maxoversampling');
            loopOptimization=getImplParams(this,'LoopOptimization');
            loopStreaming=strcmpi(loopOptimization,'Streaming');
            ramMapping=getImplParams(this,'MapPersistentVarsToRAM');
            ramMapping=strcmpi(ramMapping,'on');
            sharingFactor=getImplParams(this,'SharingFactor');
            sharingOn=~isempty(sharingFactor)&&sharingFactor>1;
            singleratesharing=maxOversampling==1;

            v=hdlvalidatestruct;
            if singleratesharing&&loopStreaming
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:singlerateloopstreaming'));
            end

            if singleratesharing&&ramMapping
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:singleraterammapping'));
            end

            if singleratesharing&&sharingOn
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:singleratemlsharing'));
            end
        end




    end

end

function id=getSysId(handle)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    id=getSystemNumber(get_param(handle,'object'));
    delete(sess);
end

function codegenEntityName=getEntityName(entityName,chartHandle)
    chartID=sfprivate('block2chart',chartHandle);
    r=sfroot;
    chartUddH=r.idToHandle(chartID);

    if chartUddH.machine.IsLibrary
        codegenEntityName=getSafeLibChartName(chartID,chartHandle);
    else
        codegenEntityName=entityName;
    end
end


function safeName=getSafeLibChartName(chart,chartHandle)
    maxLength=namelengthmax;
    machine=sf('get',chart,'chart.machine');
    chartFileNumber=sf('get',chart,'chart.chartFileNumber');
    modelName=sf('get',machine,'machine.name');
    blockH=sfprivate('chart2block',chart);
    blockName=regexprep(get_param(blockH,'name'),'[^\w]','_');

    specs=sf('Cg','get_module_specializations',chart);
    if length(specs)>1
        mainMachineName=get_param(bdroot(chartHandle),'Name');
        sf('SelectChartIDCInfoByMachine',chart,mainMachineName);
        specStr=sf('SFunctionSpecialization',chart,chartHandle);
        safeName=sprintf('%s_c%d_%s',modelName,chartFileNumber,specStr);
    else
        safeName=sprintf('%s_c%d',modelName,chartFileNumber);
    end

    if(length(safeName)<maxLength)
        safeName=[safeName,'_',blockName];
        if(length(safeName)>maxLength)
            safeName=safeName(1:maxLength);
        end
    end
end


function result=checkChartSettings(this,chartH)
    result=[];
    if this.isStateflowChart(chartH)

        if chartH.exportChartFunctions==1
            result=[result,hdlvalidatestruct(1,message('hdlcoder:stateflow:badexportfunctions'))];
        end

        if(strcmpi(chartH.StateMachineType,'Moore'))&&(chartH.InitializeOutput~=1)
            hDriver=hdlcurrentdriver;


            if~(hDriver.getParameter('SplitMooreChartStateUpdate'))
                result=[result,hdlvalidatestruct(1,message('hdlcoder:stateflow:badinitoutput',hDriver.ModelName))];
            end
        end
    end
end

function[isStruct,isComplex,dims]=getChartParamParsedProps(chartParam,slBH)
    parsedInfo=sf('DataParsedInfo',chartParam.Id,slBH);
    isStruct=strcmp(parsedInfo.type.baseStr,'structure');
    isComplex=parsedInfo.complexity;
    dims=parsedInfo.size;
end


function result=checkChartParameters(chartH,slbh)
    result=[];
    chartParams=chartH.find('-isa','Stateflow.Data','Scope','Parameter');
    for ii=1:numel(chartParams)
        if chartParams(ii).Tunable
            if~sfprivate('is_eml_chart_block',slbh)
                [isStruct,isComplex,dims]=...
                getChartParamParsedProps(chartParams(ii),slbh);
                if isStruct
                    msg=message('hdlcoder:stateflow:unsupportedparamstruct',...
                    chartParams(ii).Name,chartParams(ii).Path);
                    result=[result,hdlvalidatestruct(1,msg)];
                end
                if isComplex
                    msg=message('hdlcoder:stateflow:unsupportedparamcomplex',...
                    chartParams(ii).Name,chartParams(ii).Path);
                    result=[result,hdlvalidatestruct(1,msg)];
                end
                if~isempty(dims)
                    msg=message('hdlcoder:stateflow:unsupportedparamarray',...
                    chartParams(ii).Name,chartParams(ii).Path);
                    result=[result,hdlvalidatestruct(1,msg)];
                end

            end
        end
    end
end



function result=checkForSimulinkFunctions(chartH)
    result=[];
    slfHandles=chartH.find('-isa','Stateflow.SLFunction','IsExplicitlyCommented',false,'IsImplicitlyCommented',false);
    if~isempty(slfHandles)
        for ii=1:numel(slfHandles)
            msg=message('hdlcoder:stateflow:SLFunctionUnsupported',...
            [slfHandles(ii).Path,'/',slfHandles(ii).Name]);
            result=[result,hdlvalidatestruct(1,msg)];
        end
    end
end



function result=checkForAtomicSubcharts(chartH)
    result=[];
    ascHandles=chartH.find('-isa','Stateflow.AtomicSubchart','IsExplicitlyCommented',false,'IsImplicitlyCommented',false);
    if~isempty(ascHandles)
        for ii=1:numel(ascHandles)
            msg=message('hdlcoder:stateflow:AtomicSubchartUnsupported',...
            [ascHandles(ii).Path,'/',ascHandles(ii).Name]);
            result=[result,hdlvalidatestruct(1,msg)];
        end
    end
end


function result=checkRates(hNIC)
    result=[];
    numInstances=length(hNIC);
    for i=1:numInstances
        current=hNIC(i);
        sigs=[current.PirInputSignals;current.PirOutputSignals];
        ratesMatch=checkSignalRates(sigs);
        if~ratesMatch
            result=hdlvalidatestruct(1,message('hdlcoder:stateflow:mismatchedRates'));
        end
    end
end



function allMatch=checkSignalRates(signals)
    allMatch=true;
    singleRate=[];
    if~isempty(signals)
        for i=1:length(signals)
            currentRate=signals(i).SimulinkRate;
            if~isinf(currentRate)&&currentRate~=-1
                if isempty(singleRate)
                    singleRate=currentRate;
                else
                    if currentRate~=singleRate
                        allMatch=false;
                        break;
                    end
                end
            end
        end
    end
end


function v=checkStateflowSettings(this,v)


    varpipes=getImplParams(this,'VariablesToPipeline');
    if~isempty(varpipes)
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:VariablePipelineUnsupported'));
    end

    ramMapping=getImplParams(this,'MapPersistentVarsToRAM');
    if~isempty(ramMapping)&&~strcmpi(ramMapping,'off')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:UnsupportedOptim','MapPersistentVarsToRAM'));
    end

    guardIndex=getImplParams(this,'GuardIndexVariables');
    if~isempty(guardIndex)&&~strcmpi(guardIndex,'off')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:UnsupportedOptim','GuardIndexVariables'));
    end


    loopopts=getImplParams(this,'LoopOptimization');
    if~isempty(loopopts)&&strcmpi(loopopts,'Streaming')
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:LoopStreamingUnsupported'));
    end

    sharing=getImplParams(this,'SharingFactor');
    if~isempty(sharing)&&sharing>1
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:stateflow:SharingUnsupported'));
    end

end




function v=warnIfStateFlowTestpointsPresent(~,chartH,v)
    States=chartH.find('-isa','Stateflow.State');
    for ii=1:length(States)
        if(States(ii).Testpoint)
            msgObj=message('hdlcoder:stateflow:featureTestpointIgnoresStateTestpoint');
            v(end+1)=hdlvalidatestruct(2,msgObj);
            return;
        end
    end
end

function haveMatrixPort=checkMatrixPort(portSigs)
    haveMatrixPort=false;
    for ii=1:numel(portSigs)
        hT=portSigs(ii).Type;
        if hT.isMatrix
            haveMatrixPort=true;
            break;
        end
    end
end
function addBlockAndHilite(this,hC,originalBlkPath,targetBlkPath,...
    inputPipelineDelay,outputPipelineDelay)

    uniqueName=targetBlkPath;

    if getSimulinkBlockHandle(uniqueName)~=-1
        suffix='_chart';
        uniqueName=[uniqueName,suffix];
        hC.Name=[hC.Name,suffix];
    end
    newBlockHandle=add_block(originalBlkPath,uniqueName);
    targetParentPath=get_param(uniqueName,'Parent');

    hdlimplbase.EmlImplBase.addTunablePortsFromParams(newBlockHandle);


    [turnhilitingon,color]=this.getHiliteInfo(hC);
    if((~isempty(inputPipelineDelay)&&inputPipelineDelay>0)...
        ||(~isempty(outputPipelineDelay)&&outputPipelineDelay>0))...
        &&turnhilitingon
        set_param(targetParentPath,'BackgroundColor',color);
    end
end
function machine=validateAndGetMachine(hC)
    modelH=get_param(bdroot(hC.simulinkHandle),'handle');
    machine=sf('find','all','machine.simulinkModel',modelH);
    assert(length(machine)==1,'Failed to get machine from Stateflow block.');
end

function type=getPIRType(chartHandle,chartParam)
    sigType=chartParam.CompiledType;
    [isStruct,isComplex,dims]=...
    getChartParamParsedProps(chartParam,chartHandle);
    portDims=1;
    if~isempty(dims)
        portDims=dims;
    end

    if isStruct
        type=getStructType(chartParam.CompiledType,chartHandle);
        if isempty(type)


            if chartParam.Tunable

                error(message('hdlcoder:validate:SimulinkBusUsage',chartParam.Name,chartParam.DataType));
            else


                rtf=hdlcoder.tpc_rec_factory;
                type=hdlcoder.tp_record(rtf);
            end
        end
    else
        type=getpirsignaltype(sigType,isComplex,portDims);
    end
end

function pirrecord=getStructType(baseTypeName,chartHandle)
    pirrecord=[];
    if ischar(baseTypeName)&&...
        any(arrayfun(@(z)(strcmp(z.name,baseTypeName)),evalin('base','whos')))
        obj=evalin('base',baseTypeName);
        if isa(obj,'Simulink.Bus')
            rtf=hdlcoder.tpc_rec_factory;
            rtf.setRecordName(baseTypeName);
            for ii=1:length(obj.Elements)
                elemt=obj.Elements(ii);
                name=elemt.Name;
                isComplex=strcmpi(elemt.Complexity,'complex');
                type=elemt.DataType;
                dims=elemt.Dimensions;
                if strncmpi(type,'Bus:',4)
                    signalType=getStructType(strtrim(type(5:end)),chartHandle);
                else
                    try
                        dtObj=slResolve(type,chartHandle);
                        if isa(dtObj,'Simulink.Bus')

                            signalType=getStructType(type,chartHandle);
                        elseif strcmpi(dtObj.DataTypeMode,'Double')
                            signalType=getpirsignaltype('double',isComplex,dims);
                        elseif strcmpi(dtObj.DataTypeMode,'Single')
                            signalType=getpirsignaltype('single',isComplex,dims);
                        else
                            [~,sltype]=hdlgettypesfromsizes(dtObj.WordLength,...
                            dtObj.FractionLength,strcmpi(dtObj.Signedness,'Signed'));
                            signalType=getpirsignaltype(sltype,isComplex,dims);
                        end
                    catch e
                        if strcmp(e.identifier,'Simulink:Data:SlResolveNotResolved')

                            signalType=getpirsignaltype(type,isComplex,dims);
                        else
                            error(e.message)
                        end
                    end
                end
                rtf.addMember(name,signalType);
            end
            pirrecord=hdlcoder.tp_record(rtf);
        end
    end
end






