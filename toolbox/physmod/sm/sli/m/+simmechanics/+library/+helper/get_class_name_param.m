function classNameParam=get_class_name_param(className)
    persistent pa

    if isempty(pa)
        pa=simmechanics.library.helper.ParameterAccessor;
        pa.Namespace='mech2:messages:parameters:block';
    end
    classNameParam=pm.sli.MaskParameter;
    classNameParam.VarName=pa.param('className');
    classNameParam.ReadOnly='on';
    classNameParam.Value=className;

end