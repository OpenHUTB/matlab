function[index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)



    interp=0;

    data={hObj.XDataCache,hObj.YDataCache};


    if numel(data{1})~=numel(data{2})
        index=1;
        return
    end


    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    index=utils.nearestPoint(hObj,position,false,data{:});