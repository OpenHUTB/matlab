function plotHarmonicBarScaled(harmonicOrder,harmonicMagnitude,fundamentalFrequency,hAxes)







    thdPercent=ee.internal.signal.calculateThdPercent(harmonicOrder,harmonicMagnitude);


    fundamentalMagnitude=harmonicMagnitude(harmonicOrder==1);
    harmonicMagnitudeScaled=100*harmonicMagnitude./fundamentalMagnitude;



    if exist('hAxes','var')&&ishghandle(hAxes)
        hFigure=get(hAxes,'parent');
    else
        hFigure=figure('visible','off','numbertitle','off');
        hAxes=axes('parent',hFigure);
    end
    bar(harmonicOrder,harmonicMagnitudeScaled,'parent',hAxes);
    xlabel(hAxes,getString(message('physmod:ee:library:comments:utils:signal:plotHarmonicBarScaled:label_HarmonicNumber')));
    ylabel(hAxes,getString(message('physmod:ee:library:comments:utils:signal:plotHarmonicBarScaled:label_OfFundamental')));
    grid(hAxes,'on');
    xlim(hAxes,[min(harmonicOrder)-5,max(harmonicOrder)+5]);
    title(hAxes,getString(message('physmod:ee:library:comments:utils:signal:plotHarmonicBarScaled:sprintf_Fundamental3gHz3gTHD3g',num2str(fundamentalFrequency),num2str(fundamentalMagnitude),num2str(thdPercent))));

    set(hFigure,'visible','on');

end

