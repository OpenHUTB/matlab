function dlgstruct=getSystemObjectParamSchema(blockHandle,propName)




    prmSchema=matlab.system.ui.SystemObjectParameterSchema(blockHandle,propName);
    dlgstruct=prmSchema.getSystemObjectParamStruct();

end

