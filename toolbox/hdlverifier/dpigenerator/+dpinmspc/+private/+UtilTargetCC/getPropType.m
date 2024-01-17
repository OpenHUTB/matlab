function propType=getPropType(h,propName)

    proph = findprop(h,propName);

    switch(proph.DataType)
    case{'slbool','slint','string','ustring','MATLAB array','double'}
        propType = proph.DataType;
    otherwise
        ti = h.getPropTypeInfo(propName);
        if strcmp(ti.Type, 'enum')
            propType = 'enum';
        else
            propType = 'unknown';
        end
    end

end
