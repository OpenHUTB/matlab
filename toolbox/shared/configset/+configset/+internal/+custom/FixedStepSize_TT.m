function tooltip=FixedStepSize_TT(cs,~)




    scaleDiscreteRates=cs.isValidParam('ScaleDiscreteRates')&&strcmp(cs.getProp('ScaleDiscreteRates'),'on');
    if scaleDiscreteRates
        tooltip=message('RTW:configSet:SolverFixedStepSizeSTPToolTip').getString;
    else
        tooltip=message('RTW:configSet:SolverFixedStepSizeToolTip').getString;
    end

