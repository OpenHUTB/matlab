function[propOrInputTarget,propOrInputControl,propOrMethodTarget,propOrMethodControl]=...
    getSourceSetInfo(className,isInMSB)



    propOrInputTarget={};
    propOrInputControl={};
    propOrInputOrdinal=[];

    propOrMethodTarget={};
    propOrMethodControl={};

    mc=meta.class.fromName(className);
    mps=mc.PropertyList;
    for ii=1:length(mps)
        mp=mps(ii);
        if isa(mp,'matlab.system.CustomMetaProp')&&mp.PropertyPortPolicy
            setPropName=mp.Name;
            targetPropName=extractBefore(setPropName,strlength(setPropName)-2);

            sourceSet=mp.DefaultValue;
            policy=getPolicy(sourceSet,isInMSB);

            controlPropName=policy.ControlPropertyName;

            if isa(policy,'matlab.system.internal.PropertyOrInput')
                propOrInputTarget{end+1}=targetPropName;
                propOrInputControl{end+1}=controlPropName;
                propOrInputOrdinal(end+1)=policy.InputOrdinal;
            elseif isa(policy,'matlab.system.internal.PropertyOrMethod')
                propOrMethodTarget{end+1}=targetPropName;
                propOrMethodControl{end+1}=controlPropName;
            end
        end
    end


    [~,permIdx]=sort(propOrInputOrdinal);
    propOrInputTarget=propOrInputTarget(permIdx);
    propOrInputControl=propOrInputControl(permIdx);
end
