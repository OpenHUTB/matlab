function type=getType(node,functionTypeInfo,functionInfoRegistry,idx)











    if nargin<4
        idx=1;
    end

    if strcmp(node.kind,'CALL')
        calledFcnTypeInfo=functionTypeInfo.treeAttributes(node).CalledFunction;

        if~isempty(calledFcnTypeInfo)
            fcnOutNodes=calledFcnTypeInfo.tree.Outs.List;

            if~isempty(fcnOutNodes)



                fcnOutNodeIndices=fcnOutNodes.indices;
                fcnOutNodeIdx=fcnOutNodeIndices(idx);
                outNode=fcnOutNodes.select(fcnOutNodeIdx);


                type=getTypeImpl(outNode,...
                calledFcnTypeInfo,functionInfoRegistry);
            else

                type=internal.mtree.type.UnknownType;
            end
        else


            if idx==1
                type=getTypeImpl(node,...
                functionTypeInfo,functionInfoRegistry);
            else

                type=internal.mtree.type.UnknownType;
            end
        end
    else
        assert(idx==1,'only functions have multiple outputs')
        type=getTypeImpl(node,functionTypeInfo,functionInfoRegistry);
    end
end

function type=getTypeImpl(node,functionTypeInfo,functionInfoRegistry)

    if strcmp(node.kind,'AT')

        type=internal.mtree.type.FunctionHandle(node.Arg.tree2str);
        type.setDimensions(1);
        return;
    end

    info=functionTypeInfo.treeAttributes(node);

    if~isempty(info.CompiledMxLocInfo)
        mxInferredTypeInfo=functionInfoRegistry.mxInfos{info.CompiledMxLocInfo.MxInfoID};


        if strcmp(mxInferredTypeInfo.Class,'struct')
            type=internal.mtree.type.StructType.fromStructInfo(...
            functionInfoRegistry,mxInferredTypeInfo);
        else
            typeInfo=coder.internal.FcnInfoRegistryBuilder.getInferredTypeInfo(...
            mxInferredTypeInfo,functionInfoRegistry.mxArrays);
            type=internal.mtree.Type.fromTypeInfo(typeInfo);
        end
    else

        type=internal.mtree.type.UnknownType;
        if strcmp(node.kind,'ID')




            varInfo=functionTypeInfo.getVarInfo(node);
            if~isempty(varInfo)
                type=internal.mtree.Type.fromVarTypeInfo(varInfo);
            end
        end
    end
end


