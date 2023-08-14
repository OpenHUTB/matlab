function[pAxes,sAxes]=getPlotNavigationAxes(this)




    if isSpectrogramMode(this)

        pAxes='C';
        sAxes='';
    elseif isCCDFMode(this)

        pAxes='Y';
        sAxes='X';

    elseif isCombinedViewMode(this)

        pAxes='CY';
        sAxes='';
    else

        pAxes='Y';
        sAxes='';
    end
end