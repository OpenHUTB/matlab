function value=getValue(this,name,id)

    if nargin<3
        valueSet=this.propertyValues.toArray();
    else
        valueSet=this.propertyValues.getByKey(id);
    end
    value=valueSet.getPropertyValue(name);
end

