function setPropVal(this,name,value)
    valueProp=this.values.getByKey(name);
    valueProp.setAsMxArray(value);
end

