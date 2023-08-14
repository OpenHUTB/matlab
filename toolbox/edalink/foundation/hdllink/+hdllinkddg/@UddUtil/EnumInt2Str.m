function strRep=EnumInt2Str(this,typeName,intRep)
    h=findtype(typeName);
    strRep=h.Strings{find(h.Values==intRep)};
end

