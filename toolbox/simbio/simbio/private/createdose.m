function doseObj=createdose(name,time,amount,rate)






























    assert(ischar(name),...
    message('SimBiology:createdose:InvalidName'));
    assert(isnumeric(time)&&isvector(time),...
    message('SimBiology:createdose:InvalidTime'));
    numTimes=length(time);
    assert(isnumeric(amount)&&isvector(amount)&&length(amount)==numTimes,...
    message('SimBiology:createdose:InvalidAmount'));
    assert(isnumeric(rate)&&isvector(rate)&&length(rate)==numTimes,...
    message('SimBiology:createdose:InvalidRate'));


    time=time(:);
    amount=amount(:);
    rate=rate(:);
    allValues=[time;amount;rate];
    if any((allValues<0)|isinf(allValues))
        error(message('SimBiology:createdose:InvalidValue'));
    end


    rowsToRemove=(amount==0)|isnan(time)|isnan(amount);
    time(rowsToRemove)=[];
    amount(rowsToRemove)=[];
    rate(rowsToRemove)=[];


    rate(isnan(rate))=0;


    [time,idx]=sort(time);
    amount=amount(idx);
    rate=rate(idx);


    if length(amount)>1&&all(amount==amount(1))&&all(rate==rate(1))


        time1=time(1);
        interval=time(2)-time1;
        newTime=(time1:interval:time(end))';

        if isequal(newTime,time)
            doseObj=sbiodose(name,'repeat');
            doseObj.StartTime=time1;
            doseObj.Amount=amount(1);
            doseObj.Rate=rate(1);
            doseObj.Interval=interval;
            doseObj.RepeatCount=length(time)-1;
            return
        end
    end




    doseObj=sbiodose(name,'schedule');
    doseObj.Time=time;
    doseObj.Amount=amount;
    doseObj.Rate=rate;
