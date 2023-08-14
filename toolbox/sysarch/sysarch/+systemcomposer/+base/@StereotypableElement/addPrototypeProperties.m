function addPrototypeProperties(this,protoName,propName)





    propObj=this.getPropertyImpl(protoName,propName);
    dynProps=this.(protoName);
    dynProps.addProperty(propObj);

end