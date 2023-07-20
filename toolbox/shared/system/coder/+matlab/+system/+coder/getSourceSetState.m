function[policyClass,policyArgs]=getSourceSetState(className,propertyName,isInMSB)



    mc=meta.class.fromName(className);
    mp=findobj(mc.PropertyList,'-depth',0,'Name',propertyName);

    policy=getPolicy(mp.DefaultValue,isInMSB);

    policyClass=class(policy);

    argsFcn=str2func([policyClass,'.getConstructorArgs']);

    policyArgs=argsFcn(policy);
end
