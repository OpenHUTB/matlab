function norm=fromPropEnum(val,enums,nenums)

    for index=1:nenums
        if(ischar(val)&&strcmp(deblank(val),deblank(enums(index,:))))||(isnumeric(val)&&val==enums(index,:))
            break;
        end
    end

    norm=fromPropInt(index-1,0,(nenums-1));

end
