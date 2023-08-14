

classdef SFAstArray<slci.ast.SFAst

    methods

        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            children=aObj.getChildren();

            aObj.fDataType=children{1}.getDataType();
        end


        function out=isIndexInt32(aObj)
            children=aObj.getChildren();
            assert(numel(children)>=2);

            for i=2:numel(children)
                indexDataType=children{i}.getDataType();
                if~strcmpi(indexDataType,'int32')
                    out=false;
                    return;
                end
            end
            out=true;
            return;
        end


        function out=isIndexUInt64(aObj)
            out=true;
            children=aObj.getChildren();
            assert(numel(children)>=2);

            for i=2:numel(children)
                indexDataType=children{i}.getDataType();
                if~strcmpi(indexDataType,'uint64')
                    out=false;
                    return;
                end
            end
        end


        function out=isOneDimensional(aObj)
            children=aObj.getChildren();
            out=(numel(children)==2);
            return;
        end


        function ComputeDataDim(aObj)



            assert(~aObj.fComputedDataDim);
            if~aObj.hasMtree
                aObj.setDataDim([1,1]);
                return;
            else

                children=aObj.getChildren();
                assert(numel(children)>0);
                baseAst=children{1};
                baseDim=baseAst.getDataDim();
                [flag,baseDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,baseDim);
                if~flag
                    return;
                end
                if prod(baseDim)==1
                    aObj.setDataDim([1,1]);
                    return;
                end


                dim=[];
                if numel(children)==2
                    index=children{2};
                    if isa(index,'slci.ast.SFAstColon')...
                        &&index.hasEmptyChildren

                        aObj.setDataDim(baseAst.getDataDim);
                        return;
                    elseif index.getDataDim~=-1

                        aObj.setDataDim(index.getDataDim);
                        return;
                    end
                elseif numel(children)==3
                    for i=2:numel(children)
                        child=children{i};
                        indexDim=child.getDataDim();
                        if indexDim==-1

                            return;
                        end
                        [flag,indexDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,indexDim);
                        if~flag
                            return;
                        end
                        length=prod(indexDim);
                        if((numel(indexDim)==2)...
                            &&(indexDim(1)~=1)&&(indexDim(2)~=1))

                            return;
                        end

                        dim=[dim,length];%#ok
                    end
                    aObj.setDataDim(dim);
                    return;
                end


                for i=2:numel(children)
                    child=children{i};
                    indexDim=child.getDataDim();
                    [flag,indexDim]=slci.internal.resolveDim(aObj.ParentModel.getHandle,indexDim);
                    if~flag
                        return;
                    end
                    if prod(indexDim)~=1
                        return;
                    end
                end
                aObj.setDataDim([1,1]);
            end



        end


        function aObj=SFAstArray(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)


        function addMatlabFunctionConstraints(aObj)
            dim={'Scalar','Vector','Matrix'};
            newConstraints={...
            slci.compatibility.MatlabFunctionDimConstraint(dim),...
            slci.compatibility.MatlabFunctionMissingDimConstraint,...
            slci.compatibility.MatlabFunctionArrayIndexConstraint,...
            slci.compatibility.MatlabFunctionArrayIndexNumConstraint
            };
            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end

    end

end
