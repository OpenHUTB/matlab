function interpolationOrder=getInterpolationOrder(this,~)





    if strcmpi(getPropertyValue(this,'PlotType'),'stem')
        interpolationOrder=NaN;
    else
        interpolationOrder=1;
    end
end
