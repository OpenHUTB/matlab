



classdef NvMService<autosar.bsw.ServiceImplementation


    properties(Constant)
        FunctionPrototypeMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.FunctionPrototypes);

        FunctionPrototypeWithBlockIdMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.FunctionPrototypesWithBlockId);

        InputArgSpecMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.InputArgSpecs);

        OutputArgSpecMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.OutputArgSpecs);

        InputArgSpecTemplateMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.InputArgSpecTemplate);

        OutputArgSpecTemplateMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.OutputArgSpecTemplate);

        EnumDatatypeMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.EnumDatatypes);

        ArgSpecMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.ArgSpecs);

        OperationsDescriptionMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.OperationDescriptions);
    end

    properties(Constant,Access=private)
        DefaultClientPortName='NvMService';
        DefaultInterfacePath='/AUTOSAR/Services/NvM';
        InterfaceName='NvMService';
        Operations={'GetDataIndex'
'GetErrorStatus'
'EraseNvBlock'
'InvalidateNvBlock'
'ReadBlock'
'RestoreBlockDefaults'
'SetDataIndex'
'SetRamBlockStatus'
        'WriteBlock'};

        OperationDescriptions={
'autosarstandard:bsw:GetDataIndexDesc'
'autosarstandard:bsw:GetErrorStatusDesc'
'autosarstandard:bsw:EraseNvBlockDesc'
'autosarstandard:bsw:InvalidateNvBlockDesc'
'autosarstandard:bsw:ReadBlockDesc'
'autosarstandard:bsw:RestoreBlockDefaultsDesc'
'autosarstandard:bsw:SetDataIndexDesc'
'autosarstandard:bsw:SetRamBlockStatusDesc'
        'autosarstandard:bsw:WriteBlockDesc'};

        FunctionPrototypes={'[DataIndexPtr,ERR] = %s_GetDataIndex()'
'[RequestResultPtr,ERR] = %s_GetErrorStatus()'
'ERR = %s_EraseNvBlock()'
'ERR = %s_InvalidateNvBlock()'
'[DstPtr,ERR] = %s_ReadBlock()'
'[DestPtr,ERR] = %s_RestoreBlockDefaults()'
'ERR = %s_SetDataIndex(DataIndex)'
'ERR = %s_SetRamBlockStatus(BlockChanged)'
        'ERR = %s_WriteBlock(SrcPtr)'};


        FunctionPrototypesWithBlockId={'[DataIndexPtr,ERR] = %s_GetDataIndex(BlockId)'
'[RequestResultPtr,ERR] = %s_GetErrorStatus(BlockId)'
'ERR = %s_EraseNvBlock(BlockId)'
'ERR = %s_InvalidateNvBlock(BlockId)'
'[DstPtr,ERR] = %s_ReadBlock(BlockId)'
'[DestPtr,ERR] = %s_RestoreBlockDefaults(BlockId)'
'ERR = %s_SetDataIndex(BlockId, DataIndex)'
'ERR = %s_SetRamBlockStatus(BlockId, BlockChanged)'
        'ERR = %s_WriteBlock(BlockId, SrcPtr)'};

        InputArgSpecs={''
''
''
''
''
''
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true)'
        'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'};

        InputArgSpecTemplate={''
''
''
''
''
''
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.boolean_spec(true)'
        '%s'};

        EnumDatatypes={'','','','','','','','',''};

        OutputArgSpecs={'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'};

        OutputArgSpecTemplate={'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1), autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'%s, autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'%s, autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'
        'autosar.bsw.BasicSoftwareCaller.uint8_spec(1)'};

        ArgSpecs={''
''
''
''
'uint8(1)'
'uint8(1)'
''
''
        'uint8(1)'};

        ArgSpecMaskPromptName={''
''
''
''
'Argument specification (e.g. uint8(1)):'
'Argument specification (e.g. uint8(1)):'
''
''
        'Argument specification (e.g. uint8(1)):'};

        ArgSpecMaskPromptNameMap=containers.Map(autosar.bsw.NvMService.Operations,...
        autosar.bsw.NvMService.ArgSpecMaskPromptName);


    end

    methods(Access=public)

        function this=NvMService()
        end

        function updateFunctionCaller(this,blkPath,portName,operationName)

            import autosar.bsw.BasicSoftwareCaller

            functionPrototypeTemplate=this.FunctionPrototypeMap(operationName);
            inputArgSpec=this.InputArgSpecMap(operationName);
            outputArgSpec=this.OutputArgSpecMap(operationName);

            if strcmp(autosar.bsw.NvMService.getArgumentSpecificationVisibility(operationName),'on')
                argSpec=get_param(blkPath,'ArgumentSpecification');
                inputArgSpecTemplate=this.InputArgSpecTemplateMap(operationName);
                outputArgSpecTemplate=this.OutputArgSpecTemplateMap(operationName);

                inputArgSpec=sprintf(inputArgSpecTemplate,argSpec);
                outputArgSpec=sprintf(outputArgSpecTemplate,argSpec);
            end

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
            defaultClientPortName=autosar.bsw.NvMService.DefaultClientPortName;
        end

        function interfaceName=getInterfaceName()
            interfaceName=autosar.bsw.NvMService.InterfaceName;
        end

        function operations=getOperations()
            operations=autosar.bsw.NvMService.Operations;
        end

        function dataType=getDefaultArgumentSpecification(~)
            dataType='uint8(1)';
        end



        function hastypeParameter=hasDatatypeParameter()
            hastypeParameter=false;
        end

        function dataTypeCallback(~)
        end

        function operationCallback(blkPath)
            operationCallback@autosar.bsw.ServiceImplementation(blkPath);
            operationValue=get_param(blkPath,'Operation');
            autosar.bsw.ServiceImplementation.argumentSpecificationOperationCallbackImpl(blkPath,...
            autosar.bsw.NvMService.ArgSpecMap(operationValue),...
            autosar.bsw.NvMService.ArgSpecMaskPromptNameMap)
        end


        function hasArgSpecParameter=hasArgumentSpecificationParameter()
            hasArgSpecParameter=true;
        end



        function visibility=getArgumentSpecificationVisibility(operation)
            datatype=autosar.bsw.NvMService.ArgSpecMap(operation);
            if isempty(datatype)
                visibility='off';
            else
                visibility='on';
            end
        end

        function desc=getDescription()
            desc=autosar.bsw.NvMAdmin.getDescription();
        end

        function type=getType()
            type='NvMServiceCaller';
        end

        function libBlkPath=getLibraryBlk()
            libBlkPath=['autosarlibnvm/',autosar.bsw.NvMService.getType()];
        end

        function blockIconType=getBlockIconType()
            blockIconType='NvMCaller';
        end

        function help=getHelp()
            help='helpview(fullfile(docroot,''autosar'',''helptargets.map''),''autosar_nvmservice_block'');';
        end

        function keywords=getKeywords()
            keywords=[{'AUTOSAR';'NvM';'NVRAM';'Non-volatile';'non volatile'};...
            autosar.bsw.NvMService.getType();...
            autosar.bsw.NvMService.getOperations()];
        end

        function exportToPrevious(targetVersion,blkPath)
            if isR2017aOrEarlier(targetVersion)
                autosar.bsw.ServiceImplementation.unmaskAndUnlinkCaller(blkPath);
            end
        end
    end

end



