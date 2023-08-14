









classdef SFAstRow<slci.ast.SFAst
    methods(Access=protected)




        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end

    end
    methods



        function ComputeDataType(aObj)



            if isa(aObj.getParent(),'slci.ast.SFAstConcatenateLB')



                type_order=containers.Map(...
                {'uint8','uint16','uint32','int8','int16',...
                'int32','single','double','boolean'},...
                {1,1,1,1,1,1,2,3,4});
                type_index=-1;
                type='';
                children=aObj.getChildren();
                for i=1:numel(children)
                    child=children{i};
                    child_type=child.getDataType();
                    if isKey(type_order,child_type)
                        index=type_order(child_type);
                        if isequal(type_index,-1)
                            type_index=index;
                            type=child_type;
                        elseif index<type_index
                            type_index=index;
                            type=child_type;
                        end
                    else

                        return;
                    end
                end

                if~isempty(type)
                    aObj.setDataType(type);
                end
            end
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
            children=aObj.getChildren();
            if isempty(children)

                aObj.setDataDim([0,0]);
                return;
            end

            rowDim=0;
            colDim=0;
            for i=1:numel(children)
                child=children{i};
                dim=child.getDataDim();
                assert(~isempty(dim));
                if numel(dim)~=2

                    return;
                end


                isMissingDim=isequal(dim,-1);
                isEmptyDim=all(dim)==0;
                if isEmptyDim||isMissingDim


                    continue;
                end
                if rowDim==0

                    rowDim=dim(1);
                else


                    assert((dim(1)==-1)||(rowDim==dim(1)));
                end

                colDim=colDim+dim(2);
            end
            if(rowDim~=0)&&(colDim~=0)

                aObj.setDataDim([rowDim,colDim]);
            end
        end


        function aObj=SFAstRow(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstRow').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end

    end

    methods(Access=protected)


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionEmptyOperandsConstraint,...
            slci.compatibility.MatlabFunctionMissingDimConstraint};
            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end

    end

end
