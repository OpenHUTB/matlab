function dlgstruct=variantvariableddg(h,name)








    dlgCreator=Simulink.variant.parameterddg.VariantVariableDDGCreator(h,name);
    dlgstruct=dlgCreator.getDialogStruct();
end