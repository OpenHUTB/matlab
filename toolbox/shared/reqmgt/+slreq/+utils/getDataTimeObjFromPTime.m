function out=getDataTimeObjFromPTime(ptime,timezone)
    if nargin<2
        timezone='Local';
    end

    if ptime==0
        out=slreq.utils.DefaultValues.getNaT;
    else
        out=datetime(ptime,'ConvertFrom','posixtime','TimeZone',timezone);
    end
end