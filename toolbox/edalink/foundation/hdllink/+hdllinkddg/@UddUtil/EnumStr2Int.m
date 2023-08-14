function intRep=EnumStr2Int(this,typeName,strRep)
    h=findtype(typeName);
    intRep=h.Values(find(strcmpi(strRep,h.Strings)));
end
