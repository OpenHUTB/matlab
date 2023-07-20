function[templates,defaultModelTemplate]=loadTemplates()




    templates=sltemplate.internal.Registrar.init();
    defaultModelTemplate=Simulink.defaultModelTemplate();

end
