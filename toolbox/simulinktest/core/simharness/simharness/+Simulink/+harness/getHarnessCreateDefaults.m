function defaults=getHarnessCreateDefaults


    if slfeature('SLT_HarnessCustomizationRegistration')==0

        DAStudio.error('Simulink:Harness:DefaultRegistrationsDisallowed');
    end







    cm=DAStudio.CustomizationManager;
    defaultsObj=cm.SimulinkTestCustomizer.createHarnessDefaultsObj;

    properties=fieldnames(defaultsObj);


    for idx=1:length(properties)
        propName=properties{idx};
        mp=findprop(defaultsObj,propName);
        if~mp.Hidden
            defaults.(propName)=defaultsObj.(propName);
        end
    end

end