classdef DemOperationCycle<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemOperationCycle.Operations,...
        autosar.bsw.DemOperationCycle.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.DemOperationCycle.Operations,...
        autosar.bsw.DemOperationCycle.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemOperationCycle.Operations,...
        autosar.bsw.DemOperationCycle.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemOperationCycle.Operations,...
        autosar.bsw.DemOperationCycle.OutputArgSpecs);

        EnumDatatypeMap=containers.Map(autosar.bsw.DemOperationCycle.Operations,...
        autosar.bsw.DemOperationCycle.EnumDatatypes);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemOperationCycle.Operations,...
        autosar.bsw.DemOperationCycle.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='OperationCycle';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='OperationCycle';
        Operations={
'SetOperationCycleState'
'GetOperationCycleState'
        };

        OperationDescriptions={
'autosarstandard:bsw:SetOperationCycleStateDesc'
        'autosarstandard:bsw:GetOperationCycleStateDesc'};

        FunctionPrototypes={
'ERR = %s_SetOperationCycleState(CycleState)'
'[CycleState,ERR] = %s_GetOperationCycleState()'
        };

        FunctionPrototypesWithId={
'ERR = %s_SetOperationCycleState(OperationCycleId, CycleState)'
'[CycleState,ERR] = %s_GetOperationCycleState(OperationCycleId)'
        };

        InputArgSpecs={
'%s.getDefaultValue'
''
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1),autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };

        EnumDatatypes={
'Enum: Dem_OperationCycleStateType'
''
        };

        DatatypeMaskPromptName={
'Data type for CycleState:'
''
        };

        DatatypeMaskPromptNameMap=...
        containers.Map(autosar.bsw.DemOperationCycle.Operations,...
        autosar.bsw.DemOperationCycle.DatatypeMaskPromptName);

    end

    methods(Access=public)

        function this=DemOperationCycle()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller


            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            functionPrototype=sprintf(functionPrototypeTemplate,portName);

            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);
            if strcmp(autosar.bsw.DemOperationCycle.getDatatypeVisibility(operationName),'on')
                dataType=strrep(strtrim(get_param(blkPath,'Datatype')),'Enum: ','');
                inputArgSpec=sprintf(inputArgSpec,dataType);
            end

            BasicSoftwareCaller.set_param(blkPath,'FunctionPrototype',functionPrototype);
            BasicSoftwareCaller.set_param(blkPath,'InputArgumentSpecifications',inputArgSpec);
            BasicSoftwareCaller.set_param(blkPath,'OutputArgumentSpecifications',outputArgSpec);
        end

    end

    methods(Static,Access=public)

        function deepCopyInterface(mdlName,dstInterfacePath)%#ok<INUSD>


            arxmlPath=fullfile(autosarroot,'+autosar','+bsw','+arxml');
            arxmlFiles={fullfile(arxmlPath,'AUTOSAR_BaseTypes.arxml')
            fullfile(arxmlPath,'AUTOSAR_MOD_PlatformTypes.arxml')
            fullfile(arxmlPath,'AUTOSAR_Dem.arxml')};

            autosar.bsw.ServiceImplementation.updateAUTOSARProperties(mdlName,arxmlFiles);
        end

        function defaultClientPortName=getDefaultClientPortName()
            defaultClientPortName=autosar.bsw.DemOperationCycle.DefaultClientPortName;
        end

        function dataType=getDefaultDatatype(defaultOperation)
            dataType=autosar.bsw.DemOperationCycle.EnumDatatypeMap(defaultOperation);
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemOperationCycle.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemOperationCycle.Operations;
        end

        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=true;
        end

        function dataTypeCallback(blkPath)
            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));
            operation=get_param(blkPath,'Operation');
            if strcmp(autosar.bsw.DemOperationCycle.getDatatypeVisibility(operation),'on')
                autosar.bsw.ServiceImplementation.dataTypeCallbackImpl(blkPath);
            end
        end

        function operationCallback(blkPath)
            operationCallback@autosar.bsw.ServiceImplementation(blkPath);
            operationValue=get_param(blkPath,'Operation');
            autosar.bsw.ServiceImplementation.operationCallbackImpl(blkPath,...
            autosar.bsw.DemOperationCycle.EnumDatatypeMap(operationValue),...
            autosar.bsw.DemOperationCycle.EnumDatatypes,...
            autosar.bsw.DemOperationCycle.DatatypeMaskPromptNameMap)
        end



        function visibility=getDatatypeVisibility(operation)
            datatype=autosar.bsw.DemOperationCycle.EnumDatatypeMap(operation);
            if isempty(datatype)
                visibility='off';
            else
                visibility='on';
            end
        end

        function desc=getDescription()
            desc=autosar.bsw.DemDiagnosticInfo.getDescription();
        end

        function type=getType()
            type='DiagnosticOperationCycleCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemOperationCycle.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticoperationcycle_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'Operation';'Cycle'};...
            autosar.bsw.DemOperationCycle.getType();...
            autosar.bsw.DemOperationCycle.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2019bOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end



