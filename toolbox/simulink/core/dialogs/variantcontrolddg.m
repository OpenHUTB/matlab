function dlgstruct=variantcontrolddg(h,name)








    dlgCreator=Simulink.variant.parameterddg.VariantControlDDGCreator(h,name);
    dlgstruct=dlgCreator.getDialogStruct();
end