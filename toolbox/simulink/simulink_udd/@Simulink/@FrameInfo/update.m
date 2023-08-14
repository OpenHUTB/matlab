function h=update(h,eventData)







    numIntervals=min(length(h.FrameStart),length(h.FrameEnd));
    if numIntervals<=0||...
        all(h.FrameEnd(1:numIntervals)<h.FrameStart(1:numIntervals))||...
        isempty(h.Framesize)||(isfinite(h.Framesize)&&floor(h.Framesize)<=0)||...
        isnan(h.Framesize)
        h.Start=[];
    else
        h.Start=h.FrameStart;
    end


    if h.Framesize>0&&strcmp(h.State,'Samples')
        h.Increment=h.FrameIncrement/h.Framesize;
    elseif strcmp(h.State,'Frames')
        h.Increment=h.FrameIncrement;
    else
        h.Increment=NaN;
    end


    numIntervals=min(length(h.FrameStart),length(h.FrameEnd));
    if numIntervals<=0||...
        all(h.FrameEnd(1:numIntervals)<h.FrameStart(1:numIntervals))||...
        (isfinite(h.Framesize)&&floor(h.Framesize)<=0)||...
        isnan(h.Framesize)
        h.End=[];
    elseif strcmp(h.State,'Samples')
        framesize=floor(h.Framesize);

        h.End=h.FrameEnd+h.FrameIncrement*(framesize-1)/framesize;
    else
        h.End=h.FrameEnd;
    end