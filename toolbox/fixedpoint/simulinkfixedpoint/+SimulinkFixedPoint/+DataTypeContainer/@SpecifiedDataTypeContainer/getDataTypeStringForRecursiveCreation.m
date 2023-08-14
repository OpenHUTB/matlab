function dataTypeString=getDataTypeStringForRecursiveCreation(this)












    dataTypeString='';
    if isAlias(this)
        dataTypeString=this.resolvedObject.BaseType;
    end
end


