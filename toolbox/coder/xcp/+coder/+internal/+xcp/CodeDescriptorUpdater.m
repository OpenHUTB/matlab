classdef CodeDescriptorUpdater<handle




    properties(GetAccess=private,SetAccess=immutable)
BuildDir
IsDeploymentDiagram
NumTasks
Parser
TaskInfo
TargetAddressGranularity
    end

    properties(Access=private)
IsCurrentModelCppClass
VisitedModels
UpdateTIDs
UpdateAddresses
    end

    methods(Access=public)
        function obj=CodeDescriptorUpdater(...
            buildDir,...
            parser,...
            taskInfo,...
            numTasks,...
            isDeploymentDiagram,...
            targetAddressGranularity)

            obj.BuildDir=buildDir;
            obj.Parser=parser;
            obj.TargetAddressGranularity=targetAddressGranularity;
            obj.TaskInfo=taskInfo;
            obj.NumTasks=numTasks;
            obj.IsDeploymentDiagram=isDeploymentDiagram;

        end

        function updateTID(obj)

            obj.UpdateTIDs=true;
            obj.UpdateAddresses=false;
            obj.startUpdate();
        end

        function updateAddresses(obj)

            obj.UpdateTIDs=false;
            obj.UpdateAddresses=true;
            obj.startUpdate();
        end

        function updateAll(obj)

            obj.UpdateTIDs=true;
            obj.UpdateAddresses=true;
            obj.startUpdate();
        end
    end

    methods(Access=private)
        function startUpdate(obj)




            obj.VisitedModels=containers.Map('KeyType','char','ValueType','logical');













            codeDescriptor=coder.internal.getCodeDescriptorInternal(obj.BuildDir,247362);











            codeDescriptor.setAllowMultipleHandles(true);


            targetLang=get_param(codeDescriptor.ModelName,'TargetLang');
            codeInterfacePackaging=get_param(codeDescriptor.ModelName,'CodeInterfacePackaging');
            obj.IsCurrentModelCppClass=strcmp(targetLang,'C++')&&strcmp(codeInterfacePackaging,'C++ class');


            obj.updateModelCodeDescriptor(codeDescriptor,'','',0,0,true);
        end

        function updateModelCodeDescriptor(obj,...
            codeDescriptor,topLevelModelOrSubsystemBlockSID,...
            symbolPrefix,rtbAddress,rtdwAddress,isTopModel)












            obj.VisitedModels(codeDescriptor.ModelName)=true;

            if obj.UpdateAddresses

                obj.setAddressOrOffsetForVariablesInModel(...
                codeDescriptor,symbolPrefix,rtbAddress,isTopModel);
            end







            obj.updateTAQBlocks(codeDescriptor,...
            topLevelModelOrSubsystemBlockSID,isTopModel);


            if isTopModel&&obj.IsCurrentModelCppClass

                topModelObjectImplementation=codeDescriptor.getFullComponentInterface.getModelVariable;
                assert(isa(topModelObjectImplementation,'coder.descriptor.Variable')&&...
                isa(topModelObjectImplementation.Type,'coder.descriptor.types.Class'),...
                'invalid model object');
                symbolPrefix=[topModelObjectImplementation.assumeOwnershipAndGetExpression(),'.'];
            end




            bhm=codeDescriptor.getMF0BlockHierarchyMapForEdit();
            mdlBlks=bhm.getBlocksByType('ModelReference');
            for nMdlBlk=1:numel(mdlBlks)
                mdlBlk=mdlBlks(nMdlBlk);

                if mdlBlk.IsProtectedModelBlock
                    continue;
                end

                skipModelBlock=false;
                try
                    subCodeDescriptor=codeDescriptor.getReferencedModelCodeDescriptor(mdlBlk.ReferencedModelName);
                catch
                    skipModelBlock=true;
                end
                if skipModelBlock
                    continue;
                end

                newSymbolPrefix='';
                sub_rtbAddress=0;
                sub_rtdwAddress=0;

                if obj.UpdateAddresses
                    [newSymbolPrefix,sub_rtbAddress,sub_rtdwAddress]=...
                    obj.updateModelStructsAddressOrOffset(mdlBlk,symbolPrefix,rtdwAddress);
                end




                if obj.IsDeploymentDiagram&&isTopModel
                    topLevelModelOrSubsystemBlock=coder.internal.xcp.findRootLevelParentSubsystemBlock(mdlBlk);
                    topLevelModelOrSubsystemBlockSID=topLevelModelOrSubsystemBlock.SID;
                end

                if~obj.VisitedModels.isKey(subCodeDescriptor.ModelName)

                    currentIsCpp=obj.IsCurrentModelCppClass;
                    obj.IsCurrentModelCppClass=obj.isMdlBlockCppClass(mdlBlk);
                    obj.updateModelCodeDescriptor(...
                    subCodeDescriptor,topLevelModelOrSubsystemBlockSID,...
                    newSymbolPrefix,sub_rtbAddress,sub_rtdwAddress,...
                    false);

                    obj.IsCurrentModelCppClass=currentIsCpp;
                end
            end
        end

        function setAddressOrOffsetForVariablesInModel(obj,...
            codeDescriptor,symbolPrefix,rtbAddress,isTopModel)















            mf0Model=codeDescriptor.getMF0Model;
            a=mf0Model.allElements;%#ok







            codeDescriptor.beginTransaction();
            fullModel=codeDescriptor.getMF0FullModelForEdit();









            if~isempty(fullModel.CompiledCode)
                fullModel.CompiledCode.destroy;
            end
            fullModel.CompiledCode=coder.descriptor.CompiledCode(mf0Model);
            compiledCodeMaps=fullModel.CompiledCode;

            allDataIntrfs=coder.internal.xcp.getAllDataInterfaces(codeDescriptor);
            cleanupObj=onCleanup(@()codeDescriptor.commitTransaction());







            if~isTopModel
                p=codeDescriptor.getFullComponentInterface.Parameters.toArray();





                allDataIntrfs=setdiff(allDataIntrfs,p,'stable');
            end

            for i=1:numel(allDataIntrfs)
                dataIntrfCont=allDataIntrfs(i);
                obj.setAddressOrOffset(...
                compiledCodeMaps,symbolPrefix,rtbAddress,dataIntrfCont);
            end
            clear cleanupObj;

        end

        function setAddressOrOffset(obj,compiledCodeMaps,symbolPrefix,rtbAddress,dataInterfaceContainer)




            impl=dataInterfaceContainer.Implementation;
            if~isempty(dataInterfaceContainer.Type)&&~isempty(impl)&&...
                (isa(impl,'coder.descriptor.Variable')||isa(impl,'coder.descriptor.StructExpression'))&&...
                ~(isa(impl.Type,'coder.descriptor.types.Class')&&...
                strcmp(impl.Type.Identifier,'std::string'))

                if~impl.isDefined
                    obj.setVarOwner(impl);
                end
                expr=impl.assumeOwnershipAndGetExpression;

                if isempty(symbolPrefix)

                    try
                        symbol=obj.Parser.describeSymbol(expr);
                    catch
                        symbol.address=-1;
                    end
                else

                    expr=coder.internal.xcp.buildExpressionForMultiInstanceModelRef(...
                    impl,symbolPrefix);
                    try

                        symbol=obj.Parser.describeSymbol(expr);
                    catch
                        symbol.address=-1;
                    end
                end

                if(symbol.address==-1)
                    dataInterfaceContainer.AddressOrOffset=symbol.address;
                    compiledCodeMaps.createIntoDataInterfaceSymbols(...
                    struct('DataInterface',dataInterfaceContainer,...
                    'AddressOrOffset',uint64.empty,...
                    'TargetSize',uint64.empty));
                else
                    dataInterfaceContainer.AddressOrOffset=symbol.address-rtbAddress;
                    dataInterfaceSymbol=compiledCodeMaps.createIntoDataInterfaceSymbols(...
                    struct('DataInterface',dataInterfaceContainer,...
                    'AddressOrOffset',symbol.address-rtbAddress,...
                    'TargetSize',symbol.size*obj.TargetAddressGranularity));

                    err=obj.addNVBusTargetSizeAndOffsetToCodeDescriptor(compiledCodeMaps,dataInterfaceContainer.Type,symbol,expr);
                    if err


                        dataInterfaceContainer.AddressOrOffset=-1;
                        dataInterfaceSymbol.AddressOrOffset=uint64.empty;
                        dataInterfaceSymbol.TargetSize=uint64.empty;
                    end
                end
            end
        end

        function[symbolPrefix,rtbAddress,rtdwAddress]=updateModelStructsAddressOrOffset(obj,...
            mdlBlk,parentSymbolPrefix,parentRtdwAddress)

            symbolPrefix=coder.internal.xcp.buildModelRefPrefixExpression(...
            mdlBlk,parentSymbolPrefix,obj.IsCurrentModelCppClass);

            if~isempty(symbolPrefix)
                if obj.isMdlBlockCppClass(mdlBlk)


                    try
                        symbol=obj.Parser.describeSymbol(...
                        [parentSymbolPrefix,mdlBlk.ModelClassInstanceVariableName]);
                        rtbAddress=symbol.address;
                        mdlBlk.rtbAddressOrOffset=rtbAddress-parentRtdwAddress;
                        rtdwAddress=rtbAddress;
                        mdlBlk.rtdwAddressOrOffset=mdlBlk.rtbAddressOrOffset;
                    catch
                        rtbAddress=0;
                        mdlBlk.rtbAddressOrOffset=0;
                        rtdwAddress=0;
                        mdlBlk.rtdwAddressOrOffset=0;
                    end
                else










                    try
                        symbol=obj.Parser.describeSymbol([symbolPrefix,'rtb']);
                        rtbAddress=symbol.address;
                        mdlBlk.rtbAddressOrOffset=rtbAddress-parentRtdwAddress;
                    catch
                        rtbAddress=0;
                        mdlBlk.rtbAddressOrOffset=0;
                    end
                    try
                        symbol=obj.Parser.describeSymbol([symbolPrefix,'rtdw']);
                        rtdwAddress=symbol.address;
                        mdlBlk.rtdwAddressOrOffset=rtdwAddress-parentRtdwAddress;
                    catch
                        rtdwAddress=0;
                        mdlBlk.rtdwAddressOrOffset=0;
                    end
                end
            else

                rtbAddress=0;
                mdlBlk.rtbAddressOrOffset=0;
                rtdwAddress=0;
                mdlBlk.rtdwAddressOrOffset=0;
            end

        end

        function err=addNVBusTargetSizeAndOffsetToCodeDescriptor(obj,compiledCodeMaps,type,symbol,expr)

            if isa(type,'coder.descriptor.types.Matrix')&&...
                isa(type.BaseType,'coder.descriptor.types.Struct')



                AoBNEls=1;
                for nDim=1:type.Dimensions.Size
                    AoBNEls=AoBNEls*type.Dimensions(nDim);
                end

                targetSize=symbol.size/AoBNEls*obj.TargetAddressGranularity;
                type.BaseType.TargetSize=targetSize;

                alreadyAdded=~isempty(compiledCodeMaps.findType(type.BaseType));
                if alreadyAdded
                    err=false;
                    return;
                end
                compiledCodeMaps.createIntoTypes(...
                struct('Type',type.BaseType,...
                'TargetSize',targetSize));

                if AoBNEls>1
                    nvbus_baseExpr=[expr,'[0]'];
                else
                    nvbus_baseExpr=expr;
                end
                nvbus_baseAddr=symbol.address;
                nvbus_baseElements=type.BaseType.Elements;
                err=obj.addNVBusElementTargetOffset(compiledCodeMaps,nvbus_baseElements,nvbus_baseExpr,nvbus_baseAddr);
            elseif isa(type,'coder.descriptor.types.Struct')



                targetSize=symbol.size*obj.TargetAddressGranularity;
                type.TargetSize=targetSize;

                alreadyAdded=~isempty(compiledCodeMaps.findType(type));
                if alreadyAdded
                    err=false;
                    return;
                end
                compiledCodeMaps.createIntoTypes(...
                struct('Type',type,...
                'TargetSize',targetSize));

                nvbus_baseExpr=expr;
                nvbus_baseAddr=symbol.address;
                nvbus_baseElements=type.Elements;
                err=obj.addNVBusElementTargetOffset(compiledCodeMaps,nvbus_baseElements,nvbus_baseExpr,nvbus_baseAddr);
            else



                err=false;
                if type.isMatrix
                    numElements=prod(type.Dimensions.toArray);
                    baseType=type.BaseType;
                else
                    numElements=1;
                    baseType=type;
                end

                if baseType.isNumeric&&baseType.isHalf
                    if(symbol.size*obj.TargetAddressGranularity)~=(2*numElements)


                        err=true;
                    end
                end
            end
        end


        function err=addNVBusElementTargetOffset(obj,compiledCodeMaps,nvbus_elements,nvbus_baseExpr,nvbus_baseAddr)
            err=false;
            for nNVBusEl=1:length(nvbus_elements)

                alreadyAdded=~isempty(compiledCodeMaps.findStructElementSymbol(nvbus_elements(nNVBusEl)));
                if alreadyAdded
                    return;
                end

                nvbus_elementExpr=[nvbus_baseExpr,'.',nvbus_elements(nNVBusEl).Identifier];

                try
                    symbol=obj.Parser.describeSymbol(nvbus_elementExpr);
                catch
                    symbol.address=-1;
                end
                if symbol.address==-1
                    err=true;
                    return;
                end

                targetOffset=(symbol.address-nvbus_baseAddr)*obj.TargetAddressGranularity;
                targetSize=symbol.size*obj.TargetAddressGranularity;
                nvbus_elements(nNVBusEl).TargetOffset=targetOffset;

                compiledCodeMaps.createIntoStructElementSymbols(...
                struct('StructElement',nvbus_elements(nNVBusEl),...
                'AddressOrOffset',targetOffset,...
                'TargetSize',targetSize));


                err=obj.addNVBusTargetSizeAndOffsetToCodeDescriptor(compiledCodeMaps,nvbus_elements(nNVBusEl).Type,symbol,nvbus_elementExpr);
                if err
                    return;
                end
            end
        end


        function updateTAQBlocks(obj,codeDescriptor,topLevelModelOrSubsystemBlockSID,isTopModel)

            codeDescriptor.beginTransaction();

            fullModel=codeDescriptor.getMF0FullModelForEdit();
            compiledCodeMaps=fullModel.CompiledCode;

            taqBlocks=codeDescriptor.getMF0TAQBlocks.toArray;

            for nTAQBlock=1:numel(taqBlocks)
                taqBlock=taqBlocks(nTAQBlock);


                if obj.UpdateTIDs
                    obj.adjustTIDForTAQBlock(codeDescriptor,taqBlock,...
                    topLevelModelOrSubsystemBlockSID,isTopModel);
                end

                if~obj.UpdateAddresses

                    continue
                end




                obj.updateTaqBlockTargetDataTypeSize(codeDescriptor,compiledCodeMaps,taqBlock);





                if taqBlock.IsNVBus



                    di=coder.internal.xcp.findDataInterfaceForTAQBlock(codeDescriptor,taqBlock,-1);
                    if isempty(di)
                        continue;
                    end

                    type=di.Type;
                    isStruct=isa(type,'coder.descriptor.types.Struct');
                    isStructArray=isa(type,'coder.descriptor.types.Matrix')&&...
                    isa(type.BaseType,'coder.descriptor.types.Struct');
                    if~(isStruct||isStructArray)
                        continue;
                    end

                    diSymbol=compiledCodeMaps.findDataInterfaceSymbol(di);
                    if isempty(diSymbol)||isempty(diSymbol.AddressOrOffset)
                        continue;
                    end

                    if isStructArray
                        type=type.BaseType;
                    end

                    err=obj.addNVBusTargetSizeAndOffsetsToTAQBlock(compiledCodeMaps,taqBlock,type,0);
                    if err
                        continue;
                    end
                end
            end

            codeDescriptor.commitTransaction();

        end

        function adjustTIDForTAQBlock(obj,codeDescriptor,taqBlock,topLevelModelOrSubsystemBlockSID,isTopModel)


            if obj.NumTasks>0&&~strcmp(taqBlock.DomainType,'SLRT_kernel_data')
                entryPoint='';
                if obj.IsDeploymentDiagram
                    if isTopModel
                        entryPoint=taqBlock.ActSrcBlockSID;
                        entryPointBlock=coder.internal.xcp.getTaqBlkSrcBlock(codeDescriptor,taqBlock);
                        if~strcmp(entryPointBlock.Type,'ModelReference')


                            topLevelEntryPointBlock=coder.internal.xcp.findRootLevelParentSubsystemBlock(entryPointBlock);
                            entryPoint=topLevelEntryPointBlock.SID;
                        end
                    else
                        entryPoint=topLevelModelOrSubsystemBlockSID;
                    end
                end

                if taqBlock.IsVirtualBus
                    for nEl=1:double(taqBlock.LeafElements.Size)
                        taqBlockEl=taqBlock.LeafElements(nEl);


                        if~isnan(str2double(taqBlockEl.SampleTimeString))
                            for nTask=1:obj.NumTasks
                                foundIt=false;
                                if obj.TaskInfo(nTask).samplePeriod==taqBlockEl.DiscreteInterval&&...
                                    obj.TaskInfo(nTask).sampleOffset==taqBlockEl.DiscreteOffset&&...
                                    (isempty(entryPoint)||...
                                    any(strcmp(entryPoint,obj.TaskInfo(nTask).entryPoints)))
                                    taqBlockEl.Tid=int32(nTask-1);
                                    foundIt=true;
                                    break;
                                end
                            end
                            if~foundIt

                                taqBlock.IsLiveStreaming=false;
                                taqBlock.IsDeferredStreaming=false;
                                break;
                            end
                        end
                    end
                else

                    if~isnan(str2double(taqBlock.SampleTimeString))
                        foundIt=false;
                        for nTask=1:obj.NumTasks
                            if obj.TaskInfo(nTask).samplePeriod==taqBlock.DiscreteInterval&&...
                                obj.TaskInfo(nTask).sampleOffset==taqBlock.DiscreteOffset&&...
                                (isempty(entryPoint)||...
                                any(strcmp(entryPoint,obj.TaskInfo(nTask).entryPoints)))
                                taqBlock.Tid=int32(nTask-1);
                                foundIt=true;
                                break;
                            end
                        end
                        if~foundIt

                            taqBlock.IsLiveStreaming=false;
                            taqBlock.IsDeferredStreaming=false;
                        end
                    end
                end
            end
        end

    end

    methods(Access=private,Static)

        function isCppClass=isMdlBlockCppClass(mdlBlock)
            isCppClass=~isempty(mdlBlock.ModelClassInstanceVariableName);
        end

        function out=getBlockBySID(bhm,sid)
            blks=bhm.getBlocksBySID(sid);
            out=coder.descriptor.GraphicalBlock.empty;
            if~isempty(blks)
                out=blks(1);
            end
        end


        function err=addNVBusTargetSizeAndOffsetsToTAQBlock(compiledCodeMaps,taqBlock,type,offset)
            import coder.internal.xcp.CodeDescriptorUpdater;

            err=false;

            typeSymbol=compiledCodeMaps.findType(type);
            if isempty(typeSymbol)
                err=true;
                return;
            end

            taqBlock.DataTypeSize=typeSymbol.TargetSize;

            typeEls=type.Elements;
            typeElNames={typeEls.Identifier};

            for nEl=1:taqBlock.LeafElements.Size
                idx=strcmp(typeElNames,taqBlock.LeafElements(nEl).NVBusElementName);
                if numel(find(idx))~=1
                    err=true;
                    return;
                end
                typeEl=typeEls(idx);

                typeElSymbol=compiledCodeMaps.findStructElementSymbol(typeEl);
                if isempty(typeElSymbol)
                    err=true;
                    return;
                end
                elOffset=typeElSymbol.AddressOrOffset;

                isStruct=typeEl.Type.isStructure;
                isStructArray=typeEl.Type.isMatrix&&typeEl.Type.BaseType.isStructure;
                if isStruct

                    err=CodeDescriptorUpdater.addNVBusTargetSizeAndOffsetsToTAQBlock(...
                    compiledCodeMaps,taqBlock.LeafElements(nEl),typeEl.Type,offset+elOffset);
                elseif isStructArray

                    err=CodeDescriptorUpdater.addNVBusTargetSizeAndOffsetsToTAQBlock(...
                    compiledCodeMaps,taqBlock.LeafElements(nEl),typeEl.Type.BaseType,offset+elOffset);
                else

                    leafEl=taqBlock.LeafElements(nEl);
                    leafEl.NVBusOffset=offset+elOffset;




                    leafEl.TargetDataTypeSize=typeElSymbol.TargetSize/prod(leafEl.Dimensions.toArray);
                end
                if err
                    return;
                end
            end
        end

        function setVarOwner(impl)





            if isa(impl,'coder.descriptor.Variable')
                impl.VarOwner='SLRT';
            else
                coder.internal.xcp.CodeDescriptorUpdater...
                .setVarOwner(impl.BaseRegion);
            end
        end

        function ret=getDataInterfaceNumElements(dataInterface)


            diType=dataInterface.Type;

            if isempty(diType)||~diType.isMatrix

                ret=1;
            elseif diType.BaseType.isChar


                ret=1;
            else
                ret=prod(diType.Dimensions.toArray);
            end
        end

        function updateTaqBlockTargetDataTypeSizeInner(codeDescriptor,compiledCodeMaps,taqBlock,vBusElementIdx)

            import coder.internal.xcp.CodeDescriptorUpdater;

            di=coder.internal.xcp.findDataInterfaceForTAQBlock(codeDescriptor,taqBlock,vBusElementIdx);
            if~isempty(di)
                diSymbol=compiledCodeMaps.findDataInterfaceSymbol(di);
                if~isempty(diSymbol)&&~isempty(diSymbol.TargetSize)
                    taqBlock.TargetDataTypeSize=diSymbol.TargetSize/...
                    CodeDescriptorUpdater.getDataInterfaceNumElements(di);
                end
            end
        end

        function updateTaqBlockTargetDataTypeSize(codeDescriptor,compiledCodeMaps,taqBlock)


            import coder.internal.xcp.CodeDescriptorUpdater;

            if taqBlock.IsVirtualBus
                for kEl=1:double(taqBlock.LeafElements.Size)
                    taqBlockEl=taqBlock.LeafElements(kEl);
                    CodeDescriptorUpdater.updateTaqBlockTargetDataTypeSizeInner(...
                    codeDescriptor,compiledCodeMaps,taqBlockEl,kEl);
                end
            else
                vBusElementIdx=-1;
                CodeDescriptorUpdater.updateTaqBlockTargetDataTypeSizeInner(...
                codeDescriptor,compiledCodeMaps,taqBlock,vBusElementIdx);
            end
        end
    end
end
