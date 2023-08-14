function ret=createEnumValuesFromClassDefinition(eName,eLabels,eVals,intVals,bFlatten)






    bIsPassFail=strcmp(eName,'%PFEnumType');
    if~bIsPassFail&&isempty(which(eName))
        locCreateEnum(eName,eLabels,eVals,class(intVals));
    end



    if bIsPassFail
        ret=intVals;
    else
        try
            ret=eval(sprintf('%s(intVals)',eName));
        catch me
            ret=locConvertNonNumericEnum(eName,intVals,me);
        end
    end




    if nargin<5||bFlatten
        ret=ret(:);
    end
end


function locCreateEnum(className,labels,vals,baseClass)
    interface=Simulink.sdi.internal.Framework.getFramework();
    createDynamicEnum(interface,className,labels,vals,baseClass);
end








function ret=locConvertNonNumericEnum(eName,intVals,origError)
    try
        ev=enumeration(eName);
        mc=metaclass(ev);



        if~isempty(mc.SuperclassList)
            throw(origError);
        end
        ret=eval(sprintf('%s.empty',eName));
        for idx=1:numel(intVals)
            ret(idx)=ev(intVals(idx));
        end
    catch me %#ok<NASGU>
        Simulink.sdi.internal.warning(origError.identifier,origError.message);
        ret=intVals;
    end
end
