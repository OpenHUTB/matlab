function updatePrototypePropertyName(this,protoName,oldPropName,newPropName)





    propObj=this.getPropertyImpl(protoName,newPropName);
    dynProps=this.(protoName);
    dynProps.removeProperty(oldPropName);
    dynProps.addProperty(propObj);
end