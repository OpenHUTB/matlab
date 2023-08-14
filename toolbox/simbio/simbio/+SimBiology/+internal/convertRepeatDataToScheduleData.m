function[time,amount,rate]=convertRepeatDataToScheduleData(startTime,interval,repeatCount,amount,rate)











    if interval==0

        time=startTime;
    else
        if rem(repeatCount,1)==0
            time=startTime+((0:repeatCount)*interval);
            amount=ones(1,repeatCount+1)*amount;
            rate=ones(1,repeatCount+1)*rate;
        else
            time=0;
            amount=0;
            rate=0;
        end
    end
end
