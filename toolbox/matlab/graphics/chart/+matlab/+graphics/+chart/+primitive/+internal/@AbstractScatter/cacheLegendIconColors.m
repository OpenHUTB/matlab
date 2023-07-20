function cacheLegendIconColors(hObj,updateState,cdata)




    hObj.CurrentIconColorInfo.BackgroundColor=updateState.BackgroundColor;

    hColorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
    hColorIter.CDataMapping='scaled';

    if isempty(cdata)

        hObj.CurrentIconColorInfo.ColorData='none';

    elseif isequal(size(cdata),[1,3])



        hColorIter.Colors=cdata;
        truecolordata=updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
        hObj.CurrentIconColorInfo.ColorData=truecolordata.Data;

    elseif isvector(cdata)







        cdata_nonnan=cdata(~isnan(cdata));
        if isempty(cdata_nonnan)
            modeindex=NaN;
        else
            modeindex=mode(cdata_nonnan);
        end


        hColorIter.Colors=modeindex;
        truecolordata=updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);
        if~isempty(truecolordata)
            hObj.CurrentIconColorInfo.ColorData=truecolordata.Data;
        else
            hObj.CurrentIconColorInfo.ColorData='none';
        end

    elseif size(cdata,2)==3




        modeindex=ceil(size(cdata,1)/2);


        hColorIter.Colors=cdata(modeindex,:);
        truecolordata=updateState.ColorSpace.TransformTrueColorToTrueColor(hColorIter);
        hObj.CurrentIconColorInfo.ColorData=truecolordata.Data;

    else

        hObj.CurrentIconColorInfo.ColorData='none';
    end

end
