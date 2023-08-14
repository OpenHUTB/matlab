

classdef SFAstString<slci.ast.SFAst

    properties
        fValue=[];
    end

    methods


        function out=getValue(aObj)
            out=aObj.fValue;
        end


        function aObj=SFAstString(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            aObj.setValue(aAstObj);
        end


        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            aObj.fDataType='char';
        end


        function ComputeDataDim(aObj)

            assert(~aObj.fComputedDataDim);

        end

    end

    methods(Access=protected)


        function setValue(aObj,inputNode)
            if isa(inputNode,'mtree')
                str=inputNode.string;
                tokens=regexp(str,'^('')(.*)('')$','tokens');
                if~isempty(tokens)
                    aObj.fValue=tokens{1}{2};
                else
                    aObj.fValue=str;
                end
            else
                assert(['Cannot translate input of type ',class(inputNode),'to SFAstString']);
            end
        end

    end

end
