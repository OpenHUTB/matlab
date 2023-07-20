

function ssid=getSSIDFromSFID(id)
    ssid=0;
    obj=sf('IdToHandle',id);
    if isprop(obj,'SSIdNumber')
        ssid=obj.SSIdNumber;
    end
end