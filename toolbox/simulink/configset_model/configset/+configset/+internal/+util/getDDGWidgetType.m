function t=getDDGWidgetType(obj)




    p=obj;

    if isa(p,'configset.internal.data.WidgetStaticData')&&...
        ~isempty(obj.WidgetType)
        t=obj.WidgetType;
    else

        switch p.Type
        case{'string','numeric'}
            t='edit';
        case 'int'
            t='edit';
        case 'boolean'
            t='checkbox';
        case{'enum','enum_edit','minmax'}
            t='combobox';
        case 'mxArray'
            t='unknown';
        otherwise
            t=p.Type;
        end
    end
end