function propDT=getPropDataTypes(this,propName)




    propDT=getPropDataType(this,propName);
    if~strcmp(propDT,'enum')
        propDT='other';
    end