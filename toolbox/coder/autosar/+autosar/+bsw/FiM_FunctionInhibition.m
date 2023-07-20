classdef FiM_FunctionInhibition<autosar.bsw.ServiceImplementation



    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.FiM_FunctionInhibition.Operations,...
        autosar.bsw.FiM_FunctionInhibition.FunctionPrototypes);

        FunctionPrototypeWithIdMap=containers.Map(autosar.bsw.FiM_FunctionInhibition.Operations,...
        autosar.bsw.FiM_FunctionInhibition.FunctionPrototypesWithId);

        InputArgSpecMap=containers.Map(autosar.bsw.FiM_FunctionInhibition.Operations,...
        autosar.bsw.FiM_FunctionInhibition.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.FiM_FunctionInhibition.Operations,...
        autosar.bsw.FiM_FunctionInhibition.OutputArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.FiM_FunctionInhibition.Operations,...
        autosar.bsw.FiM_FunctionInhibition.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='FiM_FunctionInhibition';
        DefaultInterfacePath='/AUTOSAR/Services/FiM';
        InterfaceName='FunctionInhibition';
        Operations={
'GetFunctionPermission'
        };

        OperationDescriptions={'autosarstandard:bsw:GetFunctionPermissionDesc'};

        FunctionPrototypes={
'[Permission,ERR] = %s_GetFunctionPermission()'
        };

        FunctionPrototypesWithId={
'[Permission,ERR] = %s_GetFunctionPermission(FID)'
        };

        InputArgSpecs={
''
        };

        OutputArgSpecs={
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        };

    end

    methods(Access=public)

        function this=FiM_FunctionInhibition()
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
            defaultClientPortName=autosar.bsw.FiM_FunctionInhibition.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.FiM_FunctionInhibition.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.FiM_FunctionInhibition.Operations;
        end



        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=false;
        end

        function dataTypeCallback(~)
        end

        function desc=getDescription()
            desc=['Call an AUTOSAR Function Inhibition Manager (FiM) service function.',...
            newline,newline,...
            'Set the Client port name parameter to the port name used by the component for the function call.',...
            newline,newline,...
            'Select a FiM operation with the Operation parameter.  After the selection, ',...
            'the block inputs and outputs correspond to the input and output arguments of the selected operation.'];
        end

        function type=getType()
            type='Function Inhibition Caller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibfim/',autosar.bsw.FiM_FunctionInhibition.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='FiMCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_fim_functioninhibition_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'FiM';'Function';'Inhibition';'Permission'};...
            autosar.bsw.FiM_FunctionInhibition.getType();...
            autosar.bsw.FiM_FunctionInhibition.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2019bOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end



