



classdef TypeInference<handle

    properties(Access=private)


        fMtreeInference=[];


        fTypeTable=[];


        fBusTable=[];

    end


    methods(Access=public)



        function obj=TypeInference(mtreeToInference,typeTable)
            assert(isa(mtreeToInference,'containers.Map'),...
            'Invalid input argument');
            obj.fMtreeInference=mtreeToInference;
            obj.fTypeTable=typeTable;
            obj.populateBusTable(obj.fTypeTable);
        end


        function[astTable,typeTable]=apply(obj,astTable)

            assert(isa(astTable,'containers.Map'),...
            'Invalid input argument');


            fids=keys(astTable);
            for k=1:numel(fids)
                fid=fids{k};
                ast=astTable(fid);
                if isKey(obj.fMtreeInference,fid)
                    funcInference=obj.fMtreeInference(fid);
                    ast=obj.inferType(ast,funcInference);
                    astTable(fid)=ast;
                end
            end

            typeTable=obj.fTypeTable;



        end

    end

    methods(Access=private)


        function populateBusTable(aObj,typeTable)
            aObj.fBusTable=slci.mlutil.SymbolTable;
            symbols=typeTable.getSymbols();
            for k=1:numel(symbols)
                symbol=symbols{k};
                symbolType=typeTable.getType(symbol);
                if isa(symbolType,'Simulink.Bus')
                    assert(~aObj.fBusTable.hasSymbol(symbol));
                    aObj.fBusTable.addSymbol(symbol,symbolType);
                end
            end
        end



        function name=getNameOfMappedType(aObj,structType)
            mappedType=aObj.getMappedType(structType);
            assert(isa(mappedType,'slci.mlutil.NamedType')||...
            isa(mappedType,'slci.mlutil.MLStructType'));
            name=mappedType.getName();
        end



        function mappedType=getMappedType(aObj,structType)
            assert(isa(structType,'slci.mlutil.MLStructType'));
            structName=structType.getName();
            if~aObj.fTypeTable.hasSymbol(structName)
                aObj.populateType(structType);
            end
            mappedType=aObj.fTypeTable.getType(structName);
        end




        function populateType(aObj,structType)
            assert(isa(structType,'slci.mlutil.MLStructType'));
            [flag,busName,busType]=aObj.resolveToBus(structType);
            structName=structType.getName();
            assert(~aObj.fTypeTable.hasSymbol(structName));
            if flag
                namedType=slci.mlutil.NamedType(busName,busType);
                aObj.fTypeTable.addSymbol(structName,namedType);
            else
                aObj.fTypeTable.addSymbol(structName,structType);
            end
        end


        function[flag,busName,busType]=resolveToBus(aObj,structType)

            assert(isa(structType,'slci.mlutil.MLStructType'));



            fieldNames=structType.getFieldNames();
            for idx=1:numel(fieldNames)
                ftype=structType.getFieldType(fieldNames{idx});
                if isa(ftype,'slci.mlutil.MLStructType')&&...
                    ~aObj.fTypeTable.hasSymbol(ftype.getName())
                    aObj.populateType(ftype);
                end
            end


            busnames=aObj.fBusTable.getSymbols();
            for k=1:numel(busnames)
                busName=busnames{k};
                busType=aObj.fBusTable.getType(busName);
                if aObj.isEqualType(structType,busType)
                    flag=true;
                    return;
                end
            end
            flag=false;
            busName='';
            busType=[];
        end


        function flag=isEqualType(aObj,structType,busType)

            if isequal(structType,busType)
                flag=true;
            elseif isa(structType,'slci.mlutil.MLStructType')&&...
                isa(busType,'Simulink.Bus')
                fieldNames=structType.getFieldNames();
                numFields=numel(fieldNames);
                numElements=numel(busType.Elements);
                if numFields~=numElements
                    flag=false;
                    return;
                else

                    for k=1:numFields
                        busel=busType.Elements(k);


                        flag=strcmp(fieldNames{k},busel.Name);
                        if~flag
                            return;
                        end


                        buselType=busel.DataType;
                        fieldType=structType.getFieldType(fieldNames{k});
                        flag=aObj.compareFieldType(fieldType,buselType);
                        if~flag
                            return;
                        end


                        fieldDim=structType.getFieldDim(fieldNames{k});
                        if isempty(fieldDim)


                            return;
                        end
                        busDim=busel.Dimensions;
                        if ischar(busDim)


                            try
                                busDim=slResolve(busDim,bdroot);
                            catch
                            end
                        end
                        assert(~isempty(busDim));
                        flag=aObj.compareFieldDim(fieldDim,busDim);
                        if~flag
                            return;
                        end
                    end
                    flag=true;
                end
            elseif isequal(busType,'boolean')&&...
                isequal(structType,'logical')
                flag=true;
            elseif ischar(busType)
                if strncmp(busType,'Enum:',5)
                    enumTypeName=strtrim(busType(6:end));
                else
                    enumTypeName=busType;
                end
                flag=isequal(structType,enumTypeName);
            else
                flag=false;
            end
        end


        function flag=compareFieldType(aObj,fieldType,buselType)

            if isa(fieldType,'slci.mlutil.MLStructType')
                if ischar(buselType)
                    if strncmp(buselType,'Bus:',4)
                        buselTypeName=strtrim(buselType(5:end));
                    else
                        buselTypeName=buselType;
                    end

                    if aObj.fBusTable.hasSymbol(buselTypeName)
                        buselType=aObj.fBusTable.getType(buselTypeName);
                        assert(isa(buselType,'Simulink.Bus'));
                    else

                        flag=false;
                        return;
                    end

                    fieldType=aObj.getMappedType(fieldType);
                    if isa(fieldType,'slci.mlutil.NamedType')
                        fieldType=fieldType.getType();
                        assert(isa(fieldType,'Simulink.Bus'));
                    else
                        assert(isa(fieldType,'slci.mlutil.MLStructType'));
                    end


                    flag=isequal(buselType,fieldType);
                else
                    flag=false;
                end
            else
                flag=aObj.isEqualType(fieldType,buselType);
            end
        end


        function flag=compareFieldDim(~,structFieldDim,buselDim)
            numFieldDim=numel(structFieldDim);
            numBusDim=numel(buselDim);
            minDim=min(numFieldDim,numBusDim);
            flag=isequal(structFieldDim(1:minDim),buselDim(1:minDim));
            if~flag
                return;
            end


            assert(flag);
            if numFieldDim>numBusDim
                flag=all(structFieldDim(minDim+1:end)==1);
            elseif numBusDim>numFieldDim
                flag=all(buselDim(minDim+1:end)==1);
            end
        end
    end

    methods(Access=public)

        function ast=inferType(obj,ast,mtreeInference)

            assert(isa(ast,'slci.ast.SFAst'),...
            'Invalid input argument');

            fMtreeNode=ast.getMtree();
            assert(~isempty(fMtreeNode),...
            'Mtree node is unset for Matlab Ast');
            if mtreeInference.hasType(fMtreeNode)
                type=mtreeInference.getType(fMtreeNode);
                assert(~isempty(type));
                if ischar(type)
                    if strcmpi(type,'logical')
                        type='boolean';
                    end
                    ast.setDataType(type);
                elseif isa(type,'slci.mlutil.MLStructType')
                    name=obj.getNameOfMappedType(type);
                    ast.setDataType(name);
                elseif isa(type,'eml.MxInfo')&&~isempty(type.Class)

                    ast.setDataType(type.Class);
                end
            end

            children=ast.getChildren();
            for k=1:numel(children)
                child=children{k};
                obj.inferType(child,mtreeInference);
            end
        end
    end

end
