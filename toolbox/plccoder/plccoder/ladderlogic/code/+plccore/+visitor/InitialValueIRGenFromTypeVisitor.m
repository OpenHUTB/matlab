classdef InitialValueIRGenFromTypeVisitor<plccore.visitor.AbstractVisitor



    methods
        function obj=InitialValueIRGenFromTypeVisitor
            obj.Kind='InitialValueIRGenFromTypeVisitor';
        end

        function ret=visitArrayType(obj,host,input)
            array_type=host;


            valueList=cell(1,array_type.numElem);
            for index=1:array_type.numElem
                valueList{index}=array_type.elemType.accept(obj,input(index));
            end

            ret=plccore.common.ArrayValue(array_type,valueList);
        end

        function ret=visitStructType(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitPOUType(obj,host,input)
            pou=host.pou;
            assert(isa(input,'struct'),'Matlab value should be a struct');
            struct_fields=fieldnames(input);
            fieldNameList={};
            fieldValueList={};
            fieldTypeList={};
            for index=1:length(struct_fields)
                field_name=struct_fields{index};

                [var,varScope]=plccore.common.Utils.getVarInstance(field_name,plccore.common.Context.empty,pou);

                if varScope==plccore.util.ScopeTypes.localScope||...
                    varScope==plccore.util.ScopeTypes.inOutScope
                    continue;
                end
                field_type=var.type;
                if isa(pou,'plccore.common.FunctionBlock')&&...
                    strcmp(field_name,'EnableIn')
                    field_value=plccore.common.ConstTrue;
                else
                    field_value=field_type.accept(obj,input.(field_name));
                end
                fieldNameList{end+1}=field_name;%#ok<AGROW>
                fieldValueList{end+1}=field_value;%#ok<AGROW>
                fieldTypeList{end+1}=field_type;%#ok<AGROW>
            end
            ret=plccore.common.StructValue(host,fieldNameList,fieldValueList);

        end

        function ret=visitTIMEType(obj,host,input)%#ok<INUSD>
            assert(false);
            ret=[];
        end

        function ret=visitBitFieldType(obj,host,input)%#ok<INUSD>
            ret='boolean';
        end

        function ret=visitNamedType(obj,host,input)

            struct_type=host.type;
            assert(isa(input,'struct'),'Matlab value should be a struct');
            fieldNameList=cell(1,struct_type.numFields);
            fieldValueList=cell(1,struct_type.numFields);
            for index=1:struct_type.numFields
                field_type=struct_type.fieldType(index);
                field_name=struct_type.fieldName(index);
                field_value=field_type.accept(obj,input.(field_name));
                fieldNameList{index}=field_name;
                fieldValueList{index}=field_value;
            end

            ret=plccore.common.StructValue(host,fieldNameList,fieldValueList);
        end

        function ret=visitBOOLType(obj,host,input)%#ok<INUSL>
            if input
                ret=plccore.common.ConstTrue;
            else
                ret=plccore.common.ConstFalse;
            end
        end

        function ret=visitDINTType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.DINTType,num2str(input));
        end

        function ret=visitINTType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.INTType,num2str(input));
        end

        function ret=visitLINTType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.LINTType,num2str(input));
        end

        function ret=visitLREALType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.LREALType,num2str(input));
        end

        function ret=visitREALType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.REALType,num2str(input));
        end

        function ret=visitSINTType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.SINTType,num2str(input));
        end

        function ret=visitUDINTType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.UDINTType,num2str(input));
        end

        function ret=visitULINTType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.ULINTType,num2str(input));
        end

        function ret=visitUSINTType(obj,host,input)%#ok<INUSL>
            ret=plccore.common.ConstValue(plccore.type.USINTType,num2str(input));
        end

    end

end

