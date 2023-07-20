



classdef SFAstFloatNum<slci.ast.SFAst

    properties
        fValue=[];
        fSingle=false;
        fContextSensitive=false;
    end

    methods

        function out=getValue(aObj)
            out=aObj.fValue;
        end

        function out=IsDouble(aObj)
            out=~aObj.fSingle;
        end

        function out=IsSingle(aObj)
            out=aObj.fSingle;
        end

        function aObj=SFAstFloatNum(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            aObj.setValue(aAstObj);
            if aObj.fSingle
                aObj.fDataType='single';
            else
                aObj.fDataType='double';
            end
            aObj.fComputedDataType=true;
        end

        function setIsSingle(aObj,isSingle)
            assert(isa(isSingle,'logical'),...
            'fSingle must be set to a logical value')
            aObj.fSingle=isSingle;
            if aObj.fSingle
                aObj.fDataType='single';
            else
                aObj.fDataType='double';
            end
            aObj.fComputedDataType=true;
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            aObj.fDataDim=1;
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end
    end

    methods(Access=protected)


        function setValue(aObj,inputNode)
            assert(~isa(inputNode,'mtree'));
            aObj.fSingle=inputNode.sourceSnippet(end)=='F'||...
            inputNode.sourceSnippet(end)=='f';
            aObj.fContextSensitive=lower(inputNode.sourceSnippet(end))=='c';
            aObj.fValue=inputNode.value;
        end


        function out=IsContextSensitiveConstant(aObj)
            out=aObj.fContextSensitive;
        end

    end

end
