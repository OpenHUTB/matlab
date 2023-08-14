function s=toStruct(h)






    props=properties(h);
    vals=get(h,props)';
    s=cell2struct(vals,props);

end