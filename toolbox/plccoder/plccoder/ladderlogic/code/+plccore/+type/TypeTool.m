classdef TypeTool<handle




    methods(Static)
        function ret=isStructType(typ)
            ret=false;
            if isa(typ,'plccore.type.StructType')
                ret=true;
            elseif isa(typ,'plccore.type.NamedType')&&...
                isa(typ.type,'plccore.type.StructType')
                ret=true;
            end
        end

        function ret=structType(typ)
            import plccore.type.*;
            assert(TypeTool.isStructType(typ));
            ret=typ;
            if isa(typ,'plccore.type.NamedType')
                ret=typ.type;
            end
        end

        function ret=isNamedType(typ)
            ret=isa(typ,'plccore.type.NamedType');
        end

        function ret=isSlotType(typ)
            ret=isa(typ,'plccore.type.SlotType');
        end

        function ret=isNamedStructType(typ)
            import plccore.type.TypeTool;
            ret=TypeTool.isStructType(typ)&&TypeTool.isNamedType(typ);
        end

        function ret=isPOUType(typ)
            ret=isa(typ,'plccore.type.POUType');
        end

        function ret=isPOU(typ)
            import plccore.type.TypeTool;
            if TypeTool.isNamedType(typ)
                typ=typ.type;
            end
            ret=isa(typ,'plccore.common.POU');
        end

        function ret=isFunctionBlockPOUType(typ)
            ret=false;
            import plccore.type.TypeTool;
            if TypeTool.isPOUType(typ)
                if isa(typ.pou,'plccore.common.FunctionBlock')
                    ret=true;
                end
            end
        end

        function ret=isUnknownType(typ)
            import plccore.type.TypeTool;
            if TypeTool.isNamedType(typ)
                typ=typ.type;
            elseif TypeTool.isSlotType(typ)
                typ=typ.type;
            end
            ret=isa(typ,'plccore.type.UnknownType');
        end

        function ret=getUnknownType(typ,ctx)
            import plccore.type.*;

            ret=ctx.configuration.globalScope.getSymbol(typ.name);
        end

        function fieldType=getStructFieldType(structType,fieldName)
            if isa(structType,'plccore.type.NamedType')
                structType=structType.type;
            end
            assert(isa(structType,'plccore.type.StructType'));
            fieldId=structType.findField(fieldName);
            fieldType=structType.fieldType(fieldId);
        end

        function tf=hasStructField(structType,fieldName)

            if isa(structType,'plccore.type.NamedType')
                structType=structType.type;
            end
            assert(isa(structType,'plccore.type.StructType'));
            if structType.hasField(fieldName)
                tf=true;
            else
                tf=false;
            end

        end

        function tf=isArrayType(arrayType)
            if isa(arrayType,'plccore.type.NamedType')
                arrayType=arrayType.type;
            end

            if isa(arrayType,'plccore.type.ArrayType')
                tf=true;
            else
                tf=false;
            end
        end

        function name=getTypeName(typ)
            import plccore.type.TypeTool;
            if TypeTool.isNamedType(typ)
                name=typ.name;
            else
                name=typ.toString;
            end
        end

        function ret=isTimerCounterType(typ)
            import plccore.type.TypeTool;
            ret=false;
            if TypeTool.isNamedStructType(typ)&&...
                ismember(TypeTool.getTypeName(typ),{'TIMER','COUNTER'})
                ret=true;
            end
        end

        function ret=isIntegerType(typ)
            switch typ.kind
            case{'SINT','INT','DINT','LINT','USINT','UINT','UDINT','ULINT'}
                ret=true;
            otherwise
                ret=false;
            end
        end

        function ret=isRealType(typ)
            switch typ.kind
            case{'REAL'}
                ret=true;
            otherwise
                ret=false;
            end
        end

        function ret=isBoolType(typ)
            switch typ.kind
            case{'BOOL'}
                ret=true;
            otherwise
                ret=false;
            end
        end
    end
end


