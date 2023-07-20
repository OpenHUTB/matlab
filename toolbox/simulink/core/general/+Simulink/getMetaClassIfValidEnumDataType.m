function retVal=getMetaClassIfValidEnumDataType(name)





    retVal=[];


    metaClass=meta.class.fromName(name);
    if(Simulink.data.isSupportedEnumClass(metaClass))
        retVal=metaClass;
    end
