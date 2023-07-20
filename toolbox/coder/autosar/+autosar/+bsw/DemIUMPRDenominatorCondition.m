classdef DemIUMPRDenominatorCondition<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemIUMPRDenominatorCondition.Operations,...
        autosar.bsw.DemIUMPRDenominatorCondition.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.DemIUMPRDenominatorCondition.Operations,...
        autosar.bsw.DemIUMPRDenominatorCondition.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemIUMPRDenominatorCondition.Operations,...
        autosar.bsw.DemIUMPRDenominatorCondition.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemIUMPRDenominatorCondition.Operations,...
        autosar.bsw.DemIUMPRDenominatorCondition.OutputArgSpecs);

        EnumDatatypeMap=containers.Map(autosar.bsw.DemIUMPRDenominatorCondition.Operations,...
        autosar.bsw.DemIUMPRDenominatorCondition.EnumDatatypes);

        DatatypeMaskPromptNameMap=...
        containers.Map(autosar.bsw.DemIUMPRDenominatorCondition.Operations,...
        autosar.bsw.DemIUMPRDenominatorCondition.DatatypeMaskPromptName);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemIUMPRDenominatorCondition.Operations,...
        autosar.bsw.DemIUMPRDenominatorCondition.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='IUMPRDenominatorCondition';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='IUMPRDenominatorCondition';
        Operations={
'SetIUMPRDenCondition'
'GetIUMPRDenCondition'
        };

        OperationDescriptions={
'autosarstandard:bsw:SetIUMPRDenConditionDesc'
        'autosarstandard:bsw:GetIUMPRDenConditionDesc'};

        FunctionPrototypes={
'ERR = %s_SetIUMPRDenCondition(ConditionStatus)'
'[ConditionStatus, ERR] = %s_GetIUMPRDenCondition()'
        };

        FunctionPrototypesWithId={
'ERR = %s_SetIUMPRDenCondition(ConditionId, ConditionStatus)'
'[ConditionStatus, ERR] = %s_GetIUMPRDenCondition(ConditionId)'
        };

        InputArgSpecs={
'%s.getDefaultValue'
''
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };

        EnumDatatypes={
'Enum: Dem_IumprDenomCondStatusType'
''
        };

        DatatypeMaskPromptName={
'Data type for ConditionStatus:'
''
        };
    end

    methods(Access=public)

        function this=DemIUMPRDenominatorCondition()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller


            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            functionPrototype=sprintf(functionPrototypeTemplate,portName);

            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);
            if strcmp(autosar.bsw.DemIUMPRDenominatorCondition.getDatatypeVisibility(operationName),'on')
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
            defaultClientPortName=autosar.bsw.DemIUMPRDenominatorCondition.DefaultClientPortName;
        end

        function dataType=getDefaultDatatype(defaultOperation)
            dataType=autosar.bsw.DemIUMPRDenominatorCondition.EnumDatatypeMap(defaultOperation);
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemIUMPRDenominatorCondition.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemIUMPRDenominatorCondition.Operations;
        end

        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=true;
        end

        function dataTypeCallback(blkPath)
            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));
            operation=get_param(blkPath,'Operation');
            if strcmp(autosar.bsw.DemIUMPRDenominatorCondition.getDatatypeVisibility(operation),'on')
                autosar.bsw.ServiceImplementation.dataTypeCallbackImpl(blkPath);
            end
        end

        function operationCallback(blkPath)
            operationCallback@autosar.bsw.ServiceImplementation(blkPath);
            operationValue=get_param(blkPath,'Operation');
            autosar.bsw.ServiceImplementation.operationCallbackImpl(blkPath,...
            autosar.bsw.DemIUMPRDenominatorCondition.EnumDatatypeMap(operationValue),...
            autosar.bsw.DemIUMPRDenominatorCondition.EnumDatatypes,...
            autosar.bsw.DemIUMPRDenominatorCondition.DatatypeMaskPromptNameMap)
        end



        function visibility=getDatatypeVisibility(operation)
            datatype=autosar.bsw.DemIUMPRDenominatorCondition.EnumDatatypeMap(operation);
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
            type='DiagnosticIUMPRDenominatorConditionCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemIUMPRDenominatorCondition.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticmonitor_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'IUMPR'};...
            autosar.bsw.DemIUMPRDenominatorCondition.getType();...
            autosar.bsw.DemIUMPRDenominatorCondition.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)%#ok<INUSD>

        end
    end

end



