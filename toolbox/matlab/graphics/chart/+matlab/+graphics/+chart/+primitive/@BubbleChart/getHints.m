function hints=getHints(hObj)



    scatterHints=getHints@matlab.graphics.chart.primitive.internal.AbstractScatter(hObj);


    extentsHints={};
    sz=hObj.SizeDataCache;
    ext=matlab.graphics.chart.primitive.utilities.arraytolimits(sz(~isinf(sz)));
    if any(isfinite(ext))
        extentsHints={{'BubbleSizeLimits',ext}};
    end


    p=hObj.Padding;
    paddingHints={{'PointPaddedX',p},{'PointPaddedY',p},{'PointPaddedZ',p}};

    hints=[scatterHints,extentsHints,paddingHints];

end
