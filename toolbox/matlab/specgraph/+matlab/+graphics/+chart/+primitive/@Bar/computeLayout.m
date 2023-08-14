function computeLayout(hBar,hPeers)



    if isempty(hPeers)

        return;
    end


    [x,y,map]=matlab.graphics.chart.primitive.internal.collectSeriesData(hPeers);


    isGrouped=strcmpi(hBar.BarLayout,'grouped');
    maxSpacing=inf;
    if iscategorical(hBar.XData)
        maxSpacing=1;
    end
    [xOffset,yOffset,widthScaleFactor]=matlab.graphics.chart.primitive.bar.internal.computeBars(x,y,isGrouped,maxSpacing);


    for i=1:length(hPeers)
        if isempty(yOffset)
            yOffsetVal=[];
        else
            yData=hPeers(i).YData;


            yOffsetVal=zeros(size(yData));
            valid=isfinite(map(:,i));
            yOffsetVal(map(valid,i))=yOffset(valid,i);
        end

        set(hPeers(i),'XOffset_I',xOffset(i),'YOffset_I',yOffsetVal,...
        'WidthScaleFactor_I',widthScaleFactor(i));
    end
