function removePrototype(this)








    propUsages=this.getPrototypable.PropertySets.toArray;
    for propUsage=propUsages
        customProperties=propUsage.properties.toArray;
        if strcmp(propUsage.getName,'Common')




            for props=customProperties
                mProp=this.findprop(props.getName);
                if~isempty(mProp)
                    delete(mProp)
                end
            end
        else
            mProp=this.findprop(propUsage.getName);
            if~isempty(mProp)
                delete(mProp);
            end
        end
    end
end