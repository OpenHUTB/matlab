function output=getDateTime(datetimeObj,type)


    readOption='Local';

    switch type

    case 'Read'



        if datenum(datetimeObj)==719529
            output=slreq.utils.DefaultValues.getNaT;
            return;
        end




        if isempty(datetimeObj.TimeZone)

            datetimeObj.TimeZone='UTC';
        end

        if strcmpi(datetimeObj.TimeZone,'utc')
            datetimeObj.TimeZone=readOption;
            output=datetimeObj;
        else
            error('Wrong time zone specified!');
        end

    case 'Write'

        if isnat(datetimeObj)
            output=slreq.data.ReqData.initialTime;
            return;
        end




        if isempty(datetimeObj.TimeZone)

            datetimeObj.TimeZone='Local';
        end
        datetimeObj.TimeZone='UTC';
        output=datetimeObj;
    otherwise

        error('Invalue type specified');
    end
end

