function setEnabledParameterVisibility(block,useParamName,paramName)






    mask=Simulink.Mask.get(block);
    useParam=mask.getParameter(useParamName);
    param=mask.getParameter(paramName);

    param.Visible=useParam.Value;
    param.Enabled=useParam.Value;

end
