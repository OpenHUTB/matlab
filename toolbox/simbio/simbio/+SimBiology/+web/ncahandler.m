function out=ncahandler(action,varargin)











    out={action};

    switch action
    case 'getDose'
        out=getDose(varargin{:});
    case 'verifyRange'
        out=verifyRange(action,varargin{:});
    end

end

function out=getDose(input)


    programInfo=getProgramInfo(input.matfileName);

    if isfield(programInfo,'dose')
        doseInfo=programInfo.dose;
        value=[];

        if isfield(doseInfo,'doseStep')


            value=doseInfo.doseStep;
        elseif isfield(doseInfo,'modelStep')


            value=doseInfo.modelStep;
        end

        [time,amount,rate]=parseDose(value.Table);
        out.Time=time;
        out.Amount=amount;
        out.Rate=rate;
        out.AmountUnits=value.AmountUnits;
        out.RateUnits=value.RateUnits;
        out.TimeUnits=value.TimeUnits;
    else
        out.Time=[];
        out.Amount=[];
        out.Rate=[];
        out.AmountUnits='';
        out.RateUnits='';
        out.TimeUnits='';
    end

end

function programInfo=getProgramInfo(matfile)

    if SimBiology.internal.variableExistsInMatFile(matfile,'programInfo')
        programInfo=load(matfile,'programInfo');
        programInfo=programInfo.programInfo;
    elseif SimBiology.internal.variableExistsInMatFile(matfile,'program')
        programInfo=load(matfile,'program');
        programInfo=programInfo.program;
    else
        programInfo=[];
    end

end

function[time,amount,rate]=parseDose(dose)

    isrepeat=any(strcmp('StartTime',dose.Properties.VariableNames));
    if isrepeat
        startTime=dose.StartTime;
        amount=dose.Amount;
        rate=dose.Rate;
        interval=dose.Interval;
        repeatCount=dose.RepeatCount;
        [time,amount,rate]=SimBiology.internal.convertRepeatDataToScheduleData(startTime,interval,repeatCount,amount,rate);
    else
        time=dose.Time;
        amount=dose.Amount;

        if any(strcmp(dose.Properties.VariableNames,'Rate'))
            rate=dose.Rate;
        else
            rate=zeros(size(amount));
        end
    end

end

function out=verifyRange(action,input)


    info=struct('error',false);

    range=input.value;
    if~isempty(range)
        try
            if~strcmp(range(1),'{')
                range=sprintf('{%s}',range);
            end
            value=eval(range);

            for i=1:numel(value)
                if any(size(value{i})~=[1,2])
                    info.error=true;
                    break;
                end
            end

            if(~input.supportsMultiple&&numel(value)>1)
                info.error=true;
            end
        catch
            info.error=true;
        end
    end

    out={action,info};

end
