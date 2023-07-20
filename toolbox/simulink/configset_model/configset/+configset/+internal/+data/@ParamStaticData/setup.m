function setup(obj)

    if~isempty(obj.Constraint)
        obj.ConstraintType=obj.Constraint.getTypeName();
        obj.v_AvailableValues=obj.Constraint.getAvailableValues();
    end

    if~isempty(obj.ConstraintType)
        obj.Type=obj.ConstraintType;
    elseif~isempty(obj.ValueType)
        obj.Type=obj.ValueType;
    end

    if~isempty(obj.Dependency)
        obj.Parent=obj.Dependency.Parent;
    end

    if~isa(obj,'configset.internal.data.WidgetStaticData')
        obj.DefaultValue=configset.internal.helper.valueTypeConvert(obj.DefaultValue,obj.ValueType);
    end

    obj.FullName=[obj.Component,':',obj.Name];

    obj.Custom=obj.isCustom;
