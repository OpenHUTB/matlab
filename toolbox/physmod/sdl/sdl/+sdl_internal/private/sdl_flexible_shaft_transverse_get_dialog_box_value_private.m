function paramValue=sdl_flexible_shaft_transverse_get_dialog_box_value_private(blockHandle,paramString,requiredUnit)
    paramUnit=get_param(blockHandle,[paramString,'_unit']);
    paramValueString=get_param(blockHandle,paramString);

    paramValue=str2num(paramValueString);%#ok<ST2NM>

    if isempty(paramValue)
        paramValue=evalin('base',paramValueString);
    end

    paramValue=simscape.Value(paramValue,paramUnit);
    paramValue=value(paramValue,requiredUnit);

end