function[index,interp]=doIncrementIndex(hObj,index,direction,~)











    if strcmpi(direction,'up')||strcmpi(direction,'right')
        index=findNextValidIndex(hObj,index,@plus);
    else
        index=findNextValidIndex(hObj,index,@minus);
    end
    interp=0;

    function next=findNextValidIndex(hObj,start,func)


        order=hObj.AreaLayoutData.Order;
        order=unique(order(isfinite(order)),'stable');


        if isempty(order)
            next=start;
            return
        end


        start=max(min(order),min(start,max(order)));


        startArea=find(start==order);


        if isempty(startArea)
            [~,startArea]=min(abs(order-start));
            start=order(startArea);
        end


        nextArea=func(startArea,1);


        maxIndex=min([numel(order),numel(hObj.YDataCache)]);


        if nextArea>=1&&nextArea<=maxIndex
            next=order(nextArea);
        else
            next=start;
        end
