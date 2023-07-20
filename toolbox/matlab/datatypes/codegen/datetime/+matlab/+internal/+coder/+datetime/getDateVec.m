function[y,mo,d,h,m,s]=getDateVec(dd)%#codegen









    coder.allowpcode('plain');

    MSPerSecond=1000;
    MSPerDay=86400000;



    [msOfDay,wholeDays]=matlab.internal.coder.doubledouble.divmod(dd,MSPerDay);
    [wholeSecs,fracSecs]=matlab.internal.coder.doubledouble.floorFrac(matlab.internal.coder.doubledouble.divide(msOfDay,MSPerSecond));

    [y,mo,d]=matlab.internal.coder.datetime.days2ymd(real(wholeDays));
    [h,m,s]=matlab.internal.coder.datetime.secs2hms(real(wholeSecs));
    s=s+real(fracSecs);






    for j=1:numel(s)
        if s(j)==60
            s(j)=s(j)-7.1054e-15;
        end
        if dd(j)==inf
            y(j)=inf;
        elseif dd(j)==-inf
            y(j)=-inf;
        end
    end
end