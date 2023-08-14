function strStruct=EnumByStrStruct(this,typeName)



    h=findtype(typeName);
    if isempty(h)
        error(message('HDLLink:UddUtil:UnknownType'));
    end

    str=h.Strings;
    val=h.Values;

    for idx=1:length(val)
        strStruct.(str{idx})=val(idx);
    end
end
