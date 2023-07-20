function val=fromNormEnumClass(norm,enums,nenums)

    val=enums(fromNormInt(norm,0,nenums-1)+1,:);
end