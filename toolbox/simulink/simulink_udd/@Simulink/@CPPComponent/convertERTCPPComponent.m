function convertERTCPPComponent(hTarget)





    if~isa(hTarget,'Simulink.TargetCC')
        error('First argument must be a Simulink.TargetCC');
    end
    cpp=hTarget.getComponent('CPPClassGenComp');
    if isempty(cpp)||~isa(cpp,'Simulink.ERTCPPComponent')
        return;
    end

    ertcpp=hTarget.detachComponent('CPPClassGenComp');
    newCpp=Simulink.CPPComponent;
    newCpp.assignFrom(ertcpp,true);

    newCpp.IncludeModelTypesInModelClass='off';
    if strcmp(newCpp.GenerateExternalIOAccessMethods,'None')
        newCpp.ExternalIOMemberVisibility='public';
    else
        newCpp.ExternalIOMemberVisibility='protected';
    end

    hTarget.attachComponent(newCpp);
end
