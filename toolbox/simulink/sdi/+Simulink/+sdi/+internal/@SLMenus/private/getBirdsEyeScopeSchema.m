function besSchemaFcn=getBirdsEyeScopeSchema()







    isADTInstalled=dig.isProductInstalled('Automated Driving Toolbox');
    if isADTInstalled&&(slfeature('slBirdsEyeScopeApp')>0)
        besSchemaFcn=@(x)Simulink.scopes.BirdsEyeUtil.openSchema(x,true);
    else
        besSchemaFcn=@(x)hiddenActionSchema(x,'Simulink:OpenBirdsEyeScope');
    end
end