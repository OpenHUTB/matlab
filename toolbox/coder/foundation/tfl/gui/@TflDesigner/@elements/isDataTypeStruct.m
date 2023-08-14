function isStruct=isDataTypeStruct(~,dataType)



    isStruct=false;
    if length(dataType)>=6&&strcmp(dataType(1:6),'struct')
        isStruct=true;
    end