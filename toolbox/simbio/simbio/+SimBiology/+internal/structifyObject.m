function s=structifyObject(obj)




    propNames=properties(obj);
    values=get(obj,propNames);
    s=cell2struct(values,propNames,2);