function tf=isClassMethod(obj,methodName)





    m=metaclass(obj);
    functionList=m.MethodList;
    idx=strcmp({functionList.Name},methodName);
    if any(idx)
        definingClass=functionList(idx).DefiningClass.Name;
        tf=isequal(definingClass,class(obj));
    else
        tf=false;
    end
end