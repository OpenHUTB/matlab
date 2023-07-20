function[isValid,min,max,pObj,rangeVec]=evalNumericParameterRange(block,unevaledParamStr)








    isValid=false;
    min=[];
    max=[];
    pObj=[];
    rangeVec=[];
    try
        var=slResolve(unevaledParamStr,block.Handle,'variable','startUnderMask');
        if~isempty(var)&&isa(var,'Simulink.Parameter')

            value=SimulinkFixedPoint.EntityAutoscalers.ParameterObjectEntityAutoscaler.resolveParameterObjectValue(var,unevaledParamStr,block.Handle);

            if~isstruct(value)
                rangeVec=SimulinkFixedPoint.safeConcat(var.Min,var.Max,value);
                [min,max]=SimulinkFixedPoint.extractMinMax(rangeVec);
                isValid=true;
                pObj=var;
                return;
            end
        end
    catch %#ok<CTCH>

    end

    try
        rangeVec=slResolve(unevaledParamStr,block.Handle,'expression','startUnderMask');
        [min,max]=SimulinkFixedPoint.extractMinMax(rangeVec);
        isValid=true;
    catch %#ok<CTCH>

    end


