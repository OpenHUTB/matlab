function result=initialTime(isClear)





    if nargin<1
        isClear=false;
    end
    persistent zeroTime

    if isClear
        result=[];
        clear zeroTime;
        return;
    end

    if isempty(zeroTime)
        zeroTime=datetime('01-Jan-1970 00:00:00','TimeZone','UTC','Locale','en_US');
    end
    result=zeroTime;


end
