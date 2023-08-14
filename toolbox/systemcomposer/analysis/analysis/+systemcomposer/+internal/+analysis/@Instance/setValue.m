function setValue(this,name,value,index,id)

    if nargin<5
        valueSet=this.propertyValues.toArray();
    else
        valueSet=this.propertyValues.getByKey(id);
    end
    if nargin>3
        valueSet.setPropertyValue(name,value,index);
    else
        valueSet.setPropertyValue(name,value);
    end
end
