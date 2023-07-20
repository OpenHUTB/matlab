function posArray=EnumByPosArray(this,typeName)



    h=findtype(typeName);

    if isempty(h)
        error(message('HDLLink:UddUtil:UnknownType'));
    end

    str=h.Strings;
    val=h.Values;






    posArray=str;
end
