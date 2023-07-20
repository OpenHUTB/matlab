







classdef SFAstDot<slci.ast.SFAst

    properties(Access=private)

        fField;
        fEnumConstant=[];
        fIsEnumConstant=false;
    end

    methods(Access=public)


        function aObj=SFAstDot(aAstObj,aParent)

            assert(isa(aAstObj,'mtree'),...
            DAStudio.message('Slci:slci:NotMtreeNode',...
            'SFAstDot'));
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);

            if(isa(aObj.getBase(),'slci.ast.SFAstIdentifier'))
                id=aObj.getBase().getIdentifier();



                parts=regexp(id,':','split');
                id=parts{end};
                if Simulink.data.isSupportedEnumClass(id)
                    [enums,enumStrs]=enumeration(id);
                    thisEnum=enums(strcmp(aObj.getField(),enumStrs));
                    if~isempty(thisEnum)
                        aObj.fIsEnumConstant=true;
                        aObj.fEnumConstant=double(thisEnum);
                    end
                end
            end
        end


        function field=getField(aObj)
            field=aObj.fField;
            assert(~isempty(field));
        end


        function base=getBase(aObj)
            children=aObj.getChildren();
            assert(numel(children)==1);
            base=children{1};
        end


        function out=getEnumConstant(aObj)
            out=aObj.fEnumConstant;
        end


        function out=IsEnumConst(aObj)
            out=aObj.fIsEnumConstant;
        end


        function ComputeDataType(aObj)
            parentChart=aObj.ParentChart();
            if isa(parentChart,'slci.matlab.EMChart')
                aObj.ComputeMLDataType();
            elseif isa(parentChart,'slci.stateflow.Chart')&&...
                strcmpi(slci.internal.getLanguageFromSFObject(parentChart),'MATLAB')
                aObj.ComputeSFMLDataType();

            end
        end


        function ComputeMLDataType(aObj)
            baseType=aObj.getBase().getDataType();
            if isempty(baseType)
                return;
            end

            if Simulink.data.isSupportedEnumClass(baseType)

                aObj.setDataType(baseType);
                return;
            end

            parentChart=aObj.ParentChart();
            assert(isa(parentChart,'slci.matlab.EMChart'));

            symbolTable=parentChart.getSymbolTable();
            assert(ischar(baseType));

            if symbolTable.hasSymbol(baseType)
                baseType=symbolTable.getType(baseType);
            else

                return;
            end

            if isa(baseType,'slci.mlutil.MLStructType')
                fieldType=baseType.getFieldType(aObj.getField());
                if isa(fieldType,'slci.mlutil.MLStructType')
                    structName=fieldType.getName();
                    assert(symbolTable.hasSymbol(structName));
                    mappedType=symbolTable.getType(...
                    structName);
                    assert(isa(mappedType,'slci.mlutil.NamedType')||...
                    isa(mappedType,'slci.mlutil.MLStructType'));
                    fieldType=mappedType.getName();
                end
                if ischar(fieldType)
                    aObj.setDataType(fieldType);
                end
            else
                assert(isa(baseType,'Simulink.Bus'));
                for i=1:numel(baseType.Elements)
                    if strcmp(baseType.Elements(i).Name,aObj.getField())
                        fieldType=aObj.parseDataType(...
                        baseType.Elements(i).DataType);
                        assert(ischar(fieldType));
                        aObj.setDataType(fieldType);
                        return;
                    end
                end
            end
        end


        function ComputeSFMLDataType(aObj)
            parentChart=aObj.ParentChart();
            assert(isa(parentChart,'slci.stateflow.Chart')&&...
            strcmpi(slci.internal.getLanguageFromSFObject(parentChart),'MATLAB'));
            baseType=aObj.getBase().getDataType();

            if Simulink.data.isSupportedEnumClass(baseType)

                aObj.setDataType(baseType);
                return;
            end

            aObj.fDataType='';
            try
                busObject=slResolve(baseType,parentChart.getSID);
                if isa(busObject,'Simulink.Bus')
                    aObj.fDataType=aObj.getBusElementDataType(busObject);
                end
            catch
            end
        end


        function elementType=getBusElementDataType(aObj,busObject)
            assert(isa(busObject,'Simulink.Bus'));
            field=aObj.getField();
            elementType='';
            for i=1:numel(busObject.Elements)
                if strcmp(busObject.Elements(i).Name,field)

                    elementType=busObject.Elements(i).DataType;


                    elementType=aObj.parseDataType(elementType);
                    break;
                end
            end
            assert(~isempty(elementType));
        end


        function ComputeDataDim(aObj)
            parentChart=aObj.ParentChart();
            if isa(parentChart,'slci.matlab.EMChart')
                aObj.ComputeMLDataDim();
            elseif isa(parentChart,'slci.stateflow.Chart')&&...
                strcmpi(slci.internal.getLanguageFromSFObject(parentChart),'MATLAB')
                aObj.ComputeSFMLDataDim();
            end
        end


        function ComputeMLDataDim(aObj)
            baseType=aObj.getBase().getDataType();

            if Simulink.data.isSupportedEnumClass(baseType)
                aObj.setDataDim([1,1]);
                return;
            end

            parentChart=aObj.ParentChart();
            assert(isa(parentChart,'slci.matlab.EMChart'));
            symbolTable=parentChart.getSymbolTable();

            if symbolTable.hasSymbol(baseType)
                baseType=symbolTable.getType(baseType);
            else

                return;
            end

            if isa(baseType,'slci.mlutil.MLStructType')
                fieldDim=baseType.getFieldDim(aObj.getField());

                if~isempty(fieldDim)
                    aObj.setDataDim(fieldDim);
                end
            else
                assert(isa(baseType,'Simulink.Bus'));
                for i=1:numel(baseType.Elements)
                    if strcmp(baseType.Elements(i).Name,aObj.getField())
                        fieldDim=baseType.Elements(i).Dimensions;
                        if numel(fieldDim)==1

                            fieldDim=[fieldDim,1];%#ok
                        end
                        assert(~isempty(fieldDim));
                        aObj.setDataDim(fieldDim);
                        return;
                    end
                end
            end
        end


        function ComputeSFMLDataDim(aObj)
            parentChart=aObj.ParentChart();
            assert(isa(parentChart,'slci.stateflow.Chart')&&...
            strcmpi(slci.internal.getLanguageFromSFObject(parentChart),'MATLAB'));
            baseType=aObj.getBase().getDataType();
            elementDim=1;
            try
                busObject=slResolve(baseType,parentChart.getSID);
                assert(isa(busObject,'Simulink.Bus'));
                field=aObj.getField();
                busHasField=false;
                for i=1:numel(busObject.Elements)
                    if strcmp(busObject.Elements(i).Name,field)
                        busHasField=true;
                        elementDim=busObject.Elements(i).Dimensions;
                        break;
                    end
                end
                assert(busHasField==true);
            catch
            end
            if numel(elementDim)==1
                aObj.fDataDim=[elementDim,1];
            else
                aObj.fDataDim=elementDim;
            end
        end

    end

    methods(Access=protected)


        function populateChildrenFromMtreeNode(aObj,inputObj)
            assert(isa(inputObj,'mtree'));
            [success,children]=slci.mlutil.getMtreeChildren(inputObj);
            assert(success&&numel(children)==2);

            base=children{1};
            [isAstNeeded,cObj]=slci.matlab.astTranslator.createAst(...
            base,aObj);
            assert(isAstNeeded&&isa(cObj,'slci.ast.SFAst'));
            aObj.fChildren{1}=cObj;

            assert(strcmp(children{2}.kind,'FIELD'));
            aObj.fField=children{2}.string;
        end



        function parsedType=parseDataType(~,dataType)

            if strncmp(dataType,'Bus:',4)
                parsedType=strtrim(dataType(5:end));
            elseif strncmp(dataType,'Enum:',5)
                parsedType=strtrim(dataType(6:end));
            else
                parsedType=dataType;
            end
        end


        function addMatlabFunctionConstraints(aObj)
            constraints={...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint,...
            slci.compatibility.MatlabFunctionMissingDimConstraint,...
            slci.compatibility.MatlabFunctionUnsupportedAstConstraint,...
            };
            aObj.setConstraints(constraints);

        end

    end

end

