classdef DemPfcCycleQualified<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemPfcCycleQualified.Operations,...
        autosar.bsw.DemPfcCycleQualified.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.DemPfcCycleQualified.Operations,...
        autosar.bsw.DemPfcCycleQualified.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemPfcCycleQualified.Operations,...
        autosar.bsw.DemPfcCycleQualified.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemPfcCycleQualified.Operations,...
        autosar.bsw.DemPfcCycleQualified.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemPfcCycleQualified.Operations,...
        autosar.bsw.DemPfcCycleQualified.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='PfcCycleQualified';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='PfcCycleQualified';
        Operations={
'SetPfcCycleQualified'
'GetPfcCycleQualified'
        };

        OperationDescriptions={
'autosarstandard:bsw:SetPfcCycleQualifiedDesc'
        'autosarstandard:bsw:GetPfcCycleQualifiedDesc'};

        FunctionPrototypes={
'ERR = %s_SetPfcCycleQualified()'
'[isqualified, ERR] = %s_GetPfcCycleQualified()'
        };

        FunctionPrototypesWithId={
'ERR = %s_SetPfcCycleQualified()'
'[isqualified, ERR] = %s_GetPfcCycleQualified()'
        };

        InputArgSpecs={
''
''
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.boolean_spec(false), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };
    end

    methods(Access=public)

        function this=DemPfcCycleQualified()
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
            defaultClientPortName=autosar.bsw.DemPfcCycleQualified.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemPfcCycleQualified.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemPfcCycleQualified.Operations;
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
            type='DiagnosticPfcCycleQualifiedCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemPfcCycleQualified.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticmonitor_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem';'Diagnostic';'Pfc'};...
            autosar.bsw.DemPfcCycleQualified.getType();...
            autosar.bsw.DemPfcCycleQualified.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)%#ok<INUSD>

        end
    end

end



