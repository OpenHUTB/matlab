function type=get_widget_type_from_property(h,prop)





    type='edit';

    switch Simulink.data.getScalarObjectLevel(h)
    case 1
        isUDD=true;
    case 2
        isUDD=false;
    otherwise
        assert(false);
    end


    if(l_doesPropContainScalarObjectWithPublicProps(h,prop,isUDD))
        type='group';
        return;
    end

    if isUDD
        propType=prop.DataType;
    else
        try
            propType=h.getPropDataType(prop.Name);
        catch e %#ok

            propType=DAStudio.Protocol.getPropDataType(h,prop.Name);
        end
    end

    switch propType
    case{'bool','on/off'}
        type='checkbox';
    case{'enum'}
        type='combobox';
    case{'MATLAB array','mxArray','double','single','int','string',...
        'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}
        type='edit';
    otherwise

        if ddg_is_property_enabled(h,prop)
            if isUDD
                allowedValues=set(h,prop.Name);
            else
                allowedValues=getPropAllowedValues(h,prop.Name);
            end

            if(iscellstr(allowedValues)&&~isempty(allowedValues))
                type='combobox';
            end
        end
    end


    function isValidObject=l_doesPropContainScalarObjectWithPublicProps(h,prop,isUDD)
        isValidObject=false;

        if isUDD
            isGettable=strcmp(prop.AccessFlags.PublicGet,'on');
        else
            isGettable=strcmp(prop.GetAccess,'public');
        end

        if~isGettable
            return;
        end

        value=h.(prop.Name);

        if(Simulink.data.getScalarObjectLevel(value)>0)

            props=Simulink.data.getPropList(value,...
            'GetAccess','public',...
            'Hidden',false);
            isValidObject=~isempty(props);
        else

        end


