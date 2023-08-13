function setDependentFieldVisibility(block,fields)

    maskHandle=Simulink.Mask.get(block);

    independentFieldStatus=...
    get_param(block,fields.independent_field);

    for field=fields.dependent_fields
        parameter_handle=maskHandle.getParameter(field);
        parameter_handle.Visible=independentFieldStatus;
    end
end