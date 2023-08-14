classdef Info<handle




    properties(GetAccess=public,SetAccess=immutable)

        CalleeFcnInfo(1,1)


        OutputSize(1,2)uint32=[1,1]


        ImageSize(1,2)uint32=[1,1]
    end

    properties(Access=public)



        iterNode=[];
    end

    methods(Access=public)

        function this=Info(node,fcnTypeInfoOrVarDescs,fcnInfoRegistry)


            useAggregate=false;
            this.CalleeFcnInfo=this.getCalledFcnTypeInfo(...
            node,fcnTypeInfoOrVarDescs,fcnInfoRegistry,useAggregate);

            if isa(fcnTypeInfoOrVarDescs,'internal.mtree.FunctionTypeInfo')
                lookUpVarDescs=true;
                fcnTypeInfo=fcnTypeInfoOrVarDescs;
                varDescs={};
            else
                lookUpVarDescs=false;
                fcnTypeInfo=[];
                varDescs=fcnTypeInfoOrVarDescs;
            end





            imageArg=node.Right.Next;
            if lookUpVarDescs
                imageDesc=internal.mtree.getVarDesc(imageArg,fcnTypeInfo);
                imageType=imageDesc.type;

                outArg=imageArg.Next;
                outDesc=internal.mtree.getVarDesc(outArg,fcnTypeInfo);
                outType=outDesc.type;
            else
                imageType=varDescs{2}.type;
                outType=varDescs{3}.type;
            end
            this.ImageSize=imageType.Dimensions;
            this.OutputSize=outType.Dimensions;
        end

    end

    methods(Static)
        function calledFcnTypeInfo=getCalledFcnTypeInfo(...
            npufunNode,fcnTypeInfoOrVarDescs,fcnInfoRegistry,useAggregate)

            calledFcnTypeInfo=[];


            fcnHandleNode=npufunNode.Right;
            if~strcmp(fcnHandleNode.kind,'AT')
                return;
            end

            fcnName=fcnHandleNode.Arg.string;
            numExpectedFcnTypeInfos=1;


            imageArgNode=fcnHandleNode.Next;
            if isempty(imageArgNode)
                return;
            end

            numArgs=count(npufunNode.Right.List);
            expectedTypes=cell(1,numArgs-1);
            argIdx=2;
            nextArgNode=imageArgNode;
            while~isempty(nextArgNode)
                calledFcnTypeInfosCell=cell(1,numExpectedFcnTypeInfos);
                argType=internal.mtree.utils.iteratorfun.Info.getType(nextArgNode,argIdx,fcnTypeInfoOrVarDescs,useAggregate);
                expectedTypes{argIdx-1}=argType.copy;

                nextArgNode=nextArgNode.Next;
                argIdx=argIdx+1;
            end


            argType=internal.mtree.utils.iteratorfun.Info.getType(imageArgNode,2,fcnTypeInfoOrVarDescs,useAggregate);
            idxType=internal.mtree.Type.getIntToHold(prod(argType.Dimensions),[1,1]);
            expectedTypes=[expectedTypes(1:2),{idxType},expectedTypes(3:end)];

            expectedTypes{1}.setDimensions([1,1]);


            registryKeys=sort(fcnInfoRegistry.registry.keys);

            for fcnInfoOutIdx=1:numExpectedFcnTypeInfos
                for keyIdx=1:numel(registryKeys)
                    info=fcnInfoRegistry.registry(registryKeys{keyIdx});

                    if strcmp(info.functionName,fcnName)
                        inNode=info.tree.Ins;

                        if numel(expectedTypes)~=count(inNode.List)
                            continue;
                        end
                        for kernelIdx=1:numel(expectedTypes)
                            inType=internal.mtree.getType(inNode,info,fcnInfoRegistry);
                            typesMatch=isequal(inType,expectedTypes{kernelIdx});

                            if~typesMatch
                                break;
                            end
                            inNode=inNode.Next;
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
            varDesc=internal.mtree.utils.iteratorfun.Info.getVarDesc(node,index,fcnTypeInfoOrVarDescs,useAggregate);
            type=varDesc.type;
        end

    end
end


