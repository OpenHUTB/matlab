

function sfId=getSFIDFromSSID(chartH,ssid)
    if ischar(ssid)
        ssid=str2double(ssid);
    end
    sfId=-1;
    chartId=sfprivate('block2chart',chartH);
    chartObj=sf('IdToHandle',chartId);
    obj=find(chartObj,'SSIdNumber',ssid);
    if~isempty(obj)&&isscalar(obj)&&isprop(obj,'Id')
        sfId=obj.Id;
    end
end