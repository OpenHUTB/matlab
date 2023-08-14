function methodNames=scanMethods(obj,filterFcn)












    m=metaclass(obj);
    mmList=m.MethodList;


    includeMethods=arrayfun(filterFcn,mmList);
    methodNames={mmList(includeMethods).Name};
end
