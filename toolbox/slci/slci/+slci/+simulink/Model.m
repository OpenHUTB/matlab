


classdef Model<slci.common.BdObject

    properties(Access=private)
        fBlocks={};
        fAutodoc=false;
        enumConstraintsMap=[];
        blockTypeBlocksMap=[];
        fFoundVars=[];
        fBlocksToVars=[];
        fCheckAsRefModel=false;
        fInspectSharedUtils=false;
        blockTypeToBlockIdx=[];
        isRefreshed=false;
        fCharts={};
        fHandle=[];
        fSystemHandle=[];
        fSystemName=[];
        fSidToBlocks;
        fWSVarInfoTable=[];
        fDataTypeTable=[];


        fCompiledSLFcnTable=[];
        fIsCompiledSLFcnTableBuilt=false;

        fSimulinkFunctionHdls=[];
        fSLFcnCallerToFuncMap=[];
    end

    methods(Access=private)



        function unsupportedSubsystems=getUnsupportedSubsystems(aObj)
            unsupportedSubsystems={};
            subsystems=aObj.getBlockType('SubSystem');
            for i=1:numel(subsystems)
                blkH=subsystems{i}.getHandle();
                maskType=get_param(blkH,'MaskType');
                unsupported=false;
                if slci.internal.isUnsupportedStateflowBlock(blkH)
                    unsupported=true;
                elseif~slci.internal.isSupportedMaskType(maskType)
                    unsupported=true;
                elseif slci.simulink.Model.isCustomCodeBlock(subsystems{i}.getSID())
                    unsupported=true;
                end

                if unsupported
                    unsupportedSubsystems{end+1}=subsystems{i};%#ok<AGROW>;
                end
            end
        end

        function listSupportedBlocks(aObj)%#ok
            blockTypes=slci.compatibility.getSupportedBlockTypes();
            disp('Supported block types:')
            for i=1:numel(blockTypes)
                disp(['   ',blockTypes{i}])
            end
        end


        function setCompiledSLFcnTable(aObj)
            assert(~aObj.fIsCompiledSLFcnTableBuilt);
            aObj.fCompiledSLFcnTable=containers.Map('KeyType','double',...
            'ValueType','any');
            aObj.fSLFcnCallerToFuncMap=slci.internal.populateCompiledSimulinkFunction(...
            aObj);
            aObj.fIsCompiledSLFcnTableBuilt=true;
        end

        function addModelParameterConstraints(aObj)
            ertTargetConstraint=slci.compatibility.ERTTargetConstraint;
            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'GenerateAllocFcn','off');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'UtilityFuncGeneration','Shared location'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'CustomSourceCode',''));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'CustomHeaderCode',''));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'CustomInitializer',''));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'CustomTerminator',''));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'AdvancedOptControl','-SLCI'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'BooleanDataType','on'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'CombineSignalStateStructs','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'UseRowMajorAlgorithm','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ArrayLayout','Column-major'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'EfficientFloat2IntCast','on'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'EfficientMapNaN2IntZero','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            true,'GenerateComments','on'));
            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'PreserveIfCondition','on');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'CodeReplacementLibrary','None'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'TargetLangStandard',...
            'C89/C90 (ANSI)','C99 (ISO)'));
            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'GRTInterface','off');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'IncludeMdlTerminateFcn','off');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'NoFixptDivByZeroProtection','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'MatFileLogging','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'BooleansAsBitfields','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'StateBitsets','off'));
            aObj.addConstraint(slci.compatibility.PositiveModelParameterConstraint(...
            false,'SupportNonFinite','off'));
            aObj.addConstraint(slci.compatibility.PositiveModelParameterConstraint(...
            false,'SupportAbsoluteTime','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'BitwiseOrLogicalOp','Same as modeled','Bitwise operator'));


            aObj.addConstraint(...
            slci.compatibility.PositiveModelRefParameterConstraint(...
            false,'DefaultParameterBehavior','Inlined'));


solverTypeConstraint...
            =slci.compatibility.PositiveModelParameterConstraint(...
            false,'SolverType','Fixed-step');
            aObj.addConstraint(solverTypeConstraint);

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'Solver','FixedStepDiscrete'));



sampleTimeConstraint...
            =slci.compatibility.PositiveModelParameterConstraint(...
            false,'SampleTimeConstraint','Unconstrained','STIndependent');


            sampleTimeConstraint.addPreRequisiteConstraint(solverTypeConstraint);
            aObj.addConstraint(sampleTimeConstraint);

enableMultiTaskingConstraint...
            =slci.compatibility.EnableMultiTaskingConstraint();
            enableMultiTaskingConstraint.addPreRequisiteConstraint(sampleTimeConstraint);
            aObj.addConstraint(enableMultiTaskingConstraint);

autoInsertRateTranBlkConstraint...
            =slci.compatibility.AutoInsertRateTranBlkConstraint(false,'AutoInsertRateTranBlk','off');
            autoInsertRateTranBlkConstraint.addPreRequisiteConstraint(sampleTimeConstraint);
            aObj.addConstraint(autoInsertRateTranBlkConstraint);


            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'MultiTaskDSMMsg','error'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'MultiTaskRateTransMsg','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'MultiTaskCondExecSysMsg','error'));


            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'AlgebraicLoopMsg','error'));

            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'SuppressErrorStatus','on');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'UnderspecifiedInitializationDetection','Simplified'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            true,'NonBusSignalsTreatedAsBus','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ParameterDowncastMsg','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ParameterOverflowMsg','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'IntegerOverflowMsg','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'IntegerSaturationMsg','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ParameterUnderflowMsg','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ParameterTunabilityLossMsg','error'));
            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'CreateSILPILBlock','none');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'CodeProfilingInstrumentation','off');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'LoadInitialState','off'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'AllowSymbolicDim','off'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SignalNamingRule','None'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ParamNamingRule','None'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'TLCOptions','','-aMaxStackVariableSize=inf'));


            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ModelReferenceIOMsg','error'));

            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerChar','8'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerShort','16'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerInt','32'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerLong','32'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerFloat','32'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerDouble','64'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerPointer','32'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerSizeT','32'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdBitPerPtrDiffT','32'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdWordSize','32'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdIntDivRoundTo','Zero'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdShiftRightIntArith','on'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdLongLongMode','off'));
            aObj.addConstraint(...
            slci.compatibility.HardwareModelParameterConstraint(...
            false,'ProdEqTarget','on'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            true,'SupportVariableSizeSignals','off'));


            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'CombineOutputUpdateFcns','on');
            constraint.addPreRequisiteConstraint(...
            slci.compatibility.ERTTargetConstraint);
            aObj.addConstraint(constraint);


sampleERTMainConstraint...
            =slci.compatibility.SampleERTMainConstraint();
            aObj.addConstraint(sampleERTMainConstraint);


            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SFUnexpectedBacktrackingDiag','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SFInvalidInputDataAccessInChartInitDiag','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SFNoUnconditionalDefaultTransitionDiag','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SFTransitionOutsideNaturalParentDiag','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SFUnreachableExecutionPathDiag','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SFUndirectedBroadcastEventsDiag','error'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'SFTransitionActionBeforeConditionDiag','error'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'DataBitsets','off'));
            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'CastingMode','Nominal','Standards'));
            constraint=slci.compatibility.PositiveModelParameterConstraint(...
            false,'SuppressUnreachableDefaultCases','off');
            constraint.addPreRequisiteConstraint(...
            slci.compatibility.ERTTargetConstraint);
            aObj.addConstraint(constraint);

            aObj.addConstraint(slci.compatibility.MatlabCodeAnalyzerConstraint);



            aObj.addConstraint(...
            slci.compatibility.DeviceVendorParameterConstraint(...
            false,'ProdHWDeviceType','ASIC/FPGA->ASIC/FPGA'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelConcurrentTasksConstraint(...
            false,'ConcurrentTasks','off'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'UseSpecifiedMinMax','off'));

            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ExistingSharedCode',''));

            aObj.addConstraint(...
            slci.compatibility.DataExchangeInterfaceParameterConstraint(...
            false,'RTWCAPIParams','off'));
            aObj.addConstraint(...
            slci.compatibility.DataExchangeInterfaceParameterConstraint(...
            false,'RTWCAPISignals','off'));
            aObj.addConstraint(...
            slci.compatibility.DataExchangeInterfaceParameterConstraint(...
            false,'RTWCAPIStates','off'));
            aObj.addConstraint(...
            slci.compatibility.DataExchangeInterfaceParameterConstraint(...
            false,'RTWCAPIRootIO','off'));
            aObj.addConstraint(...
            slci.compatibility.DataExchangeInterfaceParameterConstraint(...
            false,'ExtMode','off'));

            constraint=...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'RateTransitionBlockCode','Inline');
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);


            aObj.addConstraint(...
            slci.compatibility.PositiveModelParameterConstraint(...
            false,'ReuseModelBlockBuffer','off'));

            constraints=aObj.getConstraints;
            [configMapTemp,~]=slciprivate('SLCIConfigMap');
            for i=1:numel(constraints)
                if(isa(constraints{i},'slci.compatibility.PositiveModelParameterConstraint')||...
                    isa(constraints{i},'slci.compatibility.NegativeModelParameterConstraint'))
                    if isKey(configMapTemp,constraints{i}.getParameterName())
                        ui=configMapTemp(constraints{i}.getParameterName());
                        constraints{i}.setEnum(ui{end});
                    else
                        [~,~,~,~,ParentPane]=getConfigParamDetails(aObj,constraints{i}.getParameterName());
                        constraints{i}.setEnum(ParentPane);
                    end
                end
            end
        end




        function out=computeFixedStep(aObj)
            mdlH=aObj.getHandle();
            mdlUddObj=get_param(mdlH,'Object');
            oldF=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
            try
                sampleTimeValues=mdlUddObj.getSampleTimeValues;
            catch
                sampleTimeValues=[];
            end
            slfeature('EngineInterface',oldF);
            if~isempty(sampleTimeValues)
                out=sampleTimeValues(1);
            else
                startTime=get_param(mdlH,'StartTime');
                stopTime=get_param(mdlH,'StopTime');
                if strcmpi(stopTime,'Inf')
                    out=0.2;
                else
                    out=(str2double(stopTime)-str2double(startTime))/50;
                end
            end
        end


        function loaded=isLoaded(~,mdl_name)
            loaded=~isempty(find_system('flat','Name',mdl_name));
        end

    end

    methods


        function obj=Model(aMdlHdl,varargin)

            obj.fSidToBlocks=containers.Map;

            if nargin>1&&strcmpi(varargin{1},'autodoc')
                obj.fAutodoc=true;
            end
            if ischar(aMdlHdl)
                obj.setSystemHandle(get_param(aMdlHdl,'Handle'));
                obj.setSystemName(aMdlHdl);
                obj.setHandle(get_param(bdroot(aMdlHdl),'Handle'));
                modelName=bdroot(aMdlHdl);
            else
                obj.setSystemHandle(aMdlHdl);
                obj.setSystemName(get_param(aMdlHdl,'Name'));
                modelName=bdroot(get_param(aMdlHdl,'Name'));
                obj.setHandle(get_param(modelName,'Handle'));
            end
            obj.setName(modelName);
            obj.setUDDObject(get_param(aMdlHdl,'Object'));
            obj.setSID(Simulink.ID.getSID(obj.getHandle()));
            obj.cacheBlockData;





            if slcifeature('SlciLevel1Checks')==1
                obj.cachePropagatedDatatypes();
            end
        end


        function cachePropagatedDatatypes(aObj)

            aObj.fDataTypeTable=containers.Map('KeyType','double',...
            'ValueType','any');

            if exist('SLCIPropDataTypes.mat','file')
                data=load('SLCIPropDataTypes');
                pt=data.PropagatedTypes;
                for i=1:numel(pt)

                    assert(numel(pt{i})==2);


                    hKey=pt{i}{1};


                    tValue=pt{i}{2};


                    aObj.fDataTypeTable(hKey)=tValue;
                end
            end
        end


        function out=getPortDatatype(aObj,blkH)
            out=[];
            if(aObj.fDataTypeTable.isKey(blkH))
                out=aObj.fDataTypeTable(blkH);
            end
        end

        function out=ParentModel(aObj)
            out=aObj;
        end

        function out=getSystemHandle(aObj)
            out=aObj.fSystemHandle;
        end

        function setSystemHandle(aObj,aHandle)
            aObj.fSystemHandle=aHandle;
        end

        function out=getSystemName(aObj)
            out=aObj.fSystemName;
        end

        function setSystemName(aObj,aName)
            aObj.fSystemName=aName;
        end


        function out=getFundamentalStepSize(aObj)
            solverType=strtrim(get_param(aObj.getSystemName,'SolverType'));
            sampleTimeConstraint=strtrim(get_param(aObj.getSystemName,'SampleTimeConstraint'));
            if(strcmpi(solverType,'Fixed-step')...
                &&strcmpi(sampleTimeConstraint,'Unconstrained'))
                fixedStep=strtrim(get_param(aObj.getSystemName,'FixedStep'));

                if strcmpi(fixedStep,'auto')
                    out=aObj.computeFixedStep();
                else
                    out=slci.internal.getValue(fixedStep,...
                    'double',...
                    aObj.getSID());
                end
            else
                out=aObj.computeFixedStep();
            end
            assert(~isnan(out)&&~isempty(out));
        end


        function blkObj=getBlockObject(aObj,blkHandle)
            blkSID=Simulink.ID.getSID(blkHandle);
            if isKey(aObj.fSidToBlocks,blkSID)
                blkObj=aObj.fSidToBlocks(blkSID);
            else
                blkObj=[];
            end
        end

        function AddConstraints(aObj)
            aObj.addConstraint(...
            slci.compatibility.StateflowMachineDataConstraint);
            aObj.addConstraint(...
            slci.compatibility.StateflowMachineEventsConstraint);
            aObj.addConstraint(...
            slci.compatibility.StrictBusMsgConstraint);
            aObj.addConstraint(...
            slci.compatibility.HiddenBusConversionConstraint);
            aObj.addConstraint(...
            slci.compatibility.HiddenBufferBlockConstraint);
            ertTargetConstraint=slci.compatibility.ERTTargetConstraint;
            aObj.addConstraint(ertTargetConstraint);
            constraint=slci.compatibility.BusRootOutportConstraint;
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.SynthLocalDSMConstraint);
            aObj.addConstraint(...
            slci.compatibility.GlobalDSMConstraint);
            aObj.addConstraint(...
            slci.compatibility.GlobalDSMShadowConstraint);
            aObj.addConstraint(...
            slci.compatibility.ConstantRootOutportConstraint);
            aObj.addConstraint(...
            slci.compatibility.StructureStorageClassConstraint);
            aObj.addConstraint(...
            slci.compatibility.MinMaxLoggingConstraint);
            SDPWorkflowCsontraint=slci.compatibility.SDPWorkflowConstraint;
            aObj.addConstraint(SDPWorkflowCsontraint);
            constraint=slci.compatibility.WorkspaceVarConstraint;
            constraint.addPreRequisiteConstraint(SDPWorkflowCsontraint);
            aObj.addConstraint(constraint);
            constraint=slci.compatibility.GetSetVarConstraint;
            constraint.addPreRequisiteConstraint(SDPWorkflowCsontraint);
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.ConditionallyExecuteInputsConstraint);
            aObj.addConstraint(...
            slci.compatibility.EnabledConditionallyExecuteInputsConstraint);
            aObj.addConstraint(...
            slci.compatibility.BlockPortsConnectedConstraint);
            aObj.addConstraint(...
            slci.compatibility.UnsupportedBlockTypeConstraint);
            constraint=slci.compatibility.FuncProtoCtrlConstraint;
            constraint.addPreRequisiteConstraint(ertTargetConstraint);
            aObj.addConstraint(constraint);
            aObj.addConstraint(...
            slci.compatibility.SampleTimesConstraint);
            aObj.addConstraint(...
            slci.compatibility.ExplicitPartitionsConstraint);
            aObj.addConstraint(...
            slci.compatibility.BusExpansionConstraint);
            aObj.addConstraint(...
            slci.compatibility.SeparateOutputAndUpdateConstraint);
            aObj.addModelParameterConstraints();
            aObj.addConstraint(...
            slci.compatibility.RollThresholdConstraint);
            aObj.addConstraint(...
            slci.compatibility.PassReuseOutputArgsAsConstraint);


            aObj.addConstraint(...
            slci.compatibility.OutportTerminatorConstraint);

            aObj.addConstraint(...
            slci.compatibility.FirstInitICPropagationConstraint());

            aObj.addConstraint(...
            slci.compatibility.DataTypeReplacementNameConstraint());

            aObj.addConstraint(...
            slci.compatibility.CommentedBlocksConstraint);

            aObj.addConstraint(...
            slci.compatibility.RefModelMultirateConstraint);
            aObj.addConstraint(...
            slci.compatibility.VVSubSystemNameConstraint);
            aObj.addConstraint(...
            slci.compatibility.ReuseSubSystemLibraryConstraint);

            aObj.addConstraint(...
            slci.compatibility.LookupndBreakpointsDataTypeConstraint);

            aObj.addConstraint(...
            slci.compatibility.SharedSynthLocalDSMConstraint);



            aObj.addConstraint(...
            slci.compatibility.CodeGenFolderStructureConstraint);

            aObj.addConstraint(...
            slci.compatibility.CodeMappingDefaultsConstraint);


            aObj.addConstraint(...
            slci.compatibility.BlockSortedOrderConstraint);
            aObj.addConstraint(...
            slci.compatibility.SharedUtilitiesSymbolsConstraint);
            aObj.addConstraint(...
            slci.compatibility.SharedUtilitiesTargetLangStandardConstraint);
            aObj.addConstraint(...
            slci.compatibility.SharedUtilitiesCodeStyleConstraint);
            aObj.addConstraint(...
            slci.compatibility.SharedUtilitiesPortableWordSizesConstraint);


            aObj.constructEnumConstraintsMap();
        end

        function cacheBlockData(obj)
            obj.fBlocks={};
            obj.fCharts={};
            obj.fSidToBlocks=containers.Map;
            obj.blockTypeBlocksMap=containers.Map;
            obj.blockTypeToBlockIdx=[];
            obj.fSimulinkFunctionHdls=[];
            mdlBlocks=slci.internal.find_blocks_except_sf(obj.getSystemHandle());


            numBlks=numel(mdlBlocks);
            if numBlks==1
                mdlBlkSID={Simulink.ID.getSID(mdlBlocks)};
            else
                mdlBlkSID=Simulink.ID.getSID(mdlBlocks);
            end

            if numBlks<65500
                blockTypeidx=uint16(0);
            else
                blockTypeidx=uint32(0);
            end


            for blockIdx=1:numBlks
                blkSID=mdlBlkSID{blockIdx};
                try
                    blkHdl=get_param(blkSID,'handle');
                catch


                    continue;
                end
                if strcmpi(get_param(blkHdl,'BlockType'),'SubSystem')&&...
                    strcmpi(slci.internal.getSubsystemType(...
                    get_param(blkHdl,'Object')),'simulinkfunction')
                    obj.fSimulinkFunctionHdls{end+1}=blkHdl;
                end
            end
            for blockIdx=1:numBlks
                blkSID=mdlBlkSID{blockIdx};
                try
                    mdlBlock=get_param(blkSID,'handle');
                catch
                    continue;
                end



                if strcmp(get_param(mdlBlock,'BlockType'),'Ground')
                    p=get_param(mdlBlock,'parent');
                    if(strcmp(get_param(p,'Type'),'block')&&~isempty(get_param(p,'TemplateBlock')))
                        continue;
                    end
                end
                blockType=slci.internal.isSupportedSFunction(mdlBlock);
                mdlBlockObj=get_param(mdlBlock,'Object');
                if isempty(blockType)&&...
                    strcmpi(get_param(mdlBlock,'BlockType'),'SubSystem')
                    subSystemType=slci.internal.getSubsystemType(mdlBlockObj);
                    if strcmpi(subSystemType,'Action')

                        blockType='ActionSubSystem';
                    elseif strcmpi(subSystemType,'simulinkfunction')


                        blockType='SimulinkFunction';
                    end
                end
                if isempty(blockType)
                    blockType=strrep(get_param(mdlBlock,'BlockType'),'-','_');
                end
                blockClass=['slci.simulink.',blockType,'Block'];
                if isempty(meta.class.fromName(blockClass))
                    obj.fBlocks{end+1}=slci.simulink.UnsupportedBlock(mdlBlock,obj);
                    blockType='Unsupported';
                else




                    if obj.fAutodoc&&...
                        strcmpi(get_param(mdlBlock,'Name'),'allBlocks')
                        cmd='obj.fBlocks{end+1} = slci.simulink.Block(mdlBlock, obj);';
                    else
                        cmd=['obj.fBlocks{end+1} = ',blockClass,'(mdlBlock, obj);'];
                    end
                    eval(cmd);
                end

                thisBlock=obj.fBlocks{end};
                obj.fSidToBlocks(thisBlock.getSID)=thisBlock;

                if~isKey(obj.blockTypeBlocksMap,blockType)
                    blockTypeidx=blockTypeidx+1;
                    obj.blockTypeBlocksMap(blockType)=blockTypeidx;
                    obj.blockTypeToBlockIdx{blockTypeidx}(1)=blockTypeidx;
                    obj.blockTypeToBlockIdx{blockTypeidx}(2)=numel(obj.fBlocks);
                else
                    obj.blockTypeToBlockIdx{obj.blockTypeBlocksMap(blockType)}(end+1)=numel(obj.fBlocks);
                end
            end
        end

        function refreshBlkCache(aObj)
            aObj.cacheBlockData();
            aObj.isRefreshed=true;
        end

        function flag=getRefreshed(aObj)
            flag=aObj.isRefreshed;
        end

        function setRefreshed(aObj,flag)
            aObj.isRefreshed=flag;
        end

        function constructEnumConstraintsMap(aObj)
            aObj.enumConstraintsMap=containers.Map;
            modelConstraints=aObj.getConstraints;
            for i=1:numel(modelConstraints)
                enum=modelConstraints{i}.getEnum;
                if~isKey(aObj.enumConstraintsMap,enum)
                    aObj.enumConstraintsMap(enum)={modelConstraints{i}};
                else
                    temp=aObj.enumConstraintsMap(enum);
                    temp{end+1}=modelConstraints{i};%#ok<AGROW> OPTIMIZE?
                    aObj.enumConstraintsMap(enum)=temp;
                end
            end
        end

        function out=getAutodoc(aObj)
            out=aObj.fAutodoc;
        end

        function out=getWSVarInfoTable(aObj)
            if~isa(aObj.fWSVarInfoTable,'containers.Map')


                BOTH_TOP_REF=2;

                fParamsTab=containers.Map;
                [aObj.fWSVarInfoTable,~]=...
                slci.internal.buildWSVarInfoStructFieldsTables(...
                aObj.ParentModel().getName(),BOTH_TOP_REF,...
                fParamsTab);
            end
            out=aObj.fWSVarInfoTable;
        end

        function out=getVars(aObj)
            if isempty(aObj.fFoundVars)
                aObj.fFoundVars=...
                containers.Map('KeyType','char','ValueType','any');
                vars=...
                Simulink.findVars(aObj.getName(),'SearchMethod','cached');
                for i=1:numel(vars)
                    varName=vars(i).Name;
                    if aObj.fFoundVars.isKey(varName)
                        aObj.fFoundVars(varName)=...
                        [aObj.fFoundVars(varName),vars(i)];
                    else
                        aObj.fFoundVars(varName)=vars(i);
                    end
                end
            end
            out=aObj.fFoundVars;
        end

        function out=getVarsForBlock(aObj,aSid)
            out=[];
            if isempty(aObj.fBlocksToVars)
                aObj.fBlocksToVars=containers.Map;
                foundVars=aObj.getVars();
                varNames=foundVars.keys();
                for i=1:numel(varNames)
                    foundVar=foundVars(varNames(i));
                    for j=1:numel(foundVar.UsedByBlocks)
                        blkPath=foundVar.UsedByBlocks{j};
                        blkSid=Simulink.ID.getSID(blkPath);
                        if~isKey(aObj.fBlocksToVars,blkSid)
                            aObj.fBlocksToVars(blkSid)={foundVar};
                        else
                            data=aObj.fBlocksToVars(blkSid);
                            data{end+1}=foundVar;%#ok
                            aObj.fBlocksToVars(blkSid)=data;
                        end
                    end
                end
            end
            if isKey(aObj.fBlocksToVars,aSid)
                out=aObj.fBlocksToVars(aSid);
            end
        end


        function out=checkCompatibility(aObj)

            out=[];


            out=[out,checkCompatibility@slci.common.BdObject(aObj)];
            for idx=1:numel(aObj.fBlocks)
                out=[out,aObj.fBlocks{idx}.checkCompatibility()];%#ok
            end
            for idx=1:numel(aObj.fCharts)
                out=[out,aObj.fCharts{idx}.checkCompatibility()];%#ok
            end

        end

        function out=getConstraint(aObj,enum)
            out={};
            if isKey(aObj.enumConstraintsMap,enum)
                out=aObj.enumConstraintsMap(enum);
            end
        end

        function setCheckAsRefModel(aObj,val)
            aObj.fCheckAsRefModel=val;
        end

        function out=getCheckAsRefModel(aObj)
            out=aObj.fCheckAsRefModel;
        end


        function setInspectSharedUtils(aObj,aInspectSharedUtils)
            aObj.fInspectSharedUtils=aInspectSharedUtils;
        end


        function out=getInspectSharedUtils(aObj)
            out=aObj.fInspectSharedUtils;
        end

        function out=getBlocks(aObj)
            out=aObj.fBlocks;
        end



        function out=getSLFcnBlockHandles(aObj)
            out=aObj.fSimulinkFunctionHdls;
        end

        function setHandle(aObj,aHandle)
            aObj.fHandle=aHandle;
        end

        function out=getHandle(aObj)
            out=aObj.fHandle;
        end



        function out=getFuncInfoForCaller(aObj,callerHdl)
            out=[];
            if~aObj.fIsCompiledSLFcnTableBuilt



                aObj.setCompiledSLFcnTable
            end
            if isKey(aObj.fSLFcnCallerToFuncMap,callerHdl)
                fcnHdls=aObj.fSLFcnCallerToFuncMap(callerHdl);
                for i=1:numel(fcnHdls)
                    assert(isKey(aObj.fCompiledSLFcnTable,fcnHdls{i}),...
                    'Unregisterd Simulink Function handle found');
                    fcns=aObj.fCompiledSLFcnTable(fcnHdls{i});
                    out=[out,fcns];%#ok
                end
            end
        end

        function out=getObjType(aObj,objType)
            out=[];
            if strcmp(objType,DAStudio.message('Slci:compatibility:Charts'))
                out=aObj.getCharts();
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:MATLABActionLanguage'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getSFAsts];%#ok
                end
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:Transitions'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getTransitions()];%#ok
                end
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:Junctions'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getJunctions()];%#ok
                end
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:States'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getStates()];%#ok
                end
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:Data'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getData()];%#ok
                end
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:Events'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getEvents()];%#ok
                end
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:GraphicalFunctions'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getGraphicalFunctions()];%#ok
                end
            elseif strcmp(objType,DAStudio.message('Slci:compatibility:TruthTables'))
                charts=aObj.getCharts();
                for i=1:numel(charts)
                    out=[out,charts{i}.getTruthTables()];%#ok
                end
            end
        end

        function out=getBlockType(aObj,type)
            out={};
            if strcmp(type,'*')
                out=aObj.fBlocks;
                return;
            end
            type=strrep(type,'-','_');
            if isKey(aObj.blockTypeBlocksMap,type)
                out=aObj.blockTypeBlocksMap(type);
            end
            if~isempty(out)
                out=aObj.fBlocks(aObj.blockTypeToBlockIdx{out}(2:end));
            end
        end

        function out=getUnsupportedBlocks(aObj)
            unsupportedBlockTypes={'Unsupported'};
            out=[];
            for k=1:numel(unsupportedBlockTypes)
                out=[out,aObj.getBlockType(unsupportedBlockTypes{k})];%#ok
            end

            out=[out,aObj.getUnsupportedSubsystems()];
        end

        function out=getCharts(aObj)
            out=aObj.fCharts;
        end

        function addChart(aObj,aChart)
            if isempty(aObj.fCharts)
                aObj.fCharts={aChart};
            else
                aObj.fCharts(end+1)={aChart};
            end
        end

        function out=getEMCharts(aObj)
            mlBlocks=aObj.getBlockType('MatlabFunction');
            out=cell(1,numel(mlBlocks));
            for k=1:numel(mlBlocks)
                blk=mlBlocks{k};
                assert(isa(blk,'slci.simulink.MatlabFunctionBlock'));
                emChart=blk.getEMChart();
                assert(~isempty(emChart));
                out{k}=emChart;
            end
        end

        function out=isConfigsetParam(aObj,paramName)
            cs=getActiveConfigSet(aObj.getHandle());
            out=cs.isValidParam(paramName);
        end

        function listCompatibility(aObj)
            if aObj.fAutodoc
                aObj.listSupportedBlocks();
                disp(' ')
            end
            disp(['For model ',aObj.getName(),':']);
            listCompatibility@slci.common.BdObject(aObj);
            for idx=1:numel(aObj.fBlocks)
                disp(' ')
                disp(['For block ',aObj.fBlocks{idx}.getName(),':']);
                aObj.fBlocks{idx}.listCompatibility();
            end
            disp(' ')
            disp('For chart anyChart:');
            aObj.fCharts(1).listCompatibility();
            disp(' ')
            disp('For transition anyTransition:');
            aObj.fCharts(1).getTransitions().listCompatibility();
            disp(' ')
            disp('For junction anyJunction:');
            aObj.fCharts(1).getJunctions().listCompatibility();
            disp(' ')
            disp('For data anyData:');
            aObj.fCharts(1).getData().listCompatibility();
            disp(' ')
            disp('For event anyEvent:');
            aObj.fCharts(1).getEvents().listCompatibility();
            disp(' ')
            disp('For state anyState:');
            aObj.fCharts(1).getStates().listCompatibility();
        end

        function[Pane,path,Type,prompt,ParentPane]=getConfigParamDetails(aObj,paramName)
            paramInfo=configset.getParameterInfo(aObj.getSystemName,paramName);
            Pane=paramInfo.getDisplayPath;
            prompt=strip(paramInfo.Description,'right',':');
            path=[paramInfo.getDisplayPath(' > '),' > ',prompt];
            Type=paramInfo.getWidgetType;
            parentIdx=strfind(Pane,'/');
            if~isempty(parentIdx)
                ParentPane=Pane(1:parentIdx(1)-1);
            else
                ParentPane=Pane;
            end
            ParentPane=[strrep(ParentPane,' ',''),'Pane'];
        end


        function out=hasLibBlockPathToBlockSID(aObj,blk_path)
            out=false;
            if isempty(aObj.fLibBlockPathToBlockSID)
                return;
            end

            out=isKey(aObj.fLibBlockPathToBlockSID,blk_path);
        end


        function out=getLibBlockPathToBlockSID(aObj,blk_path)
            out='';
            if isempty(aObj.fLibBlockPathToBlockSID)
                return;
            end
            if isKey(aObj.fLibBlockPathToBlockSID,blk_path)
                out=aObj.fLibBlockPathToBlockSID(blk_path);
            end
        end


        function registerCompiledSLFcnInfo(aObj,slfcnInfo)
            fcnBlkHdl=slfcnInfo.getFcnBlkHdl;


            if~isKey(aObj.fCompiledSLFcnTable,fcnBlkHdl)
                aObj.fCompiledSLFcnTable(fcnBlkHdl)={slfcnInfo};
            else
                fcns=aObj.fCompiledSLFcnTable(fcnBlkHdl);
                fcns{end+1}=slfcnInfo;
                aObj.fCompiledSLFcnTable(fcnBlkHdl)=fcns;
            end
        end


        function fcnInfos=getSimulinkFunctionInfo(aObj,fcnHdl)
            if~aObj.fIsCompiledSLFcnTableBuilt
                aObj.setCompiledSLFcnTable;
            end
            assert(isKey(aObj.fCompiledSLFcnTable,fcnHdl),['Unregisterd '...
            ,'Simulink Function handle found']);
            fcnInfos=aObj.fCompiledSLFcnTable(fcnHdl);
        end
    end

    methods(Access=public,Static=true)
        function out=isCustomCodeBlock(blk)
            out=false;
            rtwData=get_param(blk,'RTWdata');
            if~isempty(rtwData)&&isfield(rtwData,'Location')
                out=true;
            end
        end
    end

end



