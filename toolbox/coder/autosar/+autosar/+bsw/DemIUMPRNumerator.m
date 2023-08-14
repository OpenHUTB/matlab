classdef DemIUMPRNumerator<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemIUMPRNumerator.Operations,...
        autosar.bsw.DemIUMPRNumerator.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.DemIUMPRNumerator.Operations,...
        autosar.bsw.DemIUMPRNumerator.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemIUMPRNumerator.Operations,...
        autosar.bsw.DemIUMPRNumerator.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemIUMPRNumerator.Operations,...
        autosar.bsw.DemIUMPRNumerator.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemIUMPRNumerator.Operations,...
        autosar.bsw.DemIUMPRNumerator.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='IUMPRNumerator';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='IUMPRNumerator';
        Operations={
'RepIUMPRFaultDetect'
        };

        OperationDescriptions={'autosarstandard:bsw:RepIUMPRFaultDetectDesc'};

        FunctionPrototypes={
'ERR = %s_RepIUMPRFaultDetect()'
        };

        FunctionPrototypesWithId={
'ERR = %s_RepIUMPRFaultDetect(RatioId)'
        };

        InputArgSpecs={
''
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };
    end

    methods(Access=public)

        function this=DemIUMPRNumerator()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            functionPrototype=sprintf(functionPrototypeTemplate,portName);

            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);

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
            defaultClientPortName=autosar.bsw.DemIUMPRNumerator.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemIUMPRNumerator.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemIUMPRNumerator.Operations;
        end



        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=false;
        end

        function dataTypeCallback(~)
        end

        function desc=getDescription()
            desc=autosar.bsw.DemDiagnosticInfo.getDescription();
        end

        function type=getType()
            type='DiagnosticIUMPRNumeratorCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemIUMPRNumerator.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticmonitor_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'IUMPR'};...
            autosar.bsw.DemIUMPRNumerator.getType();...
            autosar.bsw.DemIUMPRNumerator.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)%#ok<INUSD>

        end
    end

end



