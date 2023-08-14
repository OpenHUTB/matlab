function setTimeStamp(h,timeStamp)



    h.ModifiedTimeStamp=get_param(h.Model,'RTWModifiedTimeStamp');
    if isempty(timeStamp)
        h.TimeStamp=0;
        return
    end
    if ischar(timeStamp)
        try
            firstWord=strtok(timeStamp);

            if~isempty(strfind('Sun Mon Tue Wed Thu Fri Sat',firstWord))
                ts=datenum(timeStamp(1+length(firstWord):end));
            else
                ts=datenum(timeStamp);
            end
            h.TimeStamp=RTW.TraceInfoBase.datenum2timestamp(ts);
        catch me %#ok<NASGU>
        end
    else
        h.TimeStamp=timeStamp;
    end
