function[DataTypes,dataTypeId]=lct_pAddDataType(DataTypes,dataTypeName,varargin)









    narginchk(1,3);




    if nargin<3
        modelName='';
    else
        modelName=varargin{1};
    end

    if legacycode.lct.util.feature('newImpl')
        validateattributes(DataTypes,...
        {'legacycode.lct.types.TypeTable'},{'nonempty','scalar'},...
        'legacycode.util.lct_pAddDataType','dataTypeTable',1);
        dataTypeId=DataTypes.addNamedType(dataTypeName,varargin{:});
        return
    end

    [DataTypes,dataTypeId]=iRecurseToAddDataType(DataTypes,dataTypeName,modelName);



    function[DataTypes,dataTypeId]=iRecurseToAddDataType(DataTypes,dataTypeName,modelName)




        dataTypeName=regexprep(dataTypeName,'^\s+|(?:Enum|Bus)\s*:\s+|\s+$','','ignorecase');


        [bool,dataTypeId]=ismember(dataTypeName,DataTypes.DataTypeNames);


        if bool==1
            return
        end


        isBus=false;
        isStruct=false;
        isEnum=false;

        if isempty(modelName)
            isSlObjDefined=evalin('base',sprintf('exist(''%s'',''var'')',dataTypeName));
        else
            isSlObjDefined=existsInGlobalScope(modelName,dataTypeName);
        end

        if isSlObjDefined==1

            if isempty(modelName)
                slObj=evalin('base',dataTypeName);
            else
                slObj=evalinGlobalScope(modelName,dataTypeName);
            end


            if isa(slObj,'Simulink.Bus')
                isBus=true;
            elseif isa(slObj,'Simulink.StructType')
                isStruct=true;
            else

            end
        else




            slObj=Simulink.getMetaClassIfValidEnumDataType(dataTypeName);
            if isempty(slObj)
                DAStudio.error('Simulink:tools:LCTErrorSLObjectNotFound',dataTypeName);
            end
            isEnum=true;
        end


        if(isBus==true)||(isStruct==true)

            if isempty(strtrim(slObj.HeaderFile))
                DAStudio.error('Simulink:tools:LCTErrorSLObjectHeaderFile',dataTypeName,class(slObj));
            end


            dataTypeStruct=legacycode.util.lct_pInitStructure('DataTypeElement');
            dataTypeStruct.DTName=dataTypeName;
            dataTypeStruct.Name=dataTypeName;
            dataTypeStruct.IsBus=isBus;
            dataTypeStruct.IsStruct=isStruct;
            dataTypeStruct.NumElements=length(slObj.Elements);
            dataTypeStruct.HasObject=1;
            dataTypeStruct.Object=slObj;
            dataTypeStruct.HeaderFile=strtrim(slObj.HeaderFile);

            if numel(slObj.Elements)<1
                DAStudio.error('Simulink:tools:LCTErrorBusElementEmpty',dataTypeName);
            end

            for ii=1:length(slObj.Elements)
                thisElement=slObj.Elements(ii);
                [DataTypes,dataTypeId]=iRecurseToAddDataType(DataTypes,thisElement.DataType,modelName);
                dataTypeStructElement=legacycode.util.lct_pInitStructure('BusElement');
                dataTypeStructElement.Name=thisElement.Name;
                dataTypeStructElement.DataTypeId=dataTypeId;
                dataTypeStructElement.IsComplex=strcmp(thisElement.Complexity,'complex');
                if dataTypeStructElement.IsComplex==1


                    if(dataTypeId>=DataTypes.NumSLBuiltInDataTypes)
                        thisDataType=DataTypes.DataType(dataTypeId);

                        if((thisDataType.Id~=thisDataType.IdAliasedThruTo)&&(thisDataType.IdAliasedTo~=-1))||...
                            (thisDataType.Id==DataTypes.NumSLBuiltInDataTypes)||...
                            (thisDataType.IdAliasedTo==DataTypes.NumSLBuiltInDataTypes)||...
                            (thisDataType.IdAliasedThruTo==DataTypes.NumSLBuiltInDataTypes)||...
                            (thisDataType.IsBus==1||thisDataType.IsStruct==1)

                            DAStudio.error('Simulink:tools:LCTErrorBusElementBoolComplex',...
                            thisElement.Name,dataTypeName);
                        end
                    end
                end
                dataTypeStructElement.Dimensions=thisElement.Dimensions;
                dataTypeStructElement.NumDimensions=length(thisElement.Dimensions);
                dataTypeStructElement.Width=prod(thisElement.Dimensions);
                dataTypeStruct.Elements(ii)=dataTypeStructElement;

            end


            dataTypeId=DataTypes.NumDataTypes+1;


            dataTypeStruct.Id=dataTypeId;
            dataTypeStruct.IdAliasedThruTo=dataTypeId;
            dataTypeStruct.StorageId=dataTypeId;

            DataTypes=iAppendNewDataType(DataTypes,dataTypeStruct);

        elseif isEnum

            headerFile=strtrim(Simulink.data.getEnumTypeInfo(dataTypeName,'HeaderFile'));
            if isempty(headerFile)
                DAStudio.error('Simulink:tools:LCTErrorEnumTypeMustSpecifyHeaderFile',dataTypeName);
            end


            addClassName=Simulink.data.getEnumTypeInfo(dataTypeName,'AddClassNameToEnumNames');
            if addClassName
                DAStudio.error('Simulink:tools:LCTErrorAddClassNameToEnumNamesNotSupported',dataTypeName);
            end



            [enumVals,enumNames]=enumeration(dataTypeName);





            enumDefaultIdx=Simulink.IntEnumType.getIndexOfDefaultValue(dataTypeName);




            enumType=Simulink.data.getEnumTypeInfo(dataTypeName,'StorageType');
            nativeType=[enumType,'_T'];


            dataTypeStruct=legacycode.util.lct_pInitStructure('DataTypeElement');
            dataTypeStruct.DTName=dataTypeName;
            dataTypeStruct.Name=dataTypeName;
            dataTypeStruct.IsEnum=isEnum;
            dataTypeStruct.HasObject=1;
            dataTypeStruct.Object=slObj;
            dataTypeStruct.HeaderFile=headerFile;
            dataTypeStruct.NativeType=nativeType;
            dataTypeStruct.EnumInfo(1).Strings=enumNames;
            dataTypeStruct.EnumInfo(1).Values=double(enumVals);
            dataTypeStruct.EnumInfo(1).DefaultValueIdx=enumDefaultIdx;


            dataTypeId=DataTypes.NumDataTypes+1;


            dataTypeStruct.Id=dataTypeId;
            dataTypeStruct.IdAliasedThruTo=dataTypeId;
            dataTypeStruct.StorageId=dataTypeId;

            DataTypes=iAppendNewDataType(DataTypes,dataTypeStruct);

        elseif isa(slObj,'Simulink.NumericType')

            if strcmp(slObj.DataTypeMode,'Fixed-point: unspecified scaling')
                DAStudio.error('Simulink:tools:LCTErrorUnspecifiedScaling',dataTypeName);
            end

            switch slObj.DataTypeMode
            case{'Boolean','Single','Double'}

                [DataTypes,dataTypeId]=iRecurseToAddDataType(DataTypes,lower(slObj.DataTypeMode),modelName);

            case{'Fixed-point: binary point scaling','Fixed-point: slope and bias scaling'}

                if slObj.Signed==1
                    dtSign='';
                else
                    dtSign='u';
                end


                if(slObj.WordLength<0)||(slObj.WordLength>32)
                    DAStudio.error('Simulink:tools:LCTErrorDataTypeWordlengthTooBig',dataTypeName);
                end


                trueWordlength=2^nextpow2(slObj.WordLength);


                trueWordlength=max(trueWordlength,8);


                if(trueWordlength~=slObj.WordLength)
                    MSLDiagnostic('Simulink:tools:LCTWarningDataTypeWordlengthModified',...
                    dataTypeName,slObj.WordLength,trueWordlength).reportAsWarning;
                end

                intDtName=sprintf('%sint%d',dtSign,trueWordlength);


                [bool,dataTypeId]=ismember(intDtName,DataTypes.DataTypeNames);%#ok


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


                    intDataType=DataTypes.DataType(dataTypeId);
                    fixptStruct=intDataType;
                    fixptStruct.DTName=[radix,slope,bias];
                    fixptStruct.DataTypeName=fixptStruct.DTName;
                    fixptStruct.IsFixedPoint=1;
                    fixptStruct.FixedExp=slObj.FractionLength;
                    fixptStruct.FracSlope=slObj.SlopeAdjustmentFactor;
                    fixptStruct.Bias=slObj.Bias;


                    dataTypeId=DataTypes.NumDataTypes+1;
                    fixptStruct.Id=dataTypeId;
                    fixptStruct.IdAliasedThruTo=dataTypeId;
                    DataTypes=iAppendNewDataType(DataTypes,fixptStruct);

                end

            otherwise
                DAStudio.error('Simulink:tools:LCTErrorSLObjectNotFound',dataTypeName);
            end


            originalDataType=DataTypes.DataType(dataTypeId);



            dataTypeStruct=originalDataType;
            dataTypeStruct.DTName=dataTypeName;
            dataTypeStruct.Name=dataTypeName;
            dataTypeStruct.IdAliasedThruTo=dataTypeId;
            dataTypeStruct.HasObject=1;
            dataTypeStruct.Object=slObj;
            dataTypeStruct.HeaderFile=strtrim(slObj.HeaderFile);




            if slObj.IsAlias==1

                if isempty(strtrim(slObj.HeaderFile))
                    DAStudio.error('Simulink:tools:LCTErrorSLObjectHeaderFile',...
                    dataTypeName,'Simulink.NumericType');
                end
                dataTypeStruct.IdAliasedTo=dataTypeId;
            else



                dataTypeStruct.HeaderFile='';


                dataTypeStruct.IdAliasedTo=-1;
            end


            dataTypeId=DataTypes.NumDataTypes+1;
            dataTypeStruct.Id=dataTypeId;
            DataTypes=iAppendNewDataType(DataTypes,dataTypeStruct);

        elseif isa(slObj,'Simulink.AliasType')

            if isempty(strtrim(slObj.HeaderFile))
                DAStudio.error('Simulink:tools:LCTErrorSLObjectHeaderFile',...
                dataTypeName,'Simulink.AliasType');
            end


            [DataTypes,dataTypeId]=iRecurseToAddDataType(DataTypes,slObj.BaseType,modelName);


            originalDataType=DataTypes.DataType(dataTypeId);



            dataTypeStruct=originalDataType;
            dataTypeStruct.DTName=dataTypeName;
            dataTypeStruct.Name=dataTypeName;
            dataTypeStruct.HasObject=1;
            dataTypeStruct.Object=slObj;
            dataTypeStruct.HeaderFile=strtrim(slObj.HeaderFile);



            if(DataTypes.DataType(dataTypeId).IdAliasedTo==-1)
                dataTypeStruct.IdAliasedTo=DataTypes.DataType(dataTypeId).IdAliasedThruTo;
            else
                dataTypeStruct.IdAliasedTo=dataTypeId;
            end


            dataTypeId=DataTypes.NumDataTypes+1;
            dataTypeStruct.Id=dataTypeId;
            DataTypes=iAppendNewDataType(DataTypes,dataTypeStruct);

        else
            DAStudio.error('Simulink:tools:LCTErrorSLObjectNotFound',dataTypeName);
        end



        function DataTypes=iAppendNewDataType(DataTypes,dataTypeStruct)

            if dataTypeStruct.Id<=DataTypes.NumDataTypes
                return
            end

            dataTypeStruct.IsBuiltin=dataTypeStruct.Id<=DataTypes.NumSLBuiltInDataTypes;
            DataTypes.NumDataTypes=dataTypeStruct.Id;
            DataTypes.DataTypeNames{dataTypeStruct.Id}=dataTypeStruct.DTName;
            DataTypes.DataTypeIDs(dataTypeStruct.Id)=dataTypeStruct.Id;
            DataTypes.DataType(dataTypeStruct.Id)=dataTypeStruct;


