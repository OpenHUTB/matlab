function[index,interp]=doIncrementIndex(hObj,index,direction,~)











    if strcmpi(direction,'up')||strcmpi(direction,'right')
        index=findNextValidIndex(hObj,index,@plus);
    else
        index=findNextValidIndex(hObj,index,@minus);
    end
    interp=0;


    function next=findNextValidIndex(hObj,start,func)


        barOrder=hObj.BarOrder;


        if isempty(barOrder)
            next=start;
            return
        end







        if start>max(barOrder)
            start=max(barOrder);
        elseif start<min(barOrder)
            start=min(barOrder);
        end


        startBar=find(start==barOrder);


        if isempty(startBar)
            [~,startBar]=min(abs(barOrder-start));
            start=barOrder(startBar);
        end


        nextBar=func(startBar,1);









        maxIndex=min([numel(barOrder),numel(hObj.XDataCache),numel(hObj.YDataCache)]);


        if nextBar>=1&&nextBar<=maxIndex
            next=barOrder(nextBar);
        else
            next=start;
        end
