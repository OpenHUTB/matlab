function propout=PrivateGetLength(eventSrc,eventData)








    if~isnan(eventData)&&~isempty(eventSrc.Increment)&&...
        ~isnan(eventSrc.Increment)&&eventSrc.Increment>0
        numIntervals=min(length(eventSrc.Start),length(eventSrc.End));
        propout=0;
        for k=1:numIntervals
            if eventSrc.End(k)-eventSrc.Start(k)>=0
                propout=propout+round((eventSrc.End(k)...
                -eventSrc.Start(k))/eventSrc.Increment)+1;
            end
        end
    else
        propout=eventData;
    end
