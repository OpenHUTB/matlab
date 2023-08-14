function names=getMethodArgumentNames(obj,methodName,methodInfoArgListName,...
    expectedArgCount,varargName,defaultDefiningClass)





    methodInfo=matlab.system.internal.getMetaMethod(obj,methodName);
    specifiedNames=methodInfo.(methodInfoArgListName);

    isVarargin=~isempty(specifiedNames)&&strcmp(specifiedNames{end},varargName);
    if isVarargin...
        ||length(specifiedNames)<expectedArgCount...
        ||strcmp(methodInfo.DefiningClass.Name,defaultDefiningClass)
        names=strings(1,expectedArgCount);
    else
        names=string(specifiedNames(1:expectedArgCount));
    end
end
