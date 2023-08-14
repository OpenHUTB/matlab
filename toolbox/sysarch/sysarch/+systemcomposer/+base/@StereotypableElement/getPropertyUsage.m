function propUsage=getPropertyUsage(this,propSetName,propName)




    owner=this.getPrototypable;
    propSetUsage=owner.getPropertySet(propSetName);
    propUsage=[];

    if(~isempty(propSetUsage)&&propSetUsage.isvalid)
        propUsage=propSetUsage.getPropertyUsage(propName);
        protoParent=propSetUsage.p_Parent;
        while~isempty(protoParent)&&isempty(propUsage)


            propSetUsage=owner.getPropertySet(protoParent.getName);
            propUsage=propSetUsage.getPropertyUsage(propName);
            protoParent=propSetUsage.p_Parent;
        end
    end
end

