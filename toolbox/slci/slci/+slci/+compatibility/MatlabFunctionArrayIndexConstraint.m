





classdef MatlabFunctionArrayIndexConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['For any array with dimension 1 in given index position, '...
            ,' index subscripting in that given position must be 1'];
        end


        function aObj=MatlabFunctionArrayIndexConstraint
            aObj.setEnum('MatlabFunctionArrayIndex');
            aObj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            owner=aObj.getOwner();
            assert(isa(owner,'slci.ast.SFAstArray'));

            children=owner.getChildren();
            numChild=numel(children);
            supported=true;

            if numChild>1
                baseAst=children{1};
                baseDim=baseAst.getDataDim();
                numIndex=numChild-1;
                if numel(baseDim)==numIndex
                    for idx=1:numIndex
                        if baseDim(idx)==1
                            isSupportedIndex=...
                            aObj.isSupportedIndex(children{idx+1});
                            if~isSupportedIndex
                                supported=false;
                                break;
                            end
                        end
                    end
                end
            end

            if~supported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum());
            end
        end

    end

    methods(Access=private)


        function out=isSupportedIndex(~,index)
            out=false;
            isConst=slci.matlab.astProcessor.AstSlciInferenceUtil.isConstant(...
            index);


            if isConst
                out=true;
                return;
            end


            isEnd=isa(index,'slci.ast.SFAstEnd');
            if isEnd
                out=true;
                return;
            end


            isColonWithNoOpnds=isa(index,'slci.ast.SFAstColon')...
            &&index.hasEmptyChildren();
            if isColonWithNoOpnds
                out=true;
                return;
            end

        end
    end
end