classdef DataTypeHelper<datacreation.internal.DataTypeHelper





    methods(Static)


        function outEnumDataType=parseDataTypeStringForEnumeration(dataTypeString)





            enumPattern='Enum[\s]*:';
            regexpResult=regexp(dataTypeString,enumPattern,'split');
            idxEnumStr=1;
            if length(regexpResult)>1
                idxEnumStr=2;
            end

            outEnumDataType=strtrim(regexpResult{idxEnumStr});
        end


        function outBool=isDataTypeNumericType(dataTypeString)


            FIWORDLEN_WARN_STATE_PREV=warning('OFF','fixed:numerictype:invalidMaxWordLength');

            c=onCleanup(@()warning(FIWORDLEN_WARN_STATE_PREV.state,'fixed:numerictype:invalidMaxWordLength'));


            parsedDataContainer=parseDataType(dataTypeString);

            outBool=isFixed(parsedDataContainer)&&~isBuiltInInteger(parsedDataContainer);

        end


        function[IS_VALID,ISA_META_STRUCT]=isSignalDataTypeStringValid(dataTypeString)
            IS_VALID=false;
            ISA_META_STRUCT.IS_STRING=false;
            ISA_META_STRUCT.IS_ENUM=false;
            ISA_META_STRUCT.IS_FIXDT=false;
            ISA_META_STRUCT.value=dataTypeString;




            if strcmp(dataTypeString,'string')
                IS_VALID=true;
                ISA_META_STRUCT.IS_STRING=true;
                return;
            end


            FIWORDLEN_WARN_STATE_PREV=warning('OFF','fixed:numerictype:invalidMaxWordLength');
            c=onCleanup(@()warning(FIWORDLEN_WARN_STATE_PREV.state,'fixed:numerictype:invalidMaxWordLength'));

            parsedDataContainer=parseDataType(dataTypeString);



            IS_UPPERCASE_BUILTIN=~any(strcmp(parsedDataContainer.OriginalString,slwebwidgets.BuiltInSlDataTypes.getDataTypeStrings))&&...
            any(strcmpi(parsedDataContainer.OriginalString,slwebwidgets.BuiltInSlDataTypes.getDataTypeStrings));

            if IS_UPPERCASE_BUILTIN
                return;
            end


            if parsedDataContainer.isBus
                return;
            end


            if parsedDataContainer.isUnknown||parsedDataContainer.isEnum









                outEnumDataType=starepository.DataTypeHelper.parseDataTypeStringForEnumeration(dataTypeString);

                parsedDataContainerEnumTest=parseDataType(outEnumDataType);

                if parsedDataContainerEnumTest.isEnum
                    IS_VALID=true;
                    ISA_META_STRUCT.IS_ENUM=true;
                    return;
                end
            else

                ISA_META_STRUCT.IS_FIXDT=starepository.DataTypeHelper.isDataTypeNumericType(dataTypeString);

                if ISA_META_STRUCT.IS_FIXDT


                    try





                        aFiValue=fi(1,eval(dataTypeString));
                    catch ME
                        ISA_META_STRUCT.comboErrorMessage=ME.message;
                        return;
                    end
                end


                IS_VALID=true;

            end
        end
    end
end

