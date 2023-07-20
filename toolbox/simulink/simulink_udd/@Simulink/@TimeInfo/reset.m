function hout=reset(h,t)





    hout=h;
    hout.Length_=length(t);
    if length(t)>=2
        t=timeseries.tsChkTime(t);

        if min(diff(t))<=0
            error(message('Simulink:TimeInfo:nosort'))
        end
        hout.Start=t(1);
        hout.Increment=NaN;
        hout.End=t(end);
        hout.Time_=t;
    elseif length(t)==1
        hout.Start=t(1);
        hout.End=t(1);
        hout.Time_=t;
    else
        hout.Start=[];
        hout.End=[];
        hout.Length_=0;
        hout.Increment=NaN;
        hout.Time_=t;
        return
    end
