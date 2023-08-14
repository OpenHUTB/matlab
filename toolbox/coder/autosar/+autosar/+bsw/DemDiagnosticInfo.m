classdef DemDiagnosticInfo<autosar.bsw.ServiceImplementation




    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemDiagnosticInfo.Operations,...
        autosar.bsw.DemDiagnosticInfo.FunctionPrototypes);

        FunctionPrototypeWithEventIdMap=containers.Map(autosar.bsw.DemDiagnosticInfo.Operations,...
        autosar.bsw.DemDiagnosticInfo.FunctionPrototypesWithEventId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemDiagnosticInfo.Operations,...
        autosar.bsw.DemDiagnosticInfo.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemDiagnosticInfo.Operations,...
        autosar.bsw.DemDiagnosticInfo.OutputArgSpecs);

        EnumDatatypeMap=containers.Map(autosar.bsw.DemDiagnosticInfo.Operations,...
        autosar.bsw.DemDiagnosticInfo.EnumDatatypes);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemDiagnosticInfo.Operations,...
        autosar.bsw.DemDiagnosticInfo.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='DiagnosticInfo';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='DiagnosticInfo';
        Operations={'GetEventStatus'
'GetEventFailed'
'GetEventTested'
'GetDTCOfEvent'
'GetFaultDetectionCounter'
'GetEventExtendedDataRecord'
        'GetEventFreezeFrameData'};

        OperationDescriptions={
'autosarstandard:bsw:GetEventStatusDesc'
'autosarstandard:bsw:GetEventFailedDesc'
'autosarstandard:bsw:GetEventTestedDesc'
'autosarstandard:bsw:GetDTCOfEventDesc'
'autosarstandard:bsw:GetFaultDetectionCounterDesc'
'autosarstandard:bsw:GetEventExtendedDataRecordDesc'
        'autosarstandard:bsw:GetEventFreezeFrameDataDesc'};

        FunctionPrototypes={
'[EventStatusExtended,ERR] = %s_GetEventStatus()'
'[EventFailed,ERR] = %s_GetEventFailed()'
'[EventTested,ERR] = %s_GetEventTested()'
'[DTCOfEvent,ERR] = %s_GetDTCOfEvent(DTCFormat)'
'[FaultDetectionCounter,ERR] = %s_GetFaultDetectionCounter()'
'[DestBuffer,ERR] = %s_GetEventExtendedDataRecord(RecordNumber)'
        '[DestBuffer,ERR] = %s_GetEventFreezeFrameData(RecordNumber,ReportTotalRecord,DataId)'};

        FunctionPrototypesWithEventId={
'[EventStatusExtended,ERR] = %s_GetEventStatus(EventId)'
'[EventFailed,ERR] = %s_GetEventFailed(EventId)'
'[EventTested,ERR] = %s_GetEventTested(EventId)'
'[DTCOfEvent,ERR] = %s_GetDTCOfEvent(EventId, DTCFormat)'
'[FaultDetectionCounter,ERR] = %s_GetFaultDetectionCounter(EventId)'
'[DestBuffer,ERR] = %s_GetEventExtendedDataRecord(EventId, RecordNumber)'
        '[DestBuffer,ERR] = %s_GetEventFreezeFrameData(EventId, RecordNumber,ReportTotalRecord,DataId)'};

        InputArgSpecs={''
''
''
'%s.getDefaultValue'
''
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.boolean_spec(true), autosar.bsw.BasicSoftwareCaller.uint16_spec(1)'};

        OutputArgSpecs={'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint32_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'int8(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec([1 1 1 1]), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        'autosar.bsw.BasicSoftwareCaller.uint8_spec([1 1 1 1]), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'};

        DatatypeMaskPromptName={''
''
''
'Data type for DTCFormat:'
''
''
        ''};


        EnumDatatypes={''
''
''
'Enum: Dem_DTCFormatType'
''
''
        ''};

        DatatypeMaskPromptNameMap=containers.Map(autosar.bsw.DemDiagnosticInfo.Operations,...
        autosar.bsw.DemDiagnosticInfo.DatatypeMaskPromptName);

    end

    methods(Access=public)

        function this=DemDiagnosticInfo()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller


            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            functionPrototype=sprintf(functionPrototypeTemplate,portName);

            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);
            if strcmp(autosar.bsw.DemDiagnosticInfo.getDatatypeVisibility(operationName),'on')
                dataType=strrep(strtrim(get_param(blkPath,'Datatype')),'Enum: ','');
                inputArgSpec=sprintf(inputArgSpec,dataType);
                outputArgSpec=sprintf(outputArgSpec,dataType);
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
            defaultClientPortName=autosar.bsw.DemDiagnosticInfo.DefaultClientPortName;
        end

        function dataType=getDefaultDatatype(defaultOperation)
            dataType=autosar.bsw.DemDiagnosticInfo.EnumDatatypeMap(defaultOperation);
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemDiagnosticInfo.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemDiagnosticInfo.Operations;
        end

        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=true;
        end

        function dataTypeCallback(blkPath)
            autosar.bsw.Dem_defineIntEnumTypes(bdroot(blkPath));
            operation=get_param(blkPath,'Operation');
            if strcmp(autosar.bsw.DemDiagnosticInfo.getDatatypeVisibility(operation),'on')
                autosar.bsw.ServiceImplementation.dataTypeCallbackImpl(blkPath);
            end
        end

        function operationCallback(blkPath)
            operationCallback@autosar.bsw.ServiceImplementation(blkPath);
            operationValue=get_param(blkPath,'Operation');
            autosar.bsw.ServiceImplementation.operationCallbackImpl(blkPath,...
            autosar.bsw.DemDiagnosticInfo.EnumDatatypeMap(operationValue),...
            autosar.bsw.DemDiagnosticInfo.EnumDatatypes,...
            autosar.bsw.DemDiagnosticInfo.DatatypeMaskPromptNameMap)
        end



        function visibility=getDatatypeVisibility(operation)
            datatype=autosar.bsw.DemDiagnosticInfo.EnumDatatypeMap(operation);
            if isempty(datatype)
                visibility='off';
            else
                visibility='on';
            end
        end

        function desc=getDescription()
            desc=['Call an AUTOSAR Diagnostic Event Manager (Dem) service function.',...
            newline,newline,...
            'Set the Client port name parameter to the port name used by the component for the function call.',...
            newline,newline,...
            'Select a Dem operation with the Operation parameter.  After the selection, ',...
            'the block inputs and outputs correspond to the input and output arguments of the selected operation.'];
        end

        function type=getType()
            type='DiagnosticInfoCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemDiagnosticInfo.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticinfo_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic'};...
            autosar.bsw.DemDiagnosticInfo.getType();...
            autosar.bsw.DemDiagnosticInfo.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2017aOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end


