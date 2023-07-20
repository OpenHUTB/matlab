


classdef PortUtils<handle
    methods(Access=public)
        function setupOutportBlockLabel(this,ssOutBlkH,mdlRefOutBlkH,isExpanded)







            if numel(ssOutBlkH)>1



                return;
            end

            srcPort=this.getOutportBlockGraphicalSrc(ssOutBlkH);
            srcName='';
            if(ishandle(srcPort))
                srcName=get_param(srcPort,'Name');
            end

            if isempty(srcName)
                ssOBlkPortHs=get_param(ssOutBlkH,'PortHandles');
                label=get_param(ssOBlkPortHs.Inport(1),'GetInputSegmentSignalName');
                if~isempty(label)
                    mdlRefOBlkSrcPort=this.getOutportBlockGraphicalSrc(mdlRefOutBlkH);
                    if Simulink.ModelReference.Conversion.isBusElementPort(mdlRefOutBlkH)&&isExpanded
                        if~Simulink.ModelReference.Conversion.PortUtils.busElementOutPortInsideModelReferenceAssociateWithBusObject(mdlRefOutBlkH)
                            ele=get_param(mdlRefOutBlkH,'Element');
                            if~isempty(ele)
                                label=[label,'.',ele];
                            end
                            set_param(mdlRefOutBlkH,'Element',label);
                        end
                    else
                        set_param(mdlRefOBlkSrcPort,'Name',label);
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function varSizedSig=setIOAttributesForPorbBlockWithoutBusName(portBlock,portInfo,isRightClickBuild)
            portBlockObj=get_param(portBlock,'Object');
            blkType=portBlockObj.BlockType;
            isTriggerPort=strcmp(blkType,'TriggerPort');
            isEnablePort=strcmp(blkType,'EnablePort');
            varSizedSig=false;
            isBEP=Simulink.ModelReference.Conversion.isBusElementPort(portBlock);


            isBEPaPartOfABusObject=isBEP&&Simulink.ModelReference.Conversion.PortUtils.isPartOfABusObject(portBlock);
            if~isBEPaPartOfABusObject

                Simulink.ModelReference.Conversion.VariableDimensionPortsChecker.checkAndThrowErrorForVardim(portBlock,portInfo);

                checkAssertion=true;
                Simulink.ModelReference.Conversion.PortUtils.setCompiledDataType(portBlock,...
                portInfo.DataType,portInfo.AliasThruDataType,checkAssertion,isRightClickBuild);

                portBlockObj.PortDimensions=portInfo.computeDimensions;

                if~(isTriggerPort||isEnablePort)
                    portBlockObj.SignalType=portInfo.Complexity;
                    if strcmpi(portInfo.SamplingMode,'Frame Based')
                        portBlockObj.SamplingMode='Auto';
                    else
                        portBlockObj.SamplingMode=portInfo.SamplingMode;
                    end
                    portBlockObj.VarSizeSig=portInfo.VarSizeSig;
                    varSizedSig=strcmp(portInfo.VarSizeSig,'Yes');
                end
            end
        end

        function varSizedSig=setIOAttributesForPortBlockWithBusName(portBlock,portInfo,busName,dataConnection)
            portBlockObj=get_param(portBlock,'Object');
            isBEP=Simulink.ModelReference.Conversion.isBusElementPort(portBlock);

            if~strcmpi(portBlockObj.UseBusObject,'on')
                if~isBEP||isempty(portBlockObj.Element)
                    portBlockObj.UseBusObject='on';
                    portBlockObj.BusObject=busName;
                end
            end



            if portInfo.IsStructBus

                if~isBEP



                    portBlockObj.BusOutputAsStruct='on';
                    portBlockObj.PortDimensions=portInfo.DimensionStr;
                else
                    dataType=portBlockObj.OutDataTypeStr;
                    if length(dataType)<4||~strcmp(dataType(1:4),'Bus:')
                        portBlockObj.PortDimensions=portInfo.DimensionStr;
                        portBlockObj.OutDataTypeStr=['Bus: ',busName];
                    end
                end
            else
                portBlockObj.BusOutputAsStruct='off';
            end
            varSizedSig=Simulink.ModelReference.Conversion.VariableDimensionPortsChecker.checkBusVariableDimensionsMode(dataConnection,busName,portBlock);
        end



        function ispart=isPartOfABusObject(blk)
            assert(Simulink.ModelReference.Conversion.isBusElementPort(blk));
            el=get_param(blk,'Element');
            tree=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(blk).port.tree;
            n=Simulink.internal.CompositePorts.TreeNode.findNode(tree,el);
            ispart=~isempty(n.busTypeRootAttrs)||~isempty(n.busTypeElementAttrs);
        end
    end

    methods(Static,Access=public)


        function portContainsRateTransionBlk=portConnectedWithRTB(blockObj)
            portContainsRateTransionBlk=0;
            isInportOrFromLabel=(isa(blockObj,'Simulink.Inport')||isa(blockObj,'Simulink.From'));
            isOutportOrGotoLabel=(isa(blockObj,'Simulink.Outport')||isa(blockObj,'Simulink.Goto'));

            if isInportOrFromLabel
                portBlkPort=blockObj.PortHandles.Outport;
            elseif isOutportOrGotoLabel
                portBlkPort=blockObj.PortHandles.Inport;
            else
                throw(MException(message('Simulink:modelReference:convertToModelReference_ImplicitRTBCheckingOnInvalidPortBlocks')));
            end

            portObj=get_param(portBlkPort,'Object');
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
            if isInportOrFromLabel
                actblk=portObj.getActualDst;
            else
                actblk=portObj.getActualSrc;
            end

            if~isempty(actblk)
                actBlkHandle=actblk(:,1);
                parentHandles=Simulink.ModelReference.Conversion.Utilities.cellify(get_param(actBlkHandle,'ParentHandle'));
                for pi=1:numel(parentHandles)
                    obj=get_param(parentHandles{pi},'Object');
                    if strcmp(obj.BlockType,'RateTransition')&&obj.isSynthesized&&strcmp(obj.getSyntReason,'SL_SYNT_BLK_REASON_RATETRANS')
                        portContainsRateTransionBlk=1;
                        break;
                    end
                end
            end
            delete(sess);
        end



        function resVec=flattenSignalHierarchy(signalHierarchy)
            headStr=signalHierarchy.SignalName;
            resVec={};
            if isempty(signalHierarchy.Children)
                resVec={headStr};
                return;
            end

            for ii=1:numel(signalHierarchy.Children)
                strVec=Simulink.ModelReference.Conversion.PortUtils.flattenSignalHierarchy(signalHierarchy.Children(ii));
                for jj=1:numel(strVec)
                    if~isempty(headStr)
                        resVec=[resVec;[headStr,'.',strVec{jj}]];%#ok
                    else
                        resVec=[resVec;strVec{jj}];%#ok
                    end
                end
            end
        end










        function setIOAttributesForPortBlock(portBlock,portInfo,busName,dataConnection,isRightClickBuild)
            portBlockObj=get_param(portBlock,'Object');

            isBEP=Simulink.ModelReference.Conversion.isBusElementPort(portBlock);
            isInport=strcmp(portBlockObj.BlockType,'Inport');
            if~isempty(busName)
                varSizedSig=Simulink.ModelReference.Conversion.PortUtils.setIOAttributesForPortBlockWithBusName(portBlock,portInfo,busName,dataConnection);
            else
                varSizedSig=Simulink.ModelReference.Conversion.PortUtils.setIOAttributesForPorbBlockWithoutBusName(portBlock,portInfo,isRightClickBuild);
            end



            if varSizedSig&&isInport&&~isBEP
                portBlockObj.Interpolate='Off';
            end
        end










        function setCompiledDataType(blk,dtypeStr,aliasThruDtypeStr,checkAssertion,isRightClickBuild)
            blkObj=get_param(blk,'Object');
            Simulink.ModelReference.Conversion.PortUtils.checkBlockTypeBeforeSettingDataType(blkObj.BlockType);



            if strcmp(dtypeStr,'fcn_call')
                if strcmp(blkObj.BlockType,'Inport')
                    blkObj.OutputFunctionCall='on';
                end
                return;
            elseif sl('sldtype_is_builtin',dtypeStr)

                assert(strcmp(dtypeStr,aliasThruDtypeStr)||~checkAssertion);
                blkObj.OutDataTypeStr=dtypeStr;
                return;
            elseif strcmp(dtypeStr,'half')
                blkObj.OutDataTypeStr=dtypeStr;
                return;
            elseif(fixed.internal.type.isNameOfTraditionalFixedPointType(dtypeStr))
                assert(strcmp(dtypeStr,aliasThruDtypeStr)||~checkAssertion);
                dType=fixdt(dtypeStr);
                if~dType.isscaleddouble
                    blkObj.OutDataTypeStr=dType.tostring;
                    return;
                end
            elseif~strcmp(dtypeStr,aliasThruDtypeStr)
                blkObj.OutDataTypeStr=dtypeStr;
                return;
            elseif Simulink.data.isSupportedEnumClass(dtypeStr)

                blkObj.OutDataTypeStr=['Enum: ',dtypeStr];
                return;
            elseif strncmp(dtypeStr,'str',3)

                stringTypeStr=Simulink.internal.getStringDTExprFromDTName(dtypeStr);
                if~isempty(stringTypeStr)
                    blkObj.OutDataTypeStr=stringTypeStr;
                    return;
                end
            else
                [resolvedDataType,varExists]=slResolve(dtypeStr,blk,'variable');
                if varExists&&isa(resolvedDataType,'Simulink.DataType')
                    if(isa(resolvedDataType,'Simulink.Bus'))
                        blkObj.OutDataTypeStr=['Bus: ',dtypeStr];
                    else
                        blkObj.OutDataTypeStr=dtypeStr;
                    end
                    return;
                end
            end

            Simulink.ModelReference.Conversion.PortUtils.msgDataTypeIsNotProperlySet(blkObj,dtypeStr,isRightClickBuild);
        end

        function compIOInfo=getCompiledIOInfo(ssPortStruct,currentSubsystem,useTempModelAndNotCreateBusObjects)
















            if useTempModelAndNotCreateBusObjects
                subsystemPorts=get_param(currentSubsystem,'PortHandles');
                inportInfo=Simulink.ModelReference.Conversion.PortUtils.getCompBusFromPort(ssPortStruct,subsystemPorts,'Inport');
                outportInfo=Simulink.ModelReference.Conversion.PortUtils.getCompBusFromPort(ssPortStruct,subsystemPorts,'Outport');
                enableInfo=Simulink.ModelReference.Conversion.PortUtils.getCompBusFromPort(ssPortStruct,subsystemPorts,'Enable');
                triggerInfo=Simulink.ModelReference.Conversion.PortUtils.getCompBusFromPort(ssPortStruct,subsystemPorts,'Trigger');
                resetInfo=Simulink.ModelReference.Conversion.PortUtils.getCompBusFromPort(ssPortStruct,subsystemPorts,'Reset');
                fromInfo=Simulink.ModelReference.Conversion.PortUtils.getCompBusFromPort(ssPortStruct,subsystemPorts,'From');
                gotoInfo=Simulink.ModelReference.Conversion.PortUtils.getCompBusFromPort(ssPortStruct,subsystemPorts,'Goto');
                compIOInfo=[inportInfo,outportInfo,enableInfo,triggerInfo,resetInfo,fromInfo,gotoInfo];
            else
                compIOInfo=[];
                ssPortBlks=[ssPortStruct.inportBlksH.blocks;ssPortStruct.outportBlksH.blocks;...
                ssPortStruct.enableBlksH.blocks;ssPortStruct.triggerBlksH.blocks;...
                ssPortStruct.resetBlksH.blocks];
                ssPortHs=[ssPortStruct.inportBlksH.portHs';ssPortStruct.outportBlksH.portHs';...
                ssPortStruct.enableBlksH.portHs';ssPortStruct.triggerBlksH.portHs';...
                ssPortStruct.resetBlksH.portHs';];
                if isfield(ssPortStruct,'fromBlksH')
                    ssPortBlks=[ssPortBlks;ssPortStruct.fromBlksH.blocks];
                    ssPortHs=[ssPortHs;ssPortStruct.fromBlksH.portHs'];
                end
                if isfield(ssPortStruct,'gotoBlksH')
                    ssPortBlks=[ssPortBlks;ssPortStruct.gotoBlksH.blocks];
                    ssPortHs=[ssPortHs;ssPortStruct.gotoBlksH.portHs'];
                end

                numberOfPortBlocks=length(ssPortBlks);




                assert(length(ssPortHs)==numberOfPortBlocks);

                for idx=1:numberOfPortBlocks
                    compIOInfo(idx).block=ssPortBlks(idx);%#ok<AGROW>
                    compIOInfo(idx).port=ssPortHs(idx);%#ok<AGROW>
                    compIOInfo(idx).bus=get_param(ssPortHs(idx),'CompiledBusStruct');%#ok<AGROW>
                    compIOInfo(idx).portType=get_param(ssPortHs(idx),'PortType');
                end
            end
        end


        function setOutportRTWStorageClass(outPortHandle,storageClassInfo)
            outPortObj=get_param(outPortHandle,'Object');
            portParentIsBusSelector=strcmp(get_param(outPortObj.Parent,'BlockType'),'BusSelector');
            if~isempty(storageClassInfo.SignalObject)

















                assert(~isempty(storageClassInfo.RTWSignalIdentifier),...
                'Expecting non-empty RTWSignalIdentifier when reconstructing port which has a SignalObject resolved');
                if~portParentIsBusSelector
                    outPortObj.Name=storageClassInfo.RTWSignalIdentifier;
                end
                outPortObj.RTWStorageClass='Auto';
                outPortObj.RTWStorageTypeQualifier='';
                if~portParentIsBusSelector
                    if isequal(storageClassInfo.SignalObject.slWorkspaceType,'none')
                        outPortObj.MustResolveToSignalObject='off';
                        outPortObj.SignalObject=storageClassInfo.SignalObject;
                    else
                        outPortObj.MustResolveToSignalObject='on';
                    end
                end
            elseif~strcmp(storageClassInfo.RTWStorageClass,'Auto')
                if~portParentIsBusSelector
                    outPortObj.Name=storageClassInfo.RTWSignalIdentifier;
                end
                outPortObj.RTWStorageClass=storageClassInfo.RTWStorageClass;
                outPortObj.RTWStorageTypeQualifier=storageClassInfo.RTWStorageTypeQualifier;
            end
        end

        function[prmNames,prmVals]=getOutputSigInfo(oPort)
            objPrm=get_param(oPort,'ObjectParameters');
            allPrmNames=fieldnames(objPrm);
            numberOfParameters=length(allPrmNames);
            prmNames=cell(numberOfParameters,1);
            prmVals=cell(numberOfParameters,1);
            slowIdx=1;
            for idx=1:numberOfParameters
                thisPrm=allPrmNames{idx};
                if(any(strcmp('read-write',objPrm.(thisPrm).Attributes)))
                    prmNames{slowIdx}=thisPrm;
                    prmVals{slowIdx}=get_param(oPort,thisPrm);
                    slowIdx=slowIdx+1;
                end
            end
            prmNames=prmNames(1:slowIdx-1);
            prmVals=prmVals(1:slowIdx-1);
        end

        function setOutputSigInfo(oPort,prmNames,prmVals)
            arrayfun(@(prmIdx)set_param(oPort,prmNames{prmIdx},prmVals{prmIdx}),1:numel(prmNames));
        end


        function setupInportBlockLabel(subsys,ssInBlkH,mdlRefInBlkH,isCopyContent,useNewTemporaryModel,createBusObjectsForAllBuses)










            if numel(ssInBlkH)==1
                ssInBlkPorts=get_param(ssInBlkH,'PortHandles');
                realPortIdx=str2double(get_param(ssInBlkH,'Port'));
                srcName=get_param(ssInBlkPorts.Outport,'Name');
                mdlRefInBlkPortH=get_param(mdlRefInBlkH,'PortHandles');
                mdlRefName=get_param(mdlRefInBlkPortH.Outport,'Name');
                if isCopyContent
                    if useNewTemporaryModel&&~createBusObjectsForAllBuses








                        if isempty(srcName)
                            ssPortHs=get_param(subsys,'PortHandles');
                            label=get_param(ssPortHs.Inport(realPortIdx),'GetInputSegmentSignalName');
                            if~isempty(label)
                                mdlRefInBlkPortH=get_param(mdlRefInBlkH,'PortHandles');
                                set_param(mdlRefInBlkPortH.Outport,'Name',label);
                            end
                        else
                            mdlRefInBlkPortH=get_param(mdlRefInBlkH,'PortHandles');
                            set_param(mdlRefInBlkPortH.Outport,'Name',srcName);
                        end
                    else
                        if~(isempty(mdlRefName)&&isempty(srcName))
                            assert(strcmp(mdlRefName,srcName));
                        end
                    end
                end
                if isempty(srcName)
                    ssPortHs=get_param(subsys,'PortHandles');
                    label=get_param(ssPortHs.Inport(realPortIdx),'GetInputSegmentSignalName');
                    if~isempty(label)
                        mdlRefInBlkPortH=get_param(mdlRefInBlkH,'PortHandles');
                        set_param(mdlRefInBlkPortH.Outport,'Name',label);
                    end
                end
            end
        end


        function srcPort=getOutportBlockGraphicalSrc(oBlk)




            portH=get_param(oBlk,'PortHandles');
            lineH=get_param(portH.Inport(1),'Line');

            if(ishandle(lineH))
                srcPort=get_param(lineH,'SrcPortHandle');
            else
                srcPort=-1;
            end
        end



        function setBEPsExpandedFromPureVirtualBus(ioPortBlkInNewModel,compiledPortInfo,isRightClickBuild)
            ioPortBlkInNewModelObj=get_param(ioPortBlkInNewModel,'Object');
            assert(Simulink.ModelReference.Conversion.isBusElementPort(ioPortBlkInNewModel));

            intf=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(ioPortBlkInNewModel);

            node=Simulink.internal.CompositePorts.TreeNode.findNode(intf.port.tree,"");

            dataTypeOnParentOfBEP=Simulink.internal.CompositePorts.TreeNode.getDataType(node);
            if isstruct(compiledPortInfo.bus)&&~isempty(compiledPortInfo.bus.busObjectName)&&startsWith(dataTypeOnParentOfBEP,'Inherit: auto')

                intf=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(ioPortBlkInNewModel);

                node=Simulink.internal.CompositePorts.TreeNode.findNode(intf.port.tree,"");

                Simulink.internal.CompositePorts.TreeNode.setDataTypeCL(node,['Bus: ',compiledPortInfo.bus.busObjectName]);
            end


            dataTypeOnParentOfBEP=Simulink.internal.CompositePorts.TreeNode.getDataType(node);
            if~startsWith(dataTypeOnParentOfBEP,'Bus:')
                Simulink.ModelReference.Conversion.PortUtils.setCompiledDataType(ioPortBlkInNewModel,...
                compiledPortInfo.Attribute.DataType,compiledPortInfo.portAttributes.AliasThruDataType,false,isRightClickBuild);

                ioPortBlkInNewModelObj.PortDimensions=['[',num2str(compiledPortInfo.Attribute.Dimensions),']'];
                ioPortBlkInNewModelObj.VarSizeSig=compiledPortInfo.Attribute.DimensionsMode;
                if~isempty(compiledPortInfo.Attribute.Unit)
                    ioPortBlkInNewModelObj.Unit=compiledPortInfo.Attribute.Unit;
                end
                ioPortBlkInNewModelObj.SignalType=compiledPortInfo.Attribute.Complexity;
                if~isempty(compiledPortInfo.Attribute.Min)
                    ioPortBlkInNewModelObj.OutMin=compiledPortInfo.Attribute.Min;
                end

                if~isempty(compiledPortInfo.Attribute.Max)
                    ioPortBlkInNewModelObj.OutMax=compiledPortInfo.Attribute.Max;
                end
            end
        end




















        function expandedCompIOInfos=expandCompIOInfo(compIOInfo,useNewTemporaryModel,createBusObjectsForAllBuses)
            if~createBusObjectsForAllBuses
                expandedCompIOInfos=[];
                idx=1;
                for ii=1:numel(compIOInfo)
                    if compIOInfo(ii).isPureVirtualBus&&compIOInfo(ii).canExpand&&useNewTemporaryModel
                        comeFromMultiRates=false;
                        origSampleTimebase=compIOInfo(ii).elemAttributes(1).Attribute.SampleTime;
                        multiRateStartIdx=idx;
                        for jj=1:numel(compIOInfo(ii).elemAttributes)
                            expandedCompIOInfos(idx).block=compIOInfo(ii).block;
                            expandedCompIOInfos(idx).port=compIOInfo(ii).port;
                            expandedCompIOInfos(idx).bus=compIOInfo(ii).bus;
                            expandedCompIOInfos(idx).busName=compIOInfo(ii).busName;
                            expandedCompIOInfos(idx).busObject=compIOInfo(ii).busObject;
                            expandedCompIOInfos(idx).isPureVirtualBus=compIOInfo(ii).isPureVirtualBus;
                            expandedCompIOInfos(idx).signalPath=compIOInfo(ii).elemAttributes(jj).signalPath;
                            expandedCompIOInfos(idx).Attribute=compIOInfo(ii).elemAttributes(jj).Attribute;
                            expandedCompIOInfos(idx).portAttributes=compIOInfo(ii).portAttributes;
                            expandedCompIOInfos(idx).PortBlockType=get_param(compIOInfo(ii).block,'BlockType');

                            if any(strcmp(expandedCompIOInfos(idx).PortBlockType,'From'))||any(strcmp(expandedCompIOInfos(idx).PortBlockType,'Goto'))
                                expandedCompIOInfos(idx).PortIndex=1;
                            else
                                expandedCompIOInfos(idx).PortIndex=str2double(get_param(compIOInfo(ii).block,'Port'));
                            end

                            expandedCompIOInfos(idx).isExpanded=true;
                            if(~isequal(origSampleTimebase,compIOInfo(ii).elemAttributes(jj).Attribute.SampleTime))
                                comeFromMultiRates=true;
                            end
                            idx=idx+1;
                        end
                        multiRateEndIdx=idx-1;

                        for iii=multiRateStartIdx:multiRateEndIdx
                            expandedCompIOInfos(iii).isFromMultiRate=comeFromMultiRates;
                        end
                    else
                        expandedCompIOInfos(idx).block=compIOInfo(ii).block;
                        expandedCompIOInfos(idx).port=compIOInfo(ii).port;
                        expandedCompIOInfos(idx).bus=compIOInfo(ii).bus;
                        expandedCompIOInfos(idx).busName=compIOInfo(ii).busName;
                        expandedCompIOInfos(idx).busObject=compIOInfo(ii).busObject;
                        expandedCompIOInfos(idx).isPureVirtualBus=compIOInfo(ii).isPureVirtualBus;
                        expandedCompIOInfos(idx).signalPath=[];
                        expandedCompIOInfos(idx).Attribute=[];
                        expandedCompIOInfos(idx).portAttributes=compIOInfo(ii).portAttributes;
                        expandedCompIOInfos(idx).PortBlockType=get_param(compIOInfo(ii).block(1),'BlockType');
                        if strcmp(expandedCompIOInfos(idx).PortBlockType,'Inport')||strcmp(expandedCompIOInfos(idx).PortBlockType,'Outport')
                            expandedCompIOInfos(idx).PortIndex=str2double(get_param(compIOInfo(ii).block(1),'Port'));
                        else
                            expandedCompIOInfos(idx).PortIndex='-1';
                        end
                        expandedCompIOInfos(idx).isExpanded=false;
                        expandedCompIOInfos(idx).isFromMultiRate=false;
                        idx=idx+1;
                    end
                end
            else
                expandedCompIOInfos=compIOInfo;
                for ii=1:numel(expandedCompIOInfos)
                    expandedCompIOInfos(ii).isExpanded=false;
                    expandedCompIOInfos(ii).isFromMultiRate=false;
                end
            end
        end
    end

    methods(Static,Access=private)
        function isTrue=busElementOutPortInsideModelReferenceAssociateWithBusObject(mdlRefOutBlkH)

            intf=Simulink.BlockDiagram.Internal.getInterfaceModelBlock(mdlRefOutBlkH);

            node=Simulink.internal.CompositePorts.TreeNode.findNode(intf.port.tree,"");

            dataTypeOnParentOfBEP=Simulink.internal.CompositePorts.TreeNode.getDataType(node);
            isTrue=startsWith(dataTypeOnParentOfBEP,'Bus:');
        end

        function msgDataTypeIsNotProperlySet(blkObj,dtypeStr,isRightClickBuild)
            if isRightClickBuild
                blkObj.OutDataTypeStr='Inherit: auto';
                disp(DAStudio.message('RTW:buildProcess:CustomDataSSWithSFcn',...
                dtypeStr));
            else
                throw(MException(message('Simulink:modelReference:slss2mdlUnsupportedDataType',dtypeStr)));
            end

        end

        function checkBlockTypeBeforeSettingDataType(blkType)
            assert(strcmp(blkType,'Outport')||strcmp(blkType,'Inport')||...
            strcmp(blkType,'TriggerPort')||strcmp(blkType,'EnablePort'));
        end

        function portNum=getFromOrGotoLabelPortNumber(ssPortStruct,PortType)
            portNum=0;
            if strcmp(PortType,'From')
                if isfield(ssPortStruct,'fromBlksH')
                    fromBlksH=ssPortStruct.fromBlksH;
                    if isfield(fromBlksH,'blocks')
                        portNum=numel(fromBlksH.blocks);
                    end
                end
            else
                if isfield(ssPortStruct,'gotoBlksH')
                    gotoBlksH=ssPortStruct.gotoBlksH;
                    if isfield(gotoBlksH,'blocks')
                        portNum=numel(gotoBlksH.blocks);
                    end
                end
            end
        end

        function res=getCompBusOfGotoFrom(ssPortStruct,PortType)
            res=[];
            portNum=Simulink.ModelReference.Conversion.PortUtils.getFromOrGotoLabelPortNumber(ssPortStruct,PortType);
            for idx=1:portNum
                if strcmp(PortType,'From')
                    ports=ssPortStruct.fromBlksH.portHs(idx);
                else
                    ports=ssPortStruct.gotoBlksH.portHs(idx);
                end
                curPort=ports;
                t.port=curPort;
                compBusStruct=get_param(curPort,'CompiledBusStruct');
                compBusSource=get_param(curPort,'CompiledBusSource');
                t.bus=Simulink.ModelReference.Conversion.PortUtils.combineBusStructAndBusSource(compBusStruct,compBusSource);
                if strcmp(PortType,'From')
                    pb=ssPortStruct.fromBlksH.blocks(idx);
                else
                    pb=ssPortStruct.gotoBlksH.blocks(idx);
                end
                t.block=pb;
                t.portType=PortType;
                res=[res,t];%#ok
            end
        end

        function res=getCompBusOfPortBlocks(ssPortStruct,subsystemPorts,PortType)
            res=[];
            portNum=numel(subsystemPorts.(PortType));
            for idx=1:portNum
                ports=subsystemPorts.(PortType);
                curPort=ports(idx);
                t.port=curPort;
                compBusStruct=get_param(curPort,'CompiledBusStruct');
                compBusSource=get_param(curPort,'CompiledBusSource');
                t.bus=Simulink.ModelReference.Conversion.PortUtils.combineBusStructAndBusSource(compBusStruct,compBusSource);
                portBlk=[lower(PortType),'BlksH'];
                if isfield(ssPortStruct,portBlk)
                    pb=ssPortStruct.(portBlk);
                    pb=pb.blocks;
                    if strcmp(PortType,'Reset')||strcmp(PortType,'Trigger')||strcmp(PortType,'Enable')
                        t.block=pb;
                    else
                        t.block=pb(str2double(get_param(pb,'Port'))==idx);
                    end
                    t.portType=PortType;
                    res=[res,t];%#ok
                end
            end
        end

        function res=getCompBusFromPort(ssPortStruct,subsystemPorts,PortType)
            if(strcmp(PortType,'From')||strcmp(PortType,'Goto'))
                res=Simulink.ModelReference.Conversion.PortUtils.getCompBusOfGotoFrom(ssPortStruct,PortType);
            else
                res=Simulink.ModelReference.Conversion.PortUtils.getCompBusOfPortBlocks(ssPortStruct,subsystemPorts,PortType);
            end
        end


        function[compBusStruct]=combineBusStructAndBusSource(compiledBusStruct,compiledBusSource)
            compBusStruct=[];
            if~isempty(compiledBusStruct)&&~isempty(compiledBusSource)
                compBusStruct.name=compiledBusStruct.name;
                compBusStruct.srcSignalName=compiledBusStruct.srcSignalName;
                compBusStruct.src=compiledBusStruct.src;
                compBusStruct.srcPort=compiledBusStruct.srcPort;
                compBusStruct.busObjectName=compiledBusStruct.busObjectName;
                compBusStruct.parentBusObjectName=compiledBusStruct.parentBusObjectName;
                compBusStruct.flatDataTypeElemIdx=compiledBusStruct.flatDataTypeElemIdx;
                compBusStruct.dfsDataTypeElemIdx=compiledBusStruct.dfsDataTypeElemIdx;
                compBusStruct.srcBlock=compiledBusSource.srcBlock;
                compBusStruct.srcOutport=compiledBusSource.srcOutport;
                compBusStruct.dstBlock=compiledBusSource.dstBlock;
                compBusStruct.dstInport=compiledBusSource.dstInport;
                compBusStruct.DFSIndex=compiledBusSource.DFSIndex;
                if~isempty(compiledBusStruct.signals)
                    assert(numel(compiledBusStruct.signals)==numel(compiledBusSource.subsignals))
                    for ii=1:numel(compiledBusStruct.signals)
                        curStruct=Simulink.ModelReference.Conversion.PortUtils.combineBusStructAndBusSource(compiledBusStruct.signals(ii),compiledBusSource.subsignals(ii));
                        if~isfield(curStruct,'signals')
                            curStruct.signals=[];
                        end
                        compBusStruct.signals(ii)=curStruct;
                    end
                end
            end
        end
    end
end


