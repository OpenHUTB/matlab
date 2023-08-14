



classdef SFAstIntegerNum<slci.ast.SFAst

    properties
        fValue=[];
        fContextSensitive=false;
    end

    methods


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            if(slcifeature('SLCI64BitSupportSF')==0)
                aObj.fDataType='int32';
            else
                aObj.fDataType=class(aObj.fValue);
            end
        end


        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            aObj.fDataDim=1;
        end

        function out=getValue(aObj)
            out=aObj.fValue;
        end

        function aObj=SFAstIntegerNum(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            aObj.setValue(aAstObj);
        end
    end

    methods(Access=protected)

        function setValue(aObj,inputNode)
            assert(~isa(inputNode,'mtree'));
            aObj.fContextSensitive=lower(inputNode.sourceSnippet(end))=='c';
            aObj.fValue=inputNode.value;
        end


        function out=IsContextSensitiveConstant(aObj)
            out=aObj.fContextSensitive;
        end

    end


end
