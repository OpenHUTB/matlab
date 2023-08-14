classdef JsonUtils





    properties
    end

    methods(Static,Access=public)


        updatePropertyData(info);


        outData=setPropertyValue(jsonData,stereotypeName,propertyName,propertyValue);

        value=getPropertyValue(jsonData,stereotypeName,propertyName);

        serializeJSON(info,jsonData);

        typeCastedValue=getTypeCastValue(origValue,targetDataType);
    end
end

