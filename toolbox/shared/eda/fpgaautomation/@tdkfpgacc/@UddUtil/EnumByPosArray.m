function posArray=EnumByPosArray(this,typeName)



    h=findtype(typeName);

    if isempty(h)
        error(message('EDALink:EnumByStrStruct:UnknownType'));
    end

    str=h.Strings;
    val=h.Values;






    posArray=str;
end
