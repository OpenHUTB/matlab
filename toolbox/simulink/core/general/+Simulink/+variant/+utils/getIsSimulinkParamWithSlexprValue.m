function isSimulinkParamWithSlexprValue=getIsSimulinkParamWithSlexprValue(controlVar)
    isSimulinkParamWithSlexprValue=isa(controlVar,'Simulink.Parameter')&&isa(controlVar.Value,'Simulink.data.Expression');
end