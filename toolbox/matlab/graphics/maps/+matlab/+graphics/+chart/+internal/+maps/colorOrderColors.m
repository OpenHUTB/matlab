function colors=colorOrderColors(m,obj)












    c=get(groot,'FactoryGeoaxesColorOrder');


    if isa(obj,'matlab.graphics.chart.internal.maps.Bubble')
        gb=ancestor(obj.ScatterPrimitive,'matlab.graphics.chart.GeographicBubbleChart');
        if~isempty(gb)
            c=gb.getColorOrder;
        end
    end

    if~isempty(m)

        colors=c(rem(0:m-1,size(c,1))+1,:);
    else
        colors=c;
    end