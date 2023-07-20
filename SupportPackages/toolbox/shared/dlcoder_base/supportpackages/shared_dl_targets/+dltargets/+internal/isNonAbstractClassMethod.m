function tf=isNonAbstractClassMethod(obj,methodName)





    m=metaclass(obj);
    functionList=m.MethodList;


    idx=strcmp({functionList.Name},methodName);
    if any(idx)
        definingClass=functionList(idx).DefiningClass.Name;
        definingClassMetaData=metaclass(definingClass);
        if~isequal(definingClass,class(obj))



            tf=~definingClassMetaData.Abstract;
        else


            tf=true;
        end
    else
        tf=false;
    end
end