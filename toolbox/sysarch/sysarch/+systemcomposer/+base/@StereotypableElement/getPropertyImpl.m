function propObj=getPropertyImpl(this,protoName,propName)




    psUsage=findobj(this.getPrototypable.PropertySets.toArray,'p_Name',protoName);
    propObj=findobj(psUsage.properties.toArray,'p_Name',propName);

end