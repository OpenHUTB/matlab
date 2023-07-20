








classdef SFAstConcatenateLB<slci.ast.SFAst
    methods(Access=protected)




        function out=IsInvalidMixedType(aObj)
            out=aObj.IsMixedType;
        end

    end

    methods

        function ComputeDataType(aObj)






            children=aObj.getChildren();


            type_order=containers.Map(...
            {'uint8','uint16','uint32','int8','int16',...
            'int32','single','double','boolean'},...
            {1,1,1,1,1,1,2,3,4});
            type_index=-1;
            type='';
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


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
            children=aObj.getChildren();
            rowDim=0;
            colDim=0;
            for i=1:numel(children)
                child=children{i};
                assert(isa(child,'slci.ast.SFAstRow'),...
                ['Child of SFAstConcatenateLB is:',class(child)]);
                dim=child.getDataDim();
                assert(~isempty(dim));
                if numel(dim)~=2

                    return;
                end

                isMissingDim=isequal(dim,-1);
                if isMissingDim


                    return;
                end
                if colDim==0

                    colDim=dim(2);
                else


                    assert((dim(2)==-1)||(dim(2)==0)||(colDim==dim(2)));
                end

                rowDim=rowDim+dim(1);
            end


            aObj.setDataDim([rowDim,colDim]);
        end


        function aObj=SFAstConcatenateLB(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            message('Slci:slci:NotMtreeNode',...
            'SFAstConcatenateLB').getString);
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
        end


        function out=isEmptyBrackets(aObj)
            out=false;
            children=aObj.getChildren();
            if numel(children)==1
                if isa(children{1},'slci.ast.SFAstRow')
                    out=isempty(children{1}.getChildren);
                end
            end
        end

    end

    methods(Access=protected)


        function addMatlabFunctionConstraints(aObj)
            newConstraints={...
            slci.compatibility.MatlabFunctionDatatypeConstraint,...
            slci.compatibility.MatlabFunctionMissingDimConstraint,...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint};
            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end

    end

end
