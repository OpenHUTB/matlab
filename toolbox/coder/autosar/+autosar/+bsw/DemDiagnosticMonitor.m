classdef DemDiagnosticMonitor<autosar.bsw.ServiceImplementation




    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemDiagnosticMonitor.Operations,...
        autosar.bsw.DemDiagnosticMonitor.FunctionPrototypes);

        FunctionPrototypeWithEventIdMap=containers.Map(autosar.bsw.DemDiagnosticMonitor.Operations,...
        autosar.bsw.DemDiagnosticMonitor.FunctionPrototypesWithEventId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemDiagnosticMonitor.Operations,...
        autosar.bsw.DemDiagnosticMonitor.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemDiagnosticMonitor.Operations,...
        autosar.bsw.DemDiagnosticMonitor.OutputArgSpecs);

        EnumDatatypeMap=containers.Map(autosar.bsw.DemDiagnosticMonitor.Operations,...
        autosar.bsw.DemDiagnosticMonitor.EnumDatatypes);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemDiagnosticMonitor.Operations,...
        autosar.bsw.DemDiagnosticMonitor.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='DiagnosticMonitor';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='DiagnosticMonitor';
        Operations={'SetEventStatus'
'ResetEventStatus'
'PrestoreFreezeFrame'
'ClearPrestoredFreezeFrame'
        'SetEventDisabled'};

        OperationDescriptions={
'autosarstandard:bsw:SetEventStatusDesc'
'autosarstandard:bsw:ResetEventStatusDesc'
'autosarstandard:bsw:PrestoreFreezeFrameDesc'
'autosarstandard:bsw:ClearPrestoredFreezeFrameDesc'
        'autosarstandard:bsw:SetEventDisabledDesc'};

        FunctionPrototypes={
'ERR = %s_SetEventStatus(EventStatus)'
'ERR = %s_ResetEventStatus()'
'ERR = %s_PrestoreFreezeFrame()'
'ERR = %s_ClearPrestoredFreezeFrame()'
        'ERR = %s_SetEventDisabled()'};

        FunctionPrototypesWithEventId={
'ERR = %s_SetEventStatus(EventId, EventStatus)'
'ERR = %s_ResetEventStatus(EventId)'
'ERR = %s_PrestoreFreezeFrame(EventId)'
'ERR = %s_ClearPrestoredFreezeFrame(EventId)'
        'ERR = %s_SetEventDisabled(EventId)'};

        InputArgSpecs={'%s.getDefaultValue'
''
''
''
        ''};

        OutputArgSpecs={'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'};

        EnumDatatypes={'Enum: Dem_EventStatusType'
''
''
''
        ''};

        DatatypeMaskPromptName={'Data type for EventStatus:'
''
''
''
        ''};


        DatatypeMaskPromptNameMap=containers.Map(autosar.bsw.DemDiagnosticMonitor.Operations,...
        autosar.bsw.DemDiagnosticMonitor.DatatypeMaskPromptName);

    end

    methods(Access=public)

        function this=DemDiagnosticMonitor()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller


            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            functionPrototype=sprintf(functionPrototypeTemplate,portName);

            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);
            if strcmp(autosar.bsw.DemDiagnosticMonitor.getDatatypeVisibility(operationName),'on')
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
            defaultClientPortName=autosar.bsw.DemDiagnosticMonitor.DefaultClientPortName;
        end

        function dataType=getDefaultDatatype(defaultOperation)
            dataType=autosar.bsw.DemDiagnosticMonitor.EnumDatatypeMap(defaultOperation);
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemDiagnosticMonitor.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemDiagnosticMonitor.Operations;
        end

        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=true;
        end

        function dataTypeCallback(blkPath)
            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));
            operation=get_param(blkPath,'Operation');
            if strcmp(autosar.bsw.DemDiagnosticMonitor.getDatatypeVisibility(operation),'on')
                autosar.bsw.ServiceImplementation.dataTypeCallbackImpl(blkPath);
            end
        end

        function operationCallback(blkPath)
            operationCallback@autosar.bsw.ServiceImplementation(blkPath);
            operationValue=get_param(blkPath,'Operation');
            autosar.bsw.ServiceImplementation.operationCallbackImpl(blkPath,...
            autosar.bsw.DemDiagnosticMonitor.EnumDatatypeMap(operationValue),...
            autosar.bsw.DemDiagnosticMonitor.EnumDatatypes,...
            autosar.bsw.DemDiagnosticMonitor.DatatypeMaskPromptNameMap)
        end



        function visibility=getDatatypeVisibility(operation)
            datatype=autosar.bsw.DemDiagnosticMonitor.EnumDatatypeMap(operation);
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
            type='DiagnosticMonitorCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemDiagnosticMonitor.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticmonitor_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'Monitor';'Event'};...
            autosar.bsw.DemDiagnosticMonitor.getType();...
            autosar.bsw.DemDiagnosticMonitor.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2017aOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end



