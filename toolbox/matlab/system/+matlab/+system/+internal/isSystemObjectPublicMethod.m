function flag=isSystemObjectPublicMethod(obj,methodName)







    mc=meta.class.fromName(class(obj));

    publicMethods=findobj(mc.MethodList,'Access','public');
    publicMethodNames=cell(numel(publicMethods),1);
    [publicMethodNames{:}]=publicMethods.Name;
    flag=any(strcmp(publicMethodNames,methodName));
