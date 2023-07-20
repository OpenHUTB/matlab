function setPropertyValue(this,name,value,index)
    parts=string(name).split('.');
    set=this.values.getByKey(strcat(parts(1),'.',parts(2)));
    valueProp=set.values.getByKey(parts(3));
    if nargin>3
        valueProp.setAsMxArray(value,index);
    else
        valueProp.setAsMxArray(value);
    end
end

