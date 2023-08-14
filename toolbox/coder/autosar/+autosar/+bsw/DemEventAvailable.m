classdef DemEventAvailable<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.DemEventAvailable.Operations,...
        autosar.bsw.DemEventAvailable.FunctionPrototypes);

        FunctionPrototypeWithEventIdMap=containers.Map(autosar.bsw.DemEventAvailable.Operations,...
        autosar.bsw.DemEventAvailable.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.DemEventAvailable.Operations,...
        autosar.bsw.DemEventAvailable.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.DemEventAvailable.Operations,...
        autosar.bsw.DemEventAvailable.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.DemEventAvailable.Operations,...
        autosar.bsw.DemEventAvailable.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='EventAvailable';
        DefaultInterfacePath='/AUTOSAR/Services/Dem';
        InterfaceName='EventAvailable';
        Operations={
'SetEventAvailable'
        };

        OperationDescriptions={'autosarstandard:bsw:SetEventAvailableDesc'};

        FunctionPrototypes={
'ERR = %s_SetEventAvailable(AvailableStatus)'
        };

        FunctionPrototypesWithId={
'ERR = %s_SetEventAvailable(EventId, AvailableStatus)'
        };

        InputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true)'
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };
    end

    methods(Access=public)

        function this=DemEventAvailable()
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
            defaultClientPortName=autosar.bsw.DemEventAvailable.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.DemEventAvailable.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.DemEventAvailable.Operations;
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
            type='DiagnosticEventAvailableCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibdem/',autosar.bsw.DemEventAvailable.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='DemCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_dem_diagnosticeventavailable_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'Dem'};...
            autosar.bsw.DemEventAvailable.getType();...
            autosar.bsw.DemEventAvailable.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2019bOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end



