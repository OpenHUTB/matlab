classdef argumentPrototype





    properties
modelName
identifier
direction
datatype
dims
    end

    methods

        function obj=argumentPrototype(thisModelName,thisIdentifier,thisDirection,thisDatatype,thisDims)
            obj.modelName=thisModelName;
            obj.identifier=thisIdentifier;
            obj.direction=thisDirection;
            obj.datatype=thisDatatype;
            obj.dims=thisDims;
        end

        function obj=set.datatype(obj,dataTypeName)













            isSimulinkComponentAvailable=~isempty(which('legacycode.util.lct_pInitStructure'));
            if~isSimulinkComponentAvailable
                obj.datatype.DTName=dataTypeName;
                obj.datatype.IsBuiltin=true;
                obj.datatype.IsBus=false;
                obj.datatype.IsEnum=false;
                if strcmp(dataTypeName,'uint8')
                    obj.datatype.Id=uint32(4);
                    obj.datatype.NativeType='uint8_T';
                elseif strcmp(dataTypeName,'double')
                    obj.datatype.Id=uint32(1);
                    obj.datatype.NativeType='real_T';
                else
                    assert(false,'did not expect datatype %s',dataTypeName);
                end
                return
            end

            dataTypeTable=legacycode.util.lct_pInitStructure('DataTypes');


            if Simulink.data.isSupportedEnumClass(dataTypeName)

                [dataTypeTable,dataTypeId]=legacycode.util.lct_pAddDataType(dataTypeTable,'int32',obj.modelName);%#ok<MCSUP>
                dataType=dataTypeTable.DataType(dataTypeId);
                if legacycode.lct.util.feature('newImpl')





                    dataType=copy(dataType);
                    dataType.Id=dataTypeTable.NumSLBuiltInDataTypes+1;
                end
                thisDatatype=dataType;
                thisDatatype.IsEnum=1;
                thisDatatype.DTName=dataTypeName;
                thisDatatype.Name=dataTypeName;
                thisDatatype.HeaderFile=Simulink.data.getEnumTypeInfo(dataTypeName,'HeaderFile');
                thisDatatype.IsBuiltin=0;
            else

                if~ismember(dataTypeName,dataTypeTable.DataTypeNames)



                    if fixed.internal.type.isNameOfTraditionalFixedPointType(dataTypeName)
                        DAStudio.error('RTW:autosar:dataTypeIsIntrinsicFixPt',dataTypeName,dataTypeName)
                    end




                    isSlObjDefined=existsInGlobalScope(obj.modelName,dataTypeName);%#ok<MCSUP>
                    if isSlObjDefined==1
                        slObj=evalinGlobalScope(obj.modelName,dataTypeName);%#ok<MCSUP>
                    else
                        DAStudio.error('RTW:autosar:dataTypeObjectNotFound',dataTypeName);
                    end


                    if isa(slObj,'Simulink.NumericType')
                        if slObj.IsAlias==false
                            DAStudio.error('RTW:autosar:dataTypeObjectIsAliasFalse',dataTypeName);
                        end
                    end

                    if isa(slObj,'Simulink.NumericType')||isa(slObj,'Simulink.AliasType')
                        if~strcmp(slObj.HeaderFile,'Rte_Type.h')
                            DAStudio.error('RTW:autosar:dataTypeObjectHeaderFileNotRteType',dataTypeName);
                        end
                    end
                end

                [dataTypeTable,dataTypeId]=legacycode.util.lct_pAddDataType(dataTypeTable,dataTypeName,obj.modelName);%#ok<MCSUP>
                thisDatatype=dataTypeTable.DataType(dataTypeId);
                thisDatatype.IsEnum=0;
                thisDatatype.IsBuiltin=(dataTypeId<=dataTypeTable.NumSLBuiltInDataTypes);
            end

            obj.datatype=thisDatatype;
        end

        function obj=set.direction(obj,value)
            switch value
            case{'IN','OUT'}
                obj.direction=value;
            otherwise
                DAStudio.error('RTW:autosar:unknownArgumentDirection',value);
            end
        end

        function isEqual=eq(obj,obj2)
            if(strcmp(obj.identifier,obj2.identifier)&&...
                strcmp(obj.direction,obj2.direction)&&...
                prod(obj.dims)==prod(obj2.dims)&&...
                strcmp(obj.datatype.Name,obj2.datatype.Name))
                isEqual=true;
            else
                isEqual=false;
            end
        end

    end
end


