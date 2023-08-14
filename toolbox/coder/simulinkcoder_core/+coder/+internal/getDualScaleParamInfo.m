function info=getDualScaleParamInfo(model,paramName)



    info=struct('InternalToCalCompuNumerator',[],...
    'InternalToCalCompuDenominator',[],...
    'CalibrationMin',[],...
    'CalibrationMax',[],...
    'CompuMethodName',[]);

    obj=slResolve(paramName,model,'variable');
    assert(isa(obj,'Simulink.AbstractDualScaledParameter'));

    info.InternalToCalCompuNumerator=obj.InternalToCalCompuNumerator;
    info.InternalToCalCompuDenominator=obj.InternalToCalCompuDenominator;
    info.CalibrationMin=obj.CalibrationMin;
    info.CalibrationMax=obj.CalibrationMax;
    info.CalibrationUnit=obj.CalibrationDocUnits;
    info.NameForCompuMethod=paramName;

end

