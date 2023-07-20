function value=getPropVal(this,name)
    valueProp=this.values.getByKey(name);
    value=valueProp.getAsMxArray();
end

