function slEnumBuilder=createEnumBuilder(dictionaryFile)




    if nargin<1
        dictionaryFile='';
    end

    if isempty(dictionaryFile)
        slEnumBuilder=autosar.simulink.enum.EnumDynamicMCOSBuilder();
    else
        slEnumBuilder=autosar.simulink.enum.EnumDataDictionaryBuilder(dictionaryFile);
    end
