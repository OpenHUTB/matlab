function removePrototypeProperties(this,protoName,propName)





    dynProps=this.(protoName);
    dynProps.removeProperty(propName);

end