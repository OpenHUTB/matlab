
function timestr=getCurrentTimeString(~)
    time=datetime('now','TimeZone','local');
    offset=tzoffset(time);
    offsetStr=char(offset);
    if offset>=0&&offsetStr(1)~='+'
        offsetStr=['+',offsetStr];
    end
    timestr=[datestr(time,'yyyy-mm-ddTHH:MM:SS'),offsetStr];
end

