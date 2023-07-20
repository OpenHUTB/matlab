function valueStruct=getValues(this,spec,id)
    c={};
    f={};
    if spec

        mySpec=this.specification;
        set=mySpec.PropertySets.getByKey(id);
        values=set.properties.toArray;

        for vi=1:length(values)
            c{end+1}=values(vi).initialValue.getAsMxArray();
            f{end+1}=erase(values(vi).Name,' ');
        end
    else
        if nargin<3
            valueSet=this.propertyValues.toArray();
        else
            valueSet=this.propertyValues.getByKey(id);
        end
        values=valueSet.values.toArray;

        for vi=1:length(values)
            c{end+1}=values(vi).getAsMxArray();
            f{end+1}=erase(values(vi).Name,' ');
        end
    end

    valueStruct=cell2struct(c,f,2);

end

