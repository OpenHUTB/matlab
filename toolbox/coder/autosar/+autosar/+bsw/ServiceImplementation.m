classdef ServiceImplementation<handle




    methods(Static,Abstract)

        deepCopyInterface(mdlName,dstInterfacePath);
        defaultClientPortName=getDefaultClientPortName();
        interfaceName=getInterfaceName();
        operations=getOperations();
        desc=getDescription();
        type=getType();
        libBlkPath=getLibraryBlk();
        help=getHelp();
        keywords=getKeywords();
        hastypeParameter=hasDatatypeParameter();
        dataTypeCallback(blkPath);
        exportToPrevious(targetVersion,blkPath);
    end

    methods(Static)

        function hasArgSpecParameter=hasArgumentSpecificationParameter()
            hasArgSpecParameter=false;
        end

        function operationCallback(blkPath)
            if~autosar.validation.CompiledModelUtils.isCompiled(bdroot(blkPath))

                maskObject=get_param(blkPath,'MaskObject');
                operationValue=get_param(blkPath,'Operation');
                serviceImpl=eval(get_param(blkPath,'ServiceImpl'));

                maskObject.getDialogControl('OperationDescription').Prompt=serviceImpl.OperationsDescriptionMap(operationValue);
            end
        end
    end


    methods(Static,Access=private)


        function isCustomDt=isCustomEnumDatatype(enumDatatype,allEnumDataTypes)
            isCustomDt=~isempty(enumDatatype)&&...
            isempty(find(strcmp(enumDatatype,allEnumDataTypes),1));
        end


        function isValid=isEnumDataTypeValid(dataType)
            isValid=false;
            if isempty(dataType)
                return;
            end


            dataType=strtrim(dataType);
            if~strncmp(dataType,'Enum:',length('Enum:'))
                return
            end


            enumName=regexp(dataType,'Enum:\s*(\w*)','tokens');
            enumName=enumName{1}{1};
            mprops=Simulink.getMetaClassIfValidEnumDataType(enumName);
            if isempty(mprops)
                return;
            end
            isValid=true;
        end
    end

    methods(Static,Access=public)
        function blockIconType=getBlockIconType()
            blockIconType='';
        end

        function serviceImpls=getServiceImpls()
            function isServImp=isServiceImplementation(class)
                isServImp=false;
                if~isempty(class.SuperclassList)...
                    &&strcmp(class.SuperclassList.Name,'autosar.bsw.ServiceImplementation')
                    isServImp=true;
                end
            end
            bswPackage=meta.package.fromName('autosar.bsw');
            serviceImplMetaClasses=bswPackage.ClassList(...
            arrayfun(@isServiceImplementation,bswPackage.ClassList));
            serviceImpls=cellfun(@(x)eval(x),{serviceImplMetaClasses.Name},'UniformOutput',false);
        end
    end

    methods(Static,Sealed,Access=protected)
        function updateAUTOSARProperties(mdlName,arxmlFiles)
            obj=arxml.importer(arxmlFiles);
            obj.updateAUTOSARProperties(mdlName,...
            'BackupModel',false,...
            'CreateReport',false,...
            'DisplayMessages',false);
        end



        function dataTypeCallbackImpl(blkPath)
            mo=get_param(blkPath,'MaskObject');
            paramIdx=strcmp({mo.Parameters.Name},'Datatype');

            dataType=get_param(blkPath,'Datatype');

            if~autosar.bsw.ServiceImplementation.isEnumDataTypeValid(dataType)
                DAStudio.error('Simulink:DataType:UdtInvEnumName',...
                dataType,mo.Parameters(paramIdx).Name);
            end
        end



        function operationCallbackImpl(blkPath,defaultEnumDatatype,allEnumDataTypes,...
            datatypeMaskPromptNameMap)
            maskObject=get_param(blkPath,'MaskObject');
            operationValue=get_param(blkPath,'Operation');
            portName=get_param(blkPath,'PortName');
            serviceImpl=eval(get_param(blkPath,'ServiceImpl'));

            datatypeIdx=strcmp({maskObject.Parameters.Name},'Datatype');
            if isempty(defaultEnumDatatype)
                maskObject.Parameters(datatypeIdx).Visible='off';
                set_param(blkPath,'Datatype','');
            else
                maskObject.Parameters(datatypeIdx).Visible='on';
                enumDataType=get_param(blkPath,'Datatype');

                if~autosar.bsw.DemDiagnosticInfo.isCustomEnumDatatype(enumDataType,allEnumDataTypes)
                    set_param(blkPath,'Datatype',defaultEnumDatatype);
                end
                maskObject.Parameters(datatypeIdx).Prompt=...
                datatypeMaskPromptNameMap(operationValue);
            end



            serviceImpl.updateFunctionCaller(blkPath,portName,operationValue);
        end



        function argumentSpecificationOperationCallbackImpl(blkPath,defaultDatatype,...
            datatypeMaskPromptNameMap)
            maskObject=get_param(blkPath,'MaskObject');
            operationValue=get_param(blkPath,'Operation');

            if~autosar.validation.CompiledModelUtils.isCompiled(bdroot(blkPath))

                argSpecIdx=strcmp({maskObject.Parameters.Name},'ArgumentSpecification');
                if isempty(defaultDatatype)
                    maskObject.Parameters(argSpecIdx).Visible='off';
                else
                    maskObject.Parameters(argSpecIdx).Visible='on';
                    maskObject.Parameters(argSpecIdx).Prompt=...
                    datatypeMaskPromptNameMap(operationValue);
                end
            end



            portName=get_param(blkPath,'PortName');
            operationName=get_param(blkPath,'Operation');
            serviceImpl=eval(get_param(blkPath,'ServiceImpl'));
            serviceImpl.updateFunctionCaller(blkPath,portName,operationName);
        end

        function unmaskAndUnlinkCaller(blkPath)
            sampleTime=get_param(blkPath,'st');
            autosar.blocks.unlinkAndUnmaskBlock(blkPath);
            set_param(blkPath,'SampleTime',sampleTime);
        end
    end
end


