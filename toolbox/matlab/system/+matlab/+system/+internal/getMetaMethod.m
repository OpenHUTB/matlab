function metaMethod=getMetaMethod(obj,methodName)






    metaClass=metaclass(obj);

    allMethodNames={metaClass.MethodList.Name};

    methodIndex=strcmp(methodName,allMethodNames);

    metaMethod=metaClass.MethodList(methodIndex);
    assert(isscalar(metaMethod));
end
