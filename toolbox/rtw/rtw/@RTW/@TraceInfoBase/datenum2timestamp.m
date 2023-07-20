function out=datenum2timestamp(ts)





    dt=datetime(ts,'ConvertFrom','datenum','TimeZone','local');
    tzero=datetime('2004/03/01','TimeZone','UTC','InputFormat','yyyy/MM/dd');
    out=floor(seconds(dt-tzero));
    out=max(0,out);
