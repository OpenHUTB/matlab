function value=getPropertyValue(obj,propSetUsageName,propName)


    if(isa(obj,'systemcomposer.base.StereotypableElement'))
        propOwner=obj.getPrototypable;
    else
        propOwner=obj;
    end
    if isa(propOwner,'systemcomposer.architecture.model.design.BaseComponent')
        propOwner=propOwner.getArchitecture;
    end

    value=propOwner.getPropVal([char(propSetUsageName),'.',char(propName)]).expression;
end