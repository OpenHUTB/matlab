classdef FiM_ControlFunctionAvailable<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.FiM_ControlFunctionAvailable.Operations,...
        autosar.bsw.FiM_ControlFunctionAvailable.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.FiM_ControlFunctionAvailable.Operations,...
        autosar.bsw.FiM_ControlFunctionAvailable.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.FiM_ControlFunctionAvailable.Operations,...
        autosar.bsw.FiM_ControlFunctionAvailable.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.FiM_ControlFunctionAvailable.Operations,...
        autosar.bsw.FiM_ControlFunctionAvailable.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.FiM_ControlFunctionAvailable.Operations,...
        autosar.bsw.FiM_ControlFunctionAvailable.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='FiM_ControlFunctionAvailable';
        DefaultInterfacePath='/AUTOSAR/Services/FiM';
        InterfaceName='ControlFunctionAvailable';
        Operations={
'SetFunctionAvailable'
        };

        OperationDescriptions={'autosarstandard:bsw:SetFunctionAvailableDesc'};

        FunctionPrototypes={
'ERR = %s_SetFunctionAvailable(Availability)'
        };

        FunctionPrototypesWithId={
'ERR = %s_SetFunctionAvailable(FID, Availability)'
        };

        InputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true)'
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };

    end

    methods(Access=public)

        function this=FiM_ControlFunctionAvailable()
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
            fullfile(arxmlPath,'AUTOSAR_FiM.arxml')};

            autosar.bsw.ServiceImplementation.updateAUTOSARProperties(mdlName,arxmlFiles);
        end

        function defaultClientPortName=getDefaultClientPortName()
            defaultClientPortName=autosar.bsw.FiM_ControlFunctionAvailable.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.FiM_ControlFunctionAvailable.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.FiM_ControlFunctionAvailable.Operations;
        end



        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=false;
        end

        function dataTypeCallback(~)
        end

        function desc=getDescription()
            desc=autosar.bsw.FiM_FunctionInhibition.getDescription();
        end

        function type=getType()
            type='Control Function Available Caller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibfim/',autosar.bsw.FiM_ControlFunctionAvailable.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='FiMCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_fim_controlfunctionavailable_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'FiM';'Function';'Inhibition';'Available'};...
            autosar.bsw.FiM_ControlFunctionAvailable.getType();...
            autosar.bsw.FiM_ControlFunctionAvailable.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2019bOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end



