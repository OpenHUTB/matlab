

function setupWidget(obj,param)
    obj.Parameter=param;


    if isempty(obj.v_Tag)&&isempty(obj.f_Tag)
        obj.v_Tag=obj.Parameter.v_Tag;
        obj.f_Tag=obj.Parameter.f_Tag;
    end

    if isempty(obj.UI)
        obj.UI=obj.Parameter.UI;
    end

    if isempty(obj.Type)
        obj.Type=obj.Parameter.Type;
    end


    obj.Hidden=obj.Hidden||obj.Parameter.Hidden;


    if isempty(obj.WidgetType)
        switch obj.Type
        case 'boolean'
            obj.WidgetType='checkbox';
        case 'enum'
            obj.WidgetType='combobox';
        case{'string','int','double','MxArray','struct'}
            obj.WidgetType='edit';
        end
    end


    if ismember(obj.WidgetType,{'combobox','radiobutton'})&&...
        isempty(obj.v_AvailableValues)&&isempty(obj.f_AvailableValues)
        obj.v_AvailableValues=obj.Parameter.v_AvailableValues;
        obj.f_AvailableValues=obj.Parameter.f_AvailableValues;
    end

    obj.FullName=[obj.Component,':',obj.Name];

    obj.Custom=obj.isCustom;

    obj.Feature=obj.Parameter.Feature;



    obj.DependencyOverride=obj.Parameter.DependencyOverride;
end

