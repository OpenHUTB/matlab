function[index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)




    data={hObj.XDataCache,hObj.YDataCache};
    if~isempty(hObj.ZDataCache)
        data{3}=hObj.ZDataCache;
    end

    sizes=hObj.SizeData;
    if isscalar(sizes)
        if~isfinite(sizes)

            index=1;
            return
        end
    else

        data{1}(~isfinite(sizes))=NaN;
    end


    sz=cellfun(@numel,data,'UniformOutput',true);
    if~all(sz==1|sz==max(sz))
        index=1;
        return
    end



    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    index=utils.nearestPoint(hObj,position,false,data{:});

    if isempty(index)
        index=1;
    end

    interp=0;
