

classdef ModelSymbolTable<handle
    properties(Access=private)

        fBusSymbolTable;
        fEnumSymbolTable;
    end

    methods

        function obj=ModelSymbolTable(mdl)
            obj.populateModelSymbolTables(mdl);
        end


        function out=getDefinedBusNames(aObj)
            out=aObj.fBusSymbolTable.getSymbols();
        end


        function out=getEnumSymbolTable(aObj)
            out=aObj.fEnumSymbolTable;
        end


        function out=getAllBusFieldTypeAndDim(aObj,busName)
            assert(aObj.hasBusDef(busName),'Bus not present in symbol table');
            out={};

            aBusSymTable=aObj.fBusSymbolTable.getType(busName);

            fieldNames=aBusSymTable.getFieldNames();

            for i=1:numel(fieldNames)
                [fieldType,fieldDim]=aObj.getFieldTypeAndDim(busName,...
                fieldNames{i});
                out{end+1}={fieldNames{i},fieldType,fieldDim};%#ok
            end
        end
    end


    methods(Access=private)

        function initSymbolTables(aObj)

            aObj.fBusSymbolTable=slci.mlutil.SymbolTable;


            aObj.fEnumSymbolTable=slci.mlutil.SymbolTable;
        end


        function populateModelSymbolTables(aObj,mdl)
            vars=Simulink.findVars(mdl,...
            'searchmethod','cached',...
            'IncludeEnumTypes',true);


            aObj.initSymbolTables();


            for i=1:numel(vars)
                try
                    varObj=slResolve(vars(i).Name,mdl);
                catch ME %#ok
                    varObj=[];
                end
                if aObj.isBusType(varObj)
                    busName=vars(i).Name;
                    aObj.addBusSymbol(busName,varObj,mdl);
                elseif aObj.isEnumType(class(varObj))
                    enumName=strtrim(class(varObj));
                    aObj.addEnumSymbol(enumName);
                elseif aObj.isEnumType(vars(i).Name)
                    enumName=strtrim(vars(i).Name);
                    aObj.addEnumSymbol(enumName);
                end
            end
        end


        function addBusSymbol(aObj,busName,varObj,mdl)
            if~aObj.fBusSymbolTable.hasSymbol(busName)
                aObj.fBusSymbolTable.addSymbol(...
                busName,...
                aObj.busToMLStructType(busName,varObj,mdl));
            end
        end


        function addEnumSymbol(aObj,enumName)
            if~aObj.fEnumSymbolTable.hasSymbol(enumName)
                enumDt=aObj.createEnumType(enumName);
                aObj.fEnumSymbolTable.addSymbol(...
                enumName,...
                enumDt);
            end
        end


        function out=createEnumType(~,enumName)
            out=slci.mlutil.EnumType(enumName);
            [enums,enumStrs]=enumeration(enumName);
            try
                out.setAddClassNameToEnumNames(enums.addClassNameToEnumNames);
            catch ME %#ok
                out.setAddClassNameToEnumNames(false);
            end
            for i=1:numel(enumStrs)
                name=enumStrs(i);
                value=double(enums(i));
                out.addElementAndValue(name,value);
            end
        end


        function out=busToMLStructType(~,busName,busObj,mdl)
            out=slci.mlutil.MLStructType(busName);
            elements=busObj.Elements;
            for i=1:numel(elements)
                fieldName=elements(i).Name;
                dataType=strtrim(elements(i).DataType);
                dim=elements(i).Dimensions;
                if ischar(dim)
                    dim=slci.internal.resolveSymbol(...
                    dim,'int32',mdl);
                    if isempty(dim)
                        dim=-1;
                    end
                end
                [flag,dim]=slci.internal.resolveDim(mdl,dim);
                if~flag
                    return;
                end
                dimensions=prod(dim);
                if(strncmp(dataType,'Enum:',5))
                    dataType=strtrim(dataType(6:end));
                elseif(strncmp(dataType,'?',1))
                    dataType=strtrim(dataType(2:end));
                elseif(strncmp(dataType,'Bus:',4))
                    dataType=strtrim(dataType(5:end));
                end
                fieldInfo=struct('Type',dataType,...
                'Size',dimensions);
                out.addField(fieldName,fieldInfo);
            end
        end


        function out=getBusDef(aObj,busName)
            assert(aObj.hasBusDef(busName));
            out=aObj.fBusSymbolTable.getType(busName);
        end


        function[fieldType,fieldDim]=getFieldTypeAndDim(aObj,busName,fieldName)
            fieldType=[];
            fieldDim=[];
            if aObj.hasBusDef(busName)

                busDef=aObj.getBusDef(busName);
                assert(isa(busDef,'slci.mlutil.MLStructType'));
                if busDef.hasField(fieldName)

                    fieldType=busDef.getFieldType(fieldName);
                    fieldDim=busDef.getFieldDim(fieldName);
                end
            end
        end

    end


    methods(Access=private)

        function out=isBusType(~,varObj)
            out=isa(varObj,'Simulink.Bus');
        end


        function out=isEnumType(~,enumName)
            out=Simulink.data.isSupportedEnumClass(enumName);
        end


        function out=hasBusDef(aObj,busName)
            out=aObj.fBusSymbolTable.hasSymbol(busName);
        end
    end
end
