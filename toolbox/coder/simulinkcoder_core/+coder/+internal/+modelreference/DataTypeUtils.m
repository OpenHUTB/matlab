


classdef DataTypeUtils<handle
    methods(Access=public)




        function baseType=getBaseType(this,dataType)
            if(dataType.isScalar||dataType.isVoid||dataType.isComplex||dataType.isOpaque||dataType.isStructure)
                baseType=dataType;
            elseif dataType.isMatrix
                baseType=this.getBaseType(dataType.BaseType);
            elseif dataType.isPointer
                if isempty(dataType.Identifier)
                    this.setBaseTypeIdentifier(dataType);
                end
                baseType=dataType.BaseType;
            else
                assert(false,'Update getBaseType');
            end
        end
    end

    methods(Access=private)
        function setBaseTypeIdentifier(this,dataType)
            if isprop(dataType,'BaseType')&&~isempty(dataType.BaseType)&&isempty(dataType.Identifier)
                this.setBaseTypeIdentifier(dataType.BaseType);
                dataType.Identifier=[dataType.BaseType.Identifier,'*'];
            end
        end
    end

    methods(Static)
        function nullStr=getNullDefinition()
            nullStr='(NULL)';
        end


        function str=getInfinite()
            str='rtInf';
        end


        function str=getMinusInfinite()
            str='rtMinusInf';
        end


        function numStr=int2str(x)
            numStr=[num2str(x(1:end-1),'%d,'),int2str(x(end))];
        end


        function numStr=uint2str(x)
            numStr=[num2str(x(1:end-1),'%dU,'),int2str(x(end)),'U'];
        end


        function bStr=getBooleanString(boolVal)
            if(boolVal)
                bStr='true';
            else
                bStr='false';
            end
        end
    end
end


