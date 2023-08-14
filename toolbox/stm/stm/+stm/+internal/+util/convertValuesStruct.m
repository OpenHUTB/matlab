

function convertedStruct=convertValuesStruct(valuesStruct)


    convertedStruct=struct;

    len=length(valuesStruct);
    for i=1:len

        convertedStruct.(valuesStruct(i).Variable)=valuesStruct(i).RuntimeValue;
    end
end
