function val=fromNormEnum(norm,enums,nenums)

    val=enums(fromNormInt(norm,0,nenums-1)+1,:);
    if ischar(val)
        val=deblank(val);
    end
end