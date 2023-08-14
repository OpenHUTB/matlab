function[time,amount,rate]=dose2mat(obj)











    if strcmp(obj.Type,'repeatdose')

        startTime=resolveParameterOrValue(obj,'StartTime');
        interval=resolveParameterOrValue(obj,'Interval');
        repeatCount=resolveParameterOrValue(obj,'RepeatCount');
        amount=resolveParameterOrValue(obj,'Amount');
        rate=resolveParameterOrValue(obj,'Rate');

        if startTime<0||interval<0||repeatCount<0||amount<0||rate<0
            startTime=0;
            interval=0;
            repeatCount=0;
            amount=0;
            rate=0;
        end

        [time,amount,rate]=SimBiology.internal.convertRepeatDataToScheduleData(...
        startTime,interval,repeatCount,amount,rate);
    else
        time=obj.Time;
        amount=obj.Amount;
        rate=obj.Rate;
    end


    function out=resolveParameterOrValue(dose,property)
        out=-1;
        if isnumeric(dose.(property))
            out=dose.(property);
        else
            param=dose.resolveparameter(dose.Parent,dose.(property));
            if~isempty(param)
                out=param.Value;
            end
        end