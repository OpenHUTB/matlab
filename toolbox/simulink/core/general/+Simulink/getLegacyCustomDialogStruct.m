function dlgStruct=getLegacyCustomDialogStruct(source)






    blockObj=source.getBlock;
    if blockisa(blockObj,'Goto')
        dlgStruct=getSlimGotoDDG(source,blockObj);
    elseif blockisa(blockObj,'From')
        dlgStruct=getSlimFromDDG(source,blockObj);

    elseif blockisa(blockObj,'ModelReference')
        dlgStruct=getSlimModelReferenceDDG(source,blockObj);
    elseif blockisa(blockObj,'DocBlock')
        dlgStruct=getSlimDocDDG(source,blockObj);
    elseif blockisa(blockObj,'StateWriter')||blockisa(blockObj,'StateReader')
        dlgStruct=getSlimStateAccessorDDG(source,blockObj);
    elseif blockisa(blockObj,'ParameterWriter')||blockisa(blockObj,'ParameterReader')
        dlgStruct=getSlimParamAccessorDDG(source,blockObj);
    elseif blockisa(blockObj,'CoSimServiceBlock')
        dlgStruct=getSlimCoSimServiceBlockDDG(source,blockObj);
    else
        dlgStruct=[];
    end
end
