function[convertedTime]=ConvertRelativeTimeToAboluteTime(Time)




















    sizeOfTimeArray=size(Time);
    convertedTime=zeros(sizeOfTimeArray);

    runningTime=0;

    for idx=1:sizeOfTimeArray

        if idx==1
            runningTime=Time(idx);
        elseif Time(idx+1)>Time(idx)
            runningTime=runningTime+Time(idx)-Time(idx-1);
        else
            runningTime=runningTime+Time(idx);
        end

        convertedTime(idx)=runningTime;

    end

