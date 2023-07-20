function props=scanProperties(obj,filterFcn)












    m=metaclass(obj);
    mpList=m.PropertyList;


    includeProperty=arrayfun(filterFcn,mpList);
    props={mpList(includeProperty).Name};
end
