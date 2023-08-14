function[index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)



    interp=0;
    x=hObj.XData;
    y=hObj.YData;



    [m,n]=size(hObj.UData);
    if~isequal(size(x),size(hObj.UData))
        x=x(:).';
        x=x(ones(m,1),:);
    end
    if~isequal(size(y),size(hObj.UData))
        y=y(:);
        y=y(:,ones(n,1));
    end

    data={x(:),y(:)};

    if~isempty(hObj.ZData)
        data{3}=hObj.ZData(:);
    end


    sz=cellfun(@numel,data,'UniformOutput',true);
    if~all(sz==max(sz))
        index=1;
        return
    end


    utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
    index=utils.nearestPoint(hObj,position,false,data{:});