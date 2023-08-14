function out=FixedStepSizePrompt(cs,~)




    scaleDiscreteRates=cs.isValidParam('ScaleDiscreteRates')&&...
    strcmp(cs.getProp('ScaleDiscreteRates'),'on');
    if scaleDiscreteRates
        out=message('RTW:configSet:SolverFixedStepSizeSTPName').getString;
    else
        out=message('RTW:configSet:SolverFixedStepSizeName').getString;
    end
