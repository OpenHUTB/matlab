function ind=doGetNearestPoint(hObj,position)







    data={hObj.XDataCache,hObj.YDataCache};


    if numel(data{1})~=numel(data{2})
        ind=1;
        return
    end


    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    ind=utils.nearestPoint(hObj,position,true,data{:});
