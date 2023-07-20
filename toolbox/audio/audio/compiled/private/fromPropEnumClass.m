function norm=fromPropEnumClass(val,enums,nenums)


    index=find(val==enums,1);
    norm=fromPropInt(index-1,0,(nenums-1));

end