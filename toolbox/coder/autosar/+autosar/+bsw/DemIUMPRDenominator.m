classdef DemIUMPRDenominator<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemIUMPRDenominator.Operations,...
        autosar.bsw.DemIUMPRDenominator.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.DemIUMPRDenominator.Operations,...
        autosar.bsw.DemIUMPRDenominator.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemIUMPRDenominator.Operations,...
        autosar.bsw.DemIUMPRDenominator.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemIUMPRDenominator.Operations,...
        autosar.bsw.DemIUMPRDenominator.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemIUMPRDenominator.Operations,...
        autosar.bsw.DemIUMPRDenominator.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='IUMPRDenominator';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='IUMPRDenominator';
        Operations={
'RepIUMPRDenLock'
'RepIUMPRDenRelease'
        };

        OperationDescriptions={
'autosarstandard:bsw:RepIUMPRDenLockDesc'
        'autosarstandard:bsw:RepIUMPRDenReleaseDesc'};

        FunctionPrototypes={
'ERR = %s_RepIUMPRDenLock()'
'ERR = %s_RepIUMPRDenRelease()'
        };

        FunctionPrototypesWithId={
'ERR = %s_RepIUMPRDenLock(RatioId)'
'ERR = %s_RepIUMPRDenRelease(RatioId)'
        };

        InputArgSpecs={
''
''
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };
    end

    methods(Access=public)

        function this=DemIUMPRDenominator()
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
            defaultClientPortName=autosar.bsw.DemIUMPRDenominator.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemIUMPRDenominator.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemIUMPRDenominator.Operations;
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
            type='DiagnosticIUMPRDenominatorCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemIUMPRDenominator.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticmonitor_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'IUMPR'};...
            autosar.bsw.DemIUMPRDenominator.getType();...
            autosar.bsw.DemIUMPRDenominator.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)%#ok<INUSD>

        end
    end

end



