function dataTypeId=addOpaqueType(this,dataTypeName)






    dataTypeName=regexprep(dataTypeName,'^\s+|(?:Enum|Bus)\s*:\s+|\s+$','','ignorecase');


    dataTypeId=find(strcmp(dataTypeName,this.DataTypeNames),1);
    if~isempty(dataTypeId)



        oldDataType=this.DataType(dataTypeId);
        if~oldDataType.IsOpaque
            error(message('Simulink:tools:LCTOpaqueDataTypeConflictsWithNamed',dataTypeName));
        end
        return
    end

    dtElement=legacycode.lct.types.Type();
    dtElement.DTName=dataTypeName;
    dtElement.Name=dataTypeName;
    dtElement.DataTypeName=dataTypeName;
    dtElement.NativeType=dataTypeName;
    dtElement.IsBus=false;
    dtElement.IsStruct=false;
    dtElement.Object=[];
    dtElement.HeaderFile='';
    dtElement.IsOpaque=true;
    dtElement.Id=this.Numel+1;
    dataTypeId=this.addType(dtElement,true);
