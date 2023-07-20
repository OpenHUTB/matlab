function addDesignTimeProperties(comp,codeName)






    DesignTimeProperties=...
    struct(...
    'CodeName',codeName,...
    'GroupId','',...
    'ComponentCode',{{''}});

    comp.addprop('DesignTimeProperties');
    comp.DesignTimeProperties=DesignTimeProperties;
end
