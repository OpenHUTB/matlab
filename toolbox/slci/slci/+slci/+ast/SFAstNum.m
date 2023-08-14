



classdef SFAstNum<slci.ast.SFAst

    properties
        fValue=[];
    end

    methods


        function out=getValue(aObj)
            out=aObj.fValue;
        end


        function aObj=SFAstNum(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            aObj.setValue(aAstObj);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            if aObj.hasMtree()

                aObj.fDataType='double';
            end
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            if aObj.hasMtree()
                aObj.fDataDim=size(aObj.fValue);
            end
        end

    end

    methods(Access=protected)


        function setValue(aObj,inputNode)
            assert(isa(inputNode,'mtree'));
            [value,resolved]=slci.matlab.astTranslator.getMtreeValue(...
            inputNode,aObj.ParentBlock);
            if resolved

                assert(isa(value,'numeric')&&isscalar(value));
                aObj.fValue=double(value);
            else
                DAStudio.error('Slci:compatibility:ErrorReadingMtreeExpr',...
                aObj.ParentBlock.getSID());
            end
        end

    end


end
