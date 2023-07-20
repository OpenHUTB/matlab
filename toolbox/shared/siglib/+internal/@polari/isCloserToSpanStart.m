function y=isCloserToSpanStart(p,c_current)




    c_endpts=p.hAngleSpan.SpanCplx;
    if isempty(c_endpts)
        y=false;
    else
        c=[c_endpts{1},c_endpts{2}];
        if numel(c)<2
            y=false;
        else
            d=internal.polariCommon.cangleAbsDiff(c_current,c);
            y=d(1)<d(2);
        end
    end
