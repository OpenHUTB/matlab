function calledFcnTypeInfo=getCalledFcnTypeInfo(npufunNode,fcnTypeInfoOrVarDescs,fcnInfoRegistry,npuInfo,useAggregate)





    calledFcnTypeInfo=[];


    fcnHandleNode=npufunNode.Right;
    if~strcmp(fcnHandleNode.kind,'AT')
        return;
    end

    fcnName=fcnHandleNode.Arg.string;


    sizeArgNode=fcnHandleNode.Next;
    if isempty(sizeArgNode)
        return;
    end

    sizeArgVarDesc=getVarDesc(sizeArgNode,2,fcnTypeInfoOrVarDescs,useAggregate);
    if~sizeArgVarDesc.isConst
        return;
    end

    if useAggregate

        allSizeArgs=sizeArgVarDesc.constVal;
        numSizeArgs=numel(allSizeArgs);
        uniqueSizeArgs=cell(1,numSizeArgs);
        uniqueSizeArgIdx=1;

        for i=1:numSizeArgs





            if~any(cellfun(@(x)isequal(x,allSizeArgs{i}),uniqueSizeArgs),'all')
                uniqueSizeArgs{uniqueSizeArgIdx}=allSizeArgs{i};
                uniqueSizeArgIdx=uniqueSizeArgIdx+1;
            end
        end

        numExpectedFcnTypeInfos=uniqueSizeArgIdx-1;
        sizeArgs=uniqueSizeArgs(1:numExpectedFcnTypeInfos);
    else
        numExpectedFcnTypeInfos=1;
        sizeArgs={sizeArgVarDesc.constVal};
    end


    imageArgNode=sizeArgNode.Next;

    if isempty(imageArgNode)
        return;
    end

    numImages=numel(npuInfo.StreamedArgIdxs);
    expectedTypes=cell(1,numImages);


    currIdx=3;
    while~isempty(imageArgNode)
        [isCurrIdxStreamed,locCurrIdx]=ismember(currIdx,npuInfo.StreamedArgIdxs);
        if isCurrIdxStreamed
            imageArgType=getType(imageArgNode,npuInfo.StreamedArgIdxs(locCurrIdx),fcnTypeInfoOrVarDescs,useAggregate);




            expectedTypes{locCurrIdx}=cell(1,numExpectedFcnTypeInfos);
            for j=1:numExpectedFcnTypeInfos
                expectedType=imageArgType.copy;
                expectedType.setDimensions(sizeArgs{j});
                expectedTypes{locCurrIdx}{j}=expectedType;
            end
        end
        currIdx=currIdx+1;
        imageArgNode=imageArgNode.Next;
    end

    calledFcnTypeInfosCell=cell(1,numExpectedFcnTypeInfos);



    registryKeys=sort(fcnInfoRegistry.registry.keys);

    for fcnInfoOutIdx=1:numExpectedFcnTypeInfos
        for keyIdx=1:numel(registryKeys)
            info=fcnInfoRegistry.registry(registryKeys{keyIdx});

            if strcmp(info.functionName,fcnName)
                typesMatch=true;
                currKernelIdx=1;
                inNode=info.tree.Ins;


                while~isempty(inNode)&&currKernelIdx<=numel(npuInfo.KernelArgIdxs)
                    [isStreamedKernelIdx,locStreamedKernelIdx]=ismember(currKernelIdx,npuInfo.StreamedArgIdxsInternal);
                    if isStreamedKernelIdx
                        inType=internal.mtree.getType(inNode,info,fcnInfoRegistry);
                        typesMatch=isequal(inType,expectedTypes{locStreamedKernelIdx}{fcnInfoOutIdx});
                    end
                    if~typesMatch
                        break;
                    end
                    inNode=inNode.Next;
                    currKernelIdx=currKernelIdx+1;
                end


                if typesMatch
                    calledFcnTypeInfosCell{fcnInfoOutIdx}=info;
                    break;
                end
            end
        end
    end

    if all(cellfun(@(x)~isempty(x),calledFcnTypeInfosCell),'all')
        calledFcnTypeInfo=[calledFcnTypeInfosCell{:}];
    end

end

function varDesc=getVarDesc(node,index,fcnTypeInfoOrVarDescs,useAggregate)
    if isa(fcnTypeInfoOrVarDescs,'internal.mtree.FunctionTypeInfo')
        fcnTypeInfo=fcnTypeInfoOrVarDescs;

        if useAggregate
            varDesc=internal.mtree.getVarDesc(node,fcnTypeInfo,'treeAttributesAggregate');
        else
            varDesc=internal.mtree.getVarDesc(node,fcnTypeInfo);
        end
    else
        varDesc=fcnTypeInfoOrVarDescs{index};
    end
end

function type=getType(node,index,fcnTypeInfoOrVarDescs,useAggregate)
    varDesc=getVarDesc(node,index,fcnTypeInfoOrVarDescs,useAggregate);
    type=varDesc.type;
end


