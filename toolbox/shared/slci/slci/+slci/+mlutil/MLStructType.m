




classdef MLStructType<handle


    properties

        fTypeTable;

        fDimTable;

        fName;

        fFields;
    end

    methods(Access=public)


        function aObj=MLStructType(aName)
            aObj.fName=aName;
            aObj.fTypeTable=slci.mlutil.SymbolTable;
            aObj.fDimTable=containers.Map('KeyType','char',...
            'ValueType','Any');
        end


        function addField(aObj,fieldName,fieldInfo)
            assert(isstruct(fieldInfo));
            assert(~aObj.hasField(fieldName));
            aObj.fFields{end+1}=fieldName;
            aObj.addFieldType(fieldName,fieldInfo.Type);
            aObj.addFieldDim(fieldName,fieldInfo.Size);
        end


        function fieldNames=getFieldNames(aObj)
            fieldNames=aObj.fFields;
        end


        function flag=hasField(aObj,fieldName)
            flag=any(strcmp(aObj.fFields,fieldName));
        end


        function fieldType=getFieldType(aObj,field)
            assert(aObj.fTypeTable.hasSymbol(field));
            fieldType=aObj.fTypeTable.getType(field);
        end


        function fieldDim=getFieldDim(aObj,field)
            assert(isKey(aObj.fDimTable,field));
            fieldDim=aObj.fDimTable(field);
        end


        function name=getName(aObj)
            name=aObj.fName;
        end

    end

    methods(Access=private)


        function addFieldType(aObj,fieldName,fieldType)
            assert(~aObj.fTypeTable.hasSymbol(fieldName));
            aObj.fTypeTable.addSymbol(fieldName,fieldType);
        end


        function addFieldDim(aObj,fieldName,fieldDim)
            assert(~isKey(aObj.fDimTable,fieldName));
            aObj.fDimTable(fieldName)=double(fieldDim);
        end
    end

end
