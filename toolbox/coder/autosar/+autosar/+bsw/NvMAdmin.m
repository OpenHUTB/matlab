classdef NvMAdmin<autosar.bsw.ServiceImplementation




    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.NvMAdmin.Operations,...
        autosar.bsw.NvMAdmin.FunctionPrototypes);

        FunctionPrototypeWithBlockIdMap=containers.Map(autosar.bsw.NvMAdmin.Operations,...
        autosar.bsw.NvMAdmin.FunctionPrototypesWithBlockId);

        InputArgSpecMap=containers.Map(autosar.bsw.NvMAdmin.Operations,...
        autosar.bsw.NvMAdmin.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.NvMAdmin.Operations,...
        autosar.bsw.NvMAdmin.OutputArgSpecs);

        EnumDatatypeMap=containers.Map(autosar.bsw.NvMAdmin.Operations,...
        autosar.bsw.NvMAdmin.EnumDatatypes);

        OperationsDescriptionMap=containers.Map(autosar.bsw.NvMAdmin.Operations,...
        autosar.bsw.NvMAdmin.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='NvMAdmin';
        DefaultInterfacePath='/AUTOSAR/Services/NvM';
        InterfaceName='NvMAdmin';
        Operations={'SetBlockProtection'};

        OperationDescriptions={'autosarstandard:bsw:SetBlockProtectionDesc'};

        FunctionPrototypes={'ERR = %s_SetBlockProtection(ProtectionEnabled)'};

        FunctionPrototypesWithBlockId={'ERR = %s_SetBlockProtection(BlockId, ProtectionEnabled)'};

        InputArgSpecs={'autosar.bsw.BasicSoftwareCaller.boolean_spec(true)'};
        EnumDatatypes={''};
        OutputArgSpecs={'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'};
    end

    methods(Access=public)

        function this=NvMAdmin()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);

            functionPrototype=sprintf(functionPrototypeTemplate,portName);

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
            fullfile(arxmlPath,'AUTOSAR_NvM.arxml')};

            autosar.bsw.ServiceImplementation.updateAUTOSARProperties(mdlName,arxmlFiles);
        end

        function defaultClientPortName=getDefaultClientPortName()
            defaultClientPortName=autosar.bsw.NvMAdmin.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.NvMAdmin.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.NvMAdmin.Operations;
        end



        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=false;
        end

        function dataTypeCallback(~)
        end

        function desc=getDescription()
            desc=['Call an AUTOSAR NVRAM Manager (NvM) service function.',...
            newline,newline,...
            'Set the Client port name parameter to the port name used by the component for the function call.',...
            newline,newline,...
            'Select a NvM operation with the Operation parameter.  After the selection, ',...
            'the block inputs and outputs correspond to the input and output arguments of the selected operation.'];
        end

        function type=getType()
            type='NvMAdminCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibnvm/',autosar.bsw.NvMAdmin.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='NvMCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_nvmadmin_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'NvM';'NVRAM';'Non-volatile';'non volatile'};...
            autosar.bsw.NvMAdmin.getType();...
            autosar.bsw.NvMAdmin.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2017aOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end


