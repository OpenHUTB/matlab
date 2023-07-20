function dataTypeId=addNamedType(this,dataTypeName,varargin)









    p=inputParser;
    p.addRequired('dataTypeName',...
    @(x)validateattributes(x,{'char','string'},{'scalartext'},'','dataTypeName',2));



    p.addOptional('namedTypeSource','',...
    @(x)validateattributes(x,{'char','string','double','Simulink.data.DataAccessor'},{},'','namedTypeSource',3));







    p.addParameter('StubSimBehavior',false,...
    @(x)validateattributes(x,{'logical'},{}));


    p.addParameter('WorkspaceName','',...
    @(x)validateattributes(x,{'char'},{}));

    p.parse(dataTypeName,varargin{:});


    dataTypeName=char(p.Results.dataTypeName);
    if isempty(p.Results.namedTypeSource)
        dataAccessor=Simulink.data.DataAccessor.createWithNoContext;
    elseif isa(p.Results.namedTypeSource,'Simulink.data.DataAccessor')
        dataAccessor=p.Results.namedTypeSource;
    elseif is_simulink_handle(p.Results.namedTypeSource)
        modelName=get_param(p.Results.namedTypeSource,'Name');
        dataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);
    else
        modelName=char(p.Results.namedTypeSource);
        dataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);
    end




    dataTypeId=iRecurseToAddDataType(this,dataTypeName,dataAccessor,p.Results.StubSimBehavior,p.Results.WorkspaceName);


    function dataTypeId=iRecurseToAddDataType(this,dataTypeName,dataAccessor,stubSimBehavior,workspaceName)


        if nargin<5
            workspaceName='';
        end






        dataTypeName=regexprep(dataTypeName,'^\s*\?*\s*|(?:Enum|Bus)\s*:\s*|\s+$','','ignorecase');


        dataTypeId=find(strcmp(dataTypeName,this.DataTypeNames),1);
        if~isempty(dataTypeId)



            oldDataType=this.DataType(dataTypeId);
            if oldDataType.IsOpaque
                error(message('Simulink:tools:LCTNamedDataTypeConflictsWithOpaque',dataTypeName));
            end

            if this.is64Bits(dataTypeId)
                this.UseInt64=true;
            end
            return
        end


        isBus=false;
        isStruct=false;
        isEnum=false;
        isLookupTable=false;
        isBreakpoint=false;


        [isSlObjDefined,slObj]=legacycode.lct.util.getNamedObject(dataTypeName,dataAccessor);
        if isSlObjDefined==true

            if isa(slObj,'Simulink.Bus')
                isBus=true;
            elseif isa(slObj,'Simulink.StructType')
                isStruct=true;
            elseif isa(slObj,'Simulink.data.dictionary.EnumTypeDefinition')||...
                isa(slObj,'meta.class')
                isEnum=true;
            else

            end
        else
            if stubSimBehavior







                if~isempty(workspaceName)
                    [isSlObjDefined,slObj]=legacycode.lct.util.getNamedObject(workspaceName,dataAccessor);
                    if isSlObjDefined
                        if isa(slObj,'Simulink.LookupTable')&&strcmp(slObj.StructTypeInfo.Name,dataTypeName)
                            isLookupTable=true;
                        elseif isa(slObj,'Simulink.Breakpoint')&&strcmp(slObj.StructTypeInfo.Name,dataTypeName)
                            isBreakpoint=true;
                        end
                    end
                end
            end

            if~isLookupTable&&~isBreakpoint
                error(message('Simulink:tools:LCTErrorSLObjectNotFound',dataTypeName));
            end
        end


        if(isBus==true)||(isStruct==true)

            if isempty(strtrim(slObj.HeaderFile))&&~stubSimBehavior
                error(message('Simulink:tools:LCTErrorSLObjectHeaderFile',dataTypeName,class(slObj)));
            end


            dtElement=legacycode.lct.types.Type();
            dtElement.DTName=dataTypeName;
            dtElement.Name=dataTypeName;
            dtElement.IsBus=isBus;
            dtElement.IsStruct=isStruct;
            dtElement.Object=slObj;
            dtElement.HeaderFile=strtrim(slObj.HeaderFile);

            if numel(slObj.Elements)<1
                error(message('Simulink:tools:LCTErrorBusElementEmpty',dataTypeName));
            end

            for ii=1:length(slObj.Elements)
                thisElement=slObj.Elements(ii);
                if~isempty(regexp(thisElement.DataType,'^(fixdt\s*\()','once'))

                    dataTypeId=addRawFixedPointType(this,thisElement.DataType,eval(thisElement.DataType));
                else
                    dataTypeId=iRecurseToAddDataType(this,thisElement.DataType,dataAccessor,stubSimBehavior);
                end
                dtBusElement=legacycode.lct.types.BusElement();
                dtBusElement.Name=thisElement.Name;
                dtBusElement.DataTypeId=dataTypeId;
                dtBusElement.IsComplex=strcmp(thisElement.Complexity,'complex');

                if isBus
                    dtBusElement.DimensionsMode=thisElement.DimensionsMode;
                end
                if dtBusElement.IsComplex==1


                    if(dataTypeId>=this.NumSLBuiltInDataTypes)
                        dataType=this.Items(dataTypeId);

                        if dataType.isAliasType()||...
                            (dataType.Id==this.NumSLBuiltInDataTypes)||...
                            (dataType.IdAliasedTo==this.NumSLBuiltInDataTypes)||...
                            (dataType.IdAliasedThruTo==this.NumSLBuiltInDataTypes)||...
                            dataType.isAggregateType()

                            error(message('Simulink:tools:LCTErrorBusElementBoolComplex',...
                            thisElement.Name,dataTypeName));
                        end
                    end
                end
                dtBusElement.Dimensions=thisElement.Dimensions;
                dtElement.Elements(ii)=dtBusElement;
            end


            dtElement.Id=this.Numel+1;
            dataTypeId=this.addType(dtElement,true);

        elseif isLookupTable||isBreakpoint




            dtElement=legacycode.lct.types.Type();
            dtElement.DTName=dataTypeName;
            dtElement.Name=dataTypeName;
            dtElement.IsLookupTable=isLookupTable;
            dtElement.IsBreakpoint=isBreakpoint;
            dtElement.Object=slObj;
            dtElement.HeaderFile='';
            dtElement.Id=this.Numel+1;
            dataTypeId=this.addType(dtElement,true);

        elseif isEnum

            headerFile=strtrim(Simulink.data.getEnumTypeInfo(dataTypeName,'HeaderFile'));
            if isempty(headerFile)&&~stubSimBehavior
                error(message('Simulink:tools:LCTErrorEnumTypeMustSpecifyHeaderFile',dataTypeName));
            end


            addClassName=Simulink.data.getEnumTypeInfo(dataTypeName,'AddClassNameToEnumNames');
            if addClassName
                error(message('Simulink:tools:LCTErrorAddClassNameToEnumNamesNotSupported',dataTypeName));
            end



            [enumVals,enumNames]=enumeration(dataTypeName);





            enumDefaultIdx=Simulink.IntEnumType.getIndexOfDefaultValue(dataTypeName);




            enumType=Simulink.data.getEnumTypeInfo(dataTypeName,'StorageType');
            nativeType=[enumType,'_T'];


            dtElement=legacycode.lct.types.Type(this.Numel+1);
            dtElement.DTName=dataTypeName;
            dtElement.Name=dataTypeName;
            dtElement.IsEnum=isEnum;
            dtElement.Object=slObj;
            dtElement.HeaderFile=headerFile;
            dtElement.NativeType=nativeType;
            dtElement.EnumInfo=legacycode.lct.types.EnumInfo();
            dtElement.EnumInfo.Strings=enumNames;
            dtElement.EnumInfo.Values=double(enumVals);
            dtElement.EnumInfo.DefaultValueIdx=enumDefaultIdx;


            clear enumVals;


            dataTypeId=this.addType(dtElement,true);

        elseif isa(slObj,'Simulink.NumericType')

            if strcmp(slObj.DataTypeMode,'Fixed-point: unspecified scaling')
                error(message('Simulink:tools:LCTErrorUnspecifiedScaling',dataTypeName));
            end

            switch slObj.DataTypeMode
            case{'Boolean','Single','Double'}

                dataTypeId=iRecurseToAddDataType(this,lower(slObj.DataTypeMode),dataAccessor,stubSimBehavior);

            case{'Fixed-point: binary point scaling','Fixed-point: slope and bias scaling'}
                dataTypeId=addRawFixedPointType(this,dataTypeName,slObj);

            otherwise
                error(mesage('Simulink:tools:LCTErrorSLObjectNotFound',dataTypeName));
            end


            originalDataType=this.Items(dataTypeId);



            dtElement=copy(originalDataType);
            dtElement.DTName=dataTypeName;
            dtElement.Name=dataTypeName;
            dtElement.IdAliasedThruTo=dataTypeId;
            dtElement.Object=slObj;
            dtElement.HeaderFile=strtrim(slObj.HeaderFile);




            if slObj.IsAlias==1

                if isempty(strtrim(slObj.HeaderFile))&&~stubSimBehavior
                    error(message('Simulink:tools:LCTErrorSLObjectHeaderFile',...
                    dataTypeName,'Simulink.NumericType'));
                end
                dtElement.IdAliasedTo=dataTypeId;
            else



                dtElement.HeaderFile='';


                dtElement.IdAliasedTo=0;
            end


            dtElement.Id=this.Numel+1;
            dataTypeId=this.addType(dtElement);

        elseif isa(slObj,'Simulink.AliasType')

            if isempty(strtrim(slObj.HeaderFile))&&~stubSimBehavior
                error(message('Simulink:tools:LCTErrorSLObjectHeaderFile',...
                dataTypeName,'Simulink.AliasType'));
            end

            if~isempty(regexp(slObj.BaseType,'^(fixdt\s*\()','once'))

                dataTypeId=addRawFixedPointType(this,dataTypeName,eval(slObj.BaseType));
            else

                dataTypeId=iRecurseToAddDataType(this,slObj.BaseType,dataAccessor,stubSimBehavior);
            end


            originalDataType=this.Items(dataTypeId);



            dtElement=copy(originalDataType);
            dtElement.DTName=dataTypeName;
            dtElement.Name=dataTypeName;
            dtElement.Object=slObj;
            dtElement.HeaderFile=strtrim(slObj.HeaderFile);



            if(this.Items(dataTypeId).IdAliasedTo==0)
                dtElement.IdAliasedTo=this.Items(dataTypeId).IdAliasedThruTo;
            else
                dtElement.IdAliasedTo=dataTypeId;
            end


            dtElement.Id=this.Numel+1;
            dataTypeId=this.addType(dtElement);

        else
            error(message('Simulink:tools:LCTErrorSLObjectNotFound',dataTypeName));
        end



        function dataTypeId=addRawFixedPointType(this,dataTypeName,slObj)


            if slObj.Signed==1
                dtSign='';
            else
                dtSign='u';
            end


            if(slObj.WordLength<0)||(slObj.WordLength>64)
                error(message('Simulink:tools:LCTErrorDataTypeWordlengthTooBig',dataTypeName));
            end


            trueWordlength=2^nextpow2(slObj.WordLength);


            trueWordlength=max(trueWordlength,8);


            if(trueWordlength~=slObj.WordLength)
                warning(message('Simulink:tools:LCTWarningDataTypeWordlengthModified',...
                dataTypeName,slObj.WordLength,trueWordlength));
            end

            intDtName=sprintf('%sint%d',dtSign,trueWordlength);


            dataTypeId=find(strcmp(intDtName,this.DataTypeNames),1);
            if this.is64Bits(dataTypeId)
                this.UseInt64=true;
            end


            if(slObj.Slope~=1)||(slObj.Bias~=0)
                if slObj.Signed==1
                    dtSign='s';
                end
                radix=sprintf('%sfix%d',dtSign,slObj.WordLength);
                if slObj.SlopeAdjustmentFactor==1
                    slope=sprintf('_E%d',slObj.FractionLength);
                else
                    slope=strrep(sprintf('_S%g',slObj.Slope),'.','p');
                end
                slope=strrep(slope,'-','n');
                slope=strrep(slope,'+','');

                bias='';
                if slObj.Bias~=0
                    bias=sprintf('_B%g',slObj.Bias);
                    bias=strrep(bias,'-','n');
                    bias=strrep(bias,'+','');
                end


                intDataType=this.Items(dataTypeId);
                fixptStruct=copy(intDataType);
                fixptStruct.DTName=[radix,slope,bias];
                fixptStruct.DataTypeName=fixptStruct.DTName;
                fixptStruct.IsSigned=slObj.Signed==1;
                fixptStruct.WordLength=trueWordlength;
                fixptStruct.IsFixedPoint=1;
                fixptStruct.FixedExp=slObj.FractionLength;
                fixptStruct.FracSlope=slObj.SlopeAdjustmentFactor;
                fixptStruct.Bias=slObj.Bias;


                fixptStruct.Id=this.Numel+1;
                dataTypeId=this.addType(fixptStruct);
                fixptStruct.IdAliasedThruTo=dataTypeId;
            end
