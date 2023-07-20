classdef ClassicSLPortValidator<autosar.validation.PhasedValidator




    methods(Access=public)
        function this=ClassicSLPortValidator(modelHandle)
            this@autosar.validation.PhasedValidator('ModelHandle',modelHandle);
        end
    end

    methods(Access=protected)

        function verifyPostProp(this,hModel)
            assert(isscalar(hModel)&&ishandle(hModel),'hModel is not a handle');

            this.verifyPortSignalObjectsHavePimCSC(hModel);
            this.verifyRootIODataTypes(hModel);
            this.verifyVariantConditions(hModel);
        end

    end

    methods(Access=private)
        function verifyRootIODataTypes(this,hModel)



            inpH=find_system(hModel,'SearchDepth',1,'Type','block',...
            'BlockType','Inport');
            outpH=find_system(hModel,'SearchDepth',1,'Type','block',...
            'BlockType','Outport');

            inoutH=[inpH;outpH];
            isInportArray=[ones(size(inpH));zeros(size(outpH))];

            cs=getActiveConfigSet(hModel);
            supportMatrixIO=strcmpi(...
            get_param(cs,'AutosarMatrixIOAsArray'),'on')||...
            strcmpi(get_param(cs,'ArrayLayout'),'row-major');
            modelName=get_param(hModel,'Name');
            enablePRPortChecking=false;

            if autosar.validation.ClassicSLPortValidator.isPRPortEnable(modelName)
                mapping=autosar.api.getSimulinkMapping(modelName);
                dataObj=autosar.api.getAUTOSARProperties(modelName,true);
                prportMap=containers.Map();
                enablePRPortChecking=true;
            end
            portInfo=cell(length(inoutH),6);
            for i=1:length(inoutH)
                if isInportArray(i)
                    isInport=true;
                    portH=inoutH(i);
                    portHDims=get_param(portH,'CompiledPortDimensions');
                    if~supportMatrixIO&&...
                        (portHDims.Outport(1)>1)&&...
                        (sum(portHDims.Outport(2:end)~=1)>1)
                        msg=DAStudio.message('RTW:autosar:scalarOnly',...
                        get_param(portH,'Name'));
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end


                    portHDataTypes=get_param(portH,'CompiledPortAliasedThruDataTypes');
                    portHDataTypesAliased=get_param(portH,'CompiledPortDataTypes');
                    portHWidths=get_param(portH,'CompiledPortWidths');
                    portInfo{i,1}=portHDataTypes.Outport{1};
                    portInfo{i,2}=portHWidths.Outport(1);
                    portInfo{i,3}=isInport;
                    portInfo{i,4}=get_param(portH,'CompiledSampleTime');
                    portInfo{i,5}=arblk.convertPortNameToArgName(get_param(portH,'Name'));
                    portInfo{i,6}=portHDataTypesAliased.Outport{1};
                    if enablePRPortChecking
                        autosar.validation.ClassicSLPortValidator.checkPRPort(...
                        dataObj,mapping,prportMap,...
                        get_param(portH,'Name'),portInfo(i,:));
                    end
                else
                    isInport=false;
                    portH=inoutH(i);
                    portHDims=get_param(portH,'CompiledPortDimensions');
                    if~supportMatrixIO&&...
                        (portHDims.Inport(1)>1)&&...
                        (sum(portHDims.Inport(2:end)~=1)>1)
                        msg=DAStudio.message('RTW:autosar:scalarOnly',get_param(portH,'Name'));
                        autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                    end


                    portHDataTypes=get_param(portH,'CompiledPortAliasedThruDataTypes');
                    portHDataTypesAliased=get_param(portH,'CompiledPortDataTypes');
                    portHWidths=get_param(portH,'CompiledPortWidths');
                    portInfo{i,1}=portHDataTypes.Inport{1};
                    portInfo{i,2}=portHWidths.Inport(1);
                    portInfo{i,3}=isInport;
                    portInfo{i,4}=get_param(portH,'CompiledSampleTime');
                    portInfo{i,5}=arblk.convertPortNameToArgName(get_param(portH,'Name'));
                    portInfo{i,6}=portHDataTypesAliased.Inport{1};
                    if enablePRPortChecking
                        autosar.validation.ClassicSLPortValidator.checkPRPort(...
                        dataObj,mapping,prportMap,...
                        get_param(portH,'Name'),portInfo(i,:));
                    end



                    blkObj=get_param(portH,'Object');
                    compiledSigObj=blkObj.CompiledSignalObject;
                    if~isempty(compiledSigObj)&&~strcmp(compiledSigObj.CoderInfo.StorageClass,'Auto')
                        autosar.validation.Validator.logError('RTW:autosar:nonAutoStorageClass',getfullname(portH));
                    end
                end

                portName=get_param(portH,'Name');
                portHandles=get_param(portH,'PortHandles');
                if isInport
                    thePort=portHandles.Outport;
                else
                    thePort=portHandles.Inport;
                end


                dataTypeName=get_param(thePort,'CompiledPortDataType');
                cs=getActiveConfigSet(hModel);
                maxShortNameLength=get_param(cs,'AutosarMaxShortNameLength');
                this.AutosarUtilsValidator.checkDataType(['Port ',portName],dataTypeName,maxShortNameLength,supportMatrixIO);


                dimsMode=get_param(thePort,'CompiledPortDimensionsMode');
                if any(dimsMode)
                    msg=DAStudio.message('RTW:autosar:variableSizeSignal',...
                    portName);
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end






                theRTWPort=thePort;
                csc=get_param(theRTWPort,'CompiledRTWStorageClass');
                if~isempty(csc)&&~strcmp(csc,'Auto')
                    autosar.validation.Validator.logError('RTW:autosar:nonAutoStorageClass',getfullname(portH));
                end

            end

            autosar.validation.ClassicSLPortValidator.checkApplImplClash(hModel,portInfo);
        end
    end

    methods(Static,Access=private)

        function verifyPortSignalObjectsHavePimCSC(hModel)




            if Simulink.internal.useFindSystemVariantsMatchFilter()

                ports=find_system(hModel,'FindAll','on','LookUnderMasks','on',...
                'FollowLinks','on','MatchFilter',@Simulink.match.activeVariants,...
                'Type','port','PortType','outport');
            else
                ports=find_system(hModel,'FindAll','on','LookUnderMasks','on',...
                'FollowLinks','on','Type','port','PortType','outport');
            end
            for portIdx=1:length(ports)
                dataObj=get_param(ports(portIdx),'CompiledSignalObject');
                isPIM_CSC=isa(dataObj,'AUTOSAR.Signal')&&...
                dataObj.getIsAutosarPerInstanceMemory();
                isPIM_CSC2=isa(dataObj,'Simulink.Signal')&&...
                strcmp(dataObj.CoderInfo.StorageClass,'Custom')&&...
                isa(dataObj.CoderInfo.CustomAttributes,'SimulinkCSC.AttribClass_AUTOSAR_PerInstanceMemory');
                if isPIM_CSC||isPIM_CSC2
                    msg=message(...
                    'RTW:autosar:PortWithPimCSC',...
                    get_param(ports(portIdx),'PortNumber'),...
                    get_param(ports(portIdx),'Parent'));
                    msg=MSLDiagnostic(msg).message;
                    autosar.validation.Validator.logError('RTW:fcnClass:finish',msg);
                end
            end

        end

        function validateVP(m3iObj,arRoot,modelName,blockPath)








            function result=bool2str(val)
                if val
                    result='enabled';
                else
                    result='disabled';
                end
            end

            exportVPs=autosar.mm.util.XmlOptionsAdapter.get(arRoot,'ExportPropagatedVariantConditions');
            if strcmp(exportVPs,'All')
                return;
            end

            if isempty(m3iObj)||isempty(m3iObj.variationPoint)
                return
            else
                expected=autosar.mm.util.evaluateSystemConstantExpression(modelName,m3iObj.variationPoint.Condition);
            end
            isEnabled=strcmp(get_param(blockPath,'CompiledIsActive'),'on');
            if expected~=isEnabled
                m3iCond=autosar.mm.util.extractCondExpressionFromM3iCondAccess(m3iObj.variationPoint.Condition);
                slCond=get_param(blockPath,'CompiledLocalVVCE');
                if isempty(slCond)
                    slCond='unconditional';
                end
                autosar.validation.Validator.logError('autosarstandard:validation:VariantConditionMismatch',...
                blockPath,m3iCond,bool2str(expected),slCond,bool2str(isEnabled));
            end
        end

        function verifyVariantConditions(hModel)




            modelName=get_param(hModel,'Name');
            if~autosar.api.Utils.isMapped(modelName)
                return
            end

            mapping=autosar.api.Utils.modelMapping(modelName);
            m3iModel=autosar.api.Utils.m3iModel(modelName);
            arRoot=m3iModel.RootPackage.front();
            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);

            portDict=containers.Map();
            m3iPortLists={m3iComp.ReceiverPorts;m3iComp.SenderPorts;...
            m3iComp.SenderReceiverPorts;m3iComp.ModeReceiverPorts;...
            m3iComp.ClientPorts;m3iComp.ServerPorts;...
            m3iComp.NvReceiverPorts;m3iComp.NvSenderPorts;...
            m3iComp.NvSenderReceiverPorts;m3iComp.ModeSenderPorts;};
            for ii=1:length(m3iPortLists)
                m3iPortList=m3iPortLists{ii};
                for jj=1:m3iPortList.size
                    m3iPort=m3iPortList.at(jj);
                    portDict(m3iPort.Name)=m3iPort;
                end
            end

            portMappings=[mapping.Inports,mapping.Outports];
            for ii=1:length(portMappings)
                portMap=portMappings(ii);

                if~portMap.IsActive||isempty(portMap.MappedTo)||isempty(portMap.MappedTo.Port)
                    continue;
                end

                if~isKey(portDict,portMap.MappedTo.Port)&&strcmp(get_param(portMap.Block,'IsBusElementPort'),'on')

                    continue;
                end

                m3iObj=portDict(portMap.MappedTo.Port);
                autosar.validation.ClassicSLPortValidator.validateVP(m3iObj,arRoot,modelName,portMap.Block);
            end

            for ii=1:length(mapping.FcnCallInports)
                fcnInportMap=mapping.FcnCallInports(ii);

                if~fcnInportMap.IsActive||isempty(fcnInportMap.MappedTo)||isempty(fcnInportMap.MappedTo.Runnable)
                    continue;
                end

                m3iObj=Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(...
                m3iComp.Behavior,...
                m3iComp.Behavior.Runnables,...
                fcnInportMap.MappedTo.Runnable,'Simulink.metamodel.arplatform.behavior.Runnable');
                autosar.validation.ClassicSLPortValidator.validateVP(m3iObj,arRoot,modelName,fcnInportMap.Block);
            end
        end

    end

    methods(Static,Access=private)

        function enable=isPRPortEnable(modelName)


            if~autosar.api.Utils.isMapped(modelName)
                enable=false;
                return
            end

            dataObj=autosar.api.getAUTOSARProperties(modelName,true);
            componentQualifiedName=dataObj.get('XmlOptions','ComponentQualifiedName');
            prports=dataObj.find(componentQualifiedName,'DataSenderReceiverPort',...
            'PathType','FullyQualified');

            if isempty(prports)
                enable=false;
            else
                enable=true;
            end
        end

        function checkPRPort(dataObj,mapping,prportMap,portName,portInfo)


            if strcmp(portInfo{1},'fcn_call')
                return;
            end

            if portInfo{3}
                [ARPortName,ARElementName,ARDataAccessMode]=...
                mapping.getInport(portName);
            else
                [ARPortName,ARElementName,ARDataAccessMode]=...
                mapping.getOutport(portName);
            end


            compQName=dataObj.get('XmlOptions','ComponentQualifiedName');
            portObj=dataObj.find(compQName,'DataSenderReceiverPort',...
            'PathType','FullyQualified','Name',ARPortName);
            if isempty(portObj)
                return;
            end
            interfaceName=dataObj.get(portObj{1},'Interface',...
            'PathType','FullyQualified');
            des=dataObj.get(interfaceName,'DataElements',...
            'PathType','FullyQualified');
            foundOne=false;
            for i=1:length(des)
                desName=dataObj.get(des{i},'Name');
                if strcmp(desName,ARElementName)
                    foundOne=true;
                end
            end

            if~foundOne
                return;
            end



            if strncmpi(ARDataAccessMode,'implicit',8)
                ARDataAccessMode='implicit';
            elseif strncmpi(ARDataAccessMode,'explicit',8)
                ARDataAccessMode='explicit';
            elseif strcmpi(ARDataAccessMode,'errorstatus')

                return;
            elseif strcmpi(ARDataAccessMode,'IsUpdated')

                autosar.validation.Validator.logError('autosarstandard:validation:isUpdatedInvalidSenderReceiverPort',...
                portName);
            elseif strncmpi(ARDataAccessMode,'EndToEnd',8)
                ARDataAccessMode='explicit';
            else
                autosar.validation.Validator.logError('RTW:autosar:invalidPRPortDAM',...
                portName,ARPortName,ARElementName);
            end



            key=[ARPortName,ARElementName];
            if~prportMap.isKey(key)
                prportMap(key)={portName,portInfo,ARDataAccessMode};%#ok<NASGU>
            else
                thatVal=prportMap(key);
                thatPortName=thatVal{1};
                thatPortInfo=thatVal{2};
                thatDAM=thatVal{3};




                if portInfo{3}==thatPortInfo{3}
                    autosar.validation.Validator.logError('RTW:autosar:invalidPRPortType',...
                    portName,thatPortName,ARPortName,ARElementName);
                end


                if~strcmp(ARDataAccessMode,thatDAM)
                    autosar.validation.Validator.logError('RTW:autosar:differentPRPortDAM',...
                    portName,thatPortName,ARPortName,ARElementName);
                end



                if~strcmp(portInfo{1},thatPortInfo{1})||...
                    ~strcmp(portInfo{6},thatPortInfo{6})||...
                    portInfo{2}~=thatPortInfo{2}
                    autosar.validation.Validator.logError('RTW:autosar:invalidPRPortDataType',...
                    portName,thatPortName,ARPortName,ARElementName);
                end



                prportMap.remove(key);
            end
        end

        function checkApplImplClash(hModel,portInfo)




            appl2impl=containers.Map();
            if autosar.api.Utils.isMapped(hModel)
                appl2impl=autosar.api.Utils.app2ImpMap(hModel);
            end

            alias2baseTypeMap=containers.Map();
            for ii=1:size(portInfo,1)
                baseDataType=portInfo{ii,1};
                aliasDataType=portInfo{ii,6};
                mprops=Simulink.getMetaClassIfValidEnumDataType(baseDataType);
                if~isempty(mprops)
                    storageType=Simulink.data.getEnumTypeInfo(baseDataType,'StorageType');
                    alias2baseTypeMap(aliasDataType)=storageType;
                else
                    alias2baseTypeMap(aliasDataType)=baseDataType;
                end
            end

            applDataTypes=appl2impl.keys;
            for ii=1:length(applDataTypes)
                applDataType=applDataTypes{ii};
                implDataType=appl2impl(applDataType);

                autosar.validation.ClassicSLPortValidator....
                validateApplImplBaseTypeConsistency(hModel,...
                alias2baseTypeMap,applDataType,implDataType);
            end
        end

        function validateApplImplBaseTypeConsistency(hModel,alias2baseTypeMap,applDataType,implDataType)



            if~(alias2baseTypeMap.isKey(applDataType)&&alias2baseTypeMap.isKey(implDataType))
                return;
            end
            applBaseType=alias2baseTypeMap(applDataType);
            implBaseType=alias2baseTypeMap(implDataType);

            if~autosar.mm.util.BuiltInTypeMapper.isFixPtTypeEquivalent(applBaseType,implBaseType)

                [~,applSlObj]=autosar.utils.Workspace.objectExistsInModelScope(hModel,applDataType);
                [~,implSlObj]=autosar.utils.Workspace.objectExistsInModelScope(hModel,implDataType);
                if isa(applSlObj,'Simulink.Bus')&&isa(implSlObj,'Simulink.Bus')


                    applElements=applSlObj.Elements;
                    implElements=implSlObj.Elements;
                    for elemIdx=1:length(applElements)
                        autosar.validation.ClassicSLPortValidator....
                        validateApplImplBaseTypeConsistency(hModel,...
                        alias2baseTypeMap,applElements(elemIdx).DataType,...
                        implElements(elemIdx).DataType);
                    end
                else
                    autosar.validation.Validator.logError('RTW:autosar:appl2implClash',applDataType,implDataType,applBaseType,implBaseType);
                end
            end
        end

    end

end




