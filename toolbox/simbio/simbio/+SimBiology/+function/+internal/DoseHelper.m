










classdef DoseHelper
    methods(Access=public,Static,Hidden=true)

        function out=getDoseTable(doseObject)
            out=cell(size(doseObject));

            for i=1:numel(doseObject)
                thisDose=doseObject(i);
                if isa(thisDose,'SimBiology.ScheduleDose')

                    if isempty(thisDose.Time)&&isempty(thisDose.Amount)&&isempty(thisDose.Rate)
                        out{i}=table([],[],[],'VariableNames',{'Time','Amount','Rate'});
                        out{i}.Properties.VariableUnits={thisDose.TimeUnits,thisDose.AmountUnits,thisDose.RateUnits};
                        continue;
                    end
                    if numel(thisDose.Time)~=numel(thisDose.Amount)
                        error(message('SimBiology:DoseHelper:getDoseTable_INVALID_TIME_OR_AMOUNT'));
                    end
                    time=reshape(thisDose.Time,[],1);
                    amount=reshape(thisDose.Amount,[],1);

                    if~isempty(thisDose.Rate)
                        if numel(thisDose.Rate)~=numel(thisDose.Amount)
                            error(message('SimBiology:DoseHelper:getDoseTable_INVALID_RATE_OR_AMOUNT'));
                        end
                        rate=reshape(thisDose.Rate,[],1);
                        out{i}=table(time,amount,rate,'VariableNames',{'Time','Amount','Rate'});
                        out{i}.Properties.VariableUnits={thisDose.TimeUnits,thisDose.AmountUnits,thisDose.RateUnits};

                    else
                        out{i}=table(time,amount,'VariableNames',{'Time','Amount'});
                        out{i}.Properties.VariableUnits={thisDose.TimeUnits,thisDose.AmountUnits};
                    end
                else


                    out{i}=table(wrapValueForTable(thisDose.StartTime),...
                    wrapValueForTable(thisDose.Amount),...
                    wrapValueForTable(thisDose.Rate),...
                    wrapValueForTable(thisDose.Interval),...
                    wrapValueForTable(thisDose.RepeatCount),...
                    'VariableNames',{'StartTime','Amount','Rate','Interval','RepeatCount'});

                    out{i}.Properties.VariableUnits={thisDose.TimeUnits,thisDose.AmountUnits,thisDose.RateUnits,thisDose.TimeUnits,''};
                end
            end

            if numel(doseObject)==1
                out=out{1};
            end
        end


        function setDoseTable(doseObject,doseTable)

            if iscell(doseTable)
                if~all(size(doseObject)==size(doseTable))
                    error(message('SimBiology:DoseHelper:setDoseTable_INPUT_INCORRECT_SIZE'));
                end
                for i=1:numel(doseTable)
                    verifyDoseTableAndPopulateDose(doseObject(i),doseTable{i})
                end
            elseif isa(doseTable,'table')
                if~isscalar(doseObject)
                    error(message('SimBiology:DoseHelper:setDoseTable_DOSE_TABLE_NOT_SCALAR'));
                end
                verifyDoseTableAndPopulateDose(doseObject,doseTable);
            else
                error(message('SimBiology:DoseHelper:setDoseTable_INPUT_INCORRECT_TYPE'));
            end

        end
    end
end

function verifyDoseTableAndPopulateDose(dose,doseTable)

    transaction=SimBiology.Transaction.create(dose);

    scheduleDoseProperties={'Time','Amount','Rate'};
    repeatDoseProperties={'StartTime','Amount','Interval','RepeatCount','Rate'};

    isScheduleDose=isa(dose,'SimBiology.ScheduleDose');

    if~isa(doseTable,'table')
        throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_INPUT_NOT_TABLE')));
    end
    tableProperties=doseTable.Properties;
    variableNames=tableProperties.VariableNames;
    variableUnits=tableProperties.VariableUnits;

    for i=1:numel(variableNames)
        thisVar=variableNames{i};
        thisValue=doseTable.(thisVar);
        if~isScheduleDose&&ismember(thisVar,repeatDoseProperties)
            if~(isnumeric(thisValue)||iscellstr(thisValue))
                throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_INPUT_DOSETABLE_INVALID2',thisVar)));
            end
        elseif~(isnumeric(thisValue)&&(isempty(thisValue)||iscolumn(thisValue)))
            throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_INPUT_DOSETABLE_INVALID',thisVar)));
        end
    end


    doseMatrix=doseTable{:,vartype('numeric')};
    if any(doseMatrix(:)<0)||any(~isfinite(doseMatrix(:)))
        throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_INPUT_NOT_FINITE_POSITIVE')));
    end

    if isScheduleDose
        try


            time=dose.Time;
            amount=dose.Amount;
            rate=dose.Rate;
            timeUnits=dose.TimeUnits;
            amountUnits=dose.AmountUnits;
            rateUnits=dose.RateUnits;

            timeIdx=strcmp(variableNames,'Time');
            amountIdx=strcmp(variableNames,'Amount');

            switch length(variableNames)
            case 2
                if~all(strcmp(sort(variableNames),sort(scheduleDoseProperties(1:2))))
                    throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_COLUMNS_NAMES_DOSETABLE_2VARS')));
                end
                if~isempty(doseTable)
                    dose.Time=doseTable.Time;
                    dose.Amount=doseTable.Amount;
                    dose.Rate=[];
                else
                    dose.Time=[];
                    dose.Amount=[];
                    dose.Rate=[];
                end


                if~isempty(variableUnits)
                    dose.TimeUnits=variableUnits{timeIdx};
                    dose.AmountUnits=variableUnits{amountIdx};



                    dose.RateUnits='';
                else
                    dose.TimeUnits='';
                    dose.AmountUnits='';
                    dose.RateUnits='';
                end

            case 3
                if~all(strcmp(sort(variableNames),sort(scheduleDoseProperties)))
                    throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_COLUMNS_NAMES_DOSETABLE_3VARS')));
                end

                rateIdx=strcmp(variableNames,'Rate');
                if~isempty(doseTable)
                    dose.Time=doseTable.Time;
                    dose.Amount=doseTable.Amount;
                    dose.Rate=doseTable.Rate;
                else
                    dose.Time=[];
                    dose.Amount=[];
                    dose.Rate=[];
                end

                if~isempty(variableUnits)
                    dose.TimeUnits=variableUnits{strcmp(variableNames,'Time')};
                    dose.AmountUnits=variableUnits{strcmp(variableNames,'Amount')};
                    dose.RateUnits=variableUnits{rateIdx};
                else
                    dose.TimeUnits='';
                    dose.AmountUnits='';
                    dose.RateUnits='';
                end
            otherwise
                throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_INPUT_NOT_TABLE_WITH_RIGHTCOLUMN_SCHEDULE')));
            end
        catch me
            dose.Time=time;
            dose.Amount=amount;
            dose.Rate=rate;
            dose.TimeUnits=timeUnits;
            dose.RateUnits=rateUnits;
            dose.AmountUnits=amountUnits;
            rethrow(me);
        end
    else
        try
            startTime=dose.StartTime;
            amount=dose.Amount;
            rate=dose.Rate;
            interval=dose.Interval;
            repeatCount=dose.RepeatCount;
            tUnits=dose.TimeUnits;
            amountUnits=dose.AmountUnits;
            rateUnits=dose.RateUnits;

            if height(doseTable)>1
                throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_INVALID_NUMBER_OF_ROWS_DOSETABLE')));
            end
            if isempty(doseTable)
                throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_EMPTY_DOSETABLE')));
            end

            startTimeIdx=strcmp(variableNames,'StartTime');
            amountIdx=strcmp(variableNames,'Amount');
            intervalIndex=strcmp(variableNames,'Interval');
            repeatCountIndex=strcmp(variableNames,'RepeatCount');


            switch length(variableNames)
            case 4
                if~all(strcmp(sort(variableNames),sort(repeatDoseProperties(1:end-1))))
                    throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_COLUMNS_NAMES_DOSETABLE_4VARS')));
                end
                dose.StartTime=unwrapValueFromTable(doseTable.StartTime);
                dose.Amount=unwrapValueFromTable(doseTable.Amount);
                dose.Interval=unwrapValueFromTable(doseTable.Interval);
                dose.RepeatCount=unwrapValueFromTable(doseTable.RepeatCount);
                dose.Rate=0;

                if~isempty(variableUnits)



                    timeUnits=variableUnits{startTimeIdx};
                    if~isempty(timeUnits)&&~SimBiology.internal.areUnitsValidAndConsistent(timeUnits,'second')
                        throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_TIMEUNITS_DOSETABLE_REPEAT')));
                    end




                    if isempty(timeUnits)
                        timeUnits=variableUnits{intervalIndex};
                        if~isempty(timeUnits)&&~SimBiology.internal.areUnitsValidAndConsistent(timeUnits,'second')
                            throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_INTERVAL_UNITS_DOSETABLE_REPEAT')));
                        end
                    else
                        if~isempty(variableUnits{intervalIndex})
                            if SimBiology.internal.areUnitsValidAndConsistent(variableUnits{intervalIndex},'second')
                                dose.Interval=sbiounitcalculator(variableUnits{intervalIndex},timeUnits,dose.Interval);
                            else
                                throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_INTERVAL_UNITS_DOSETABLE_REPEAT')));
                            end
                        end
                    end

                    dose.TimeUnits=timeUnits;

                    try
                        dose.AmountUnits=variableUnits{amountIdx};
                    catch
                        throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_AMOUNTUNITS_DOSETABLE_REPEAT')));
                    end

                    if~isempty(variableUnits{repeatCountIndex})&&~strcmp(variableUnits{repeatCountIndex},'dimensionless')
                        throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_REPEATCOUNT_UNITS_DOSETABLE_REPEAT')));
                    end



                    dose.RateUnits='';
                else
                    dose.TimeUnits='';
                    dose.AmountUnits='';
                    dose.RateUnits='';
                end
            case 5
                if~all(strcmp(sort(variableNames),sort(repeatDoseProperties)))
                    throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_COLUMNS_NAMES_DOSETABLE_5VARS')));
                end

                dose.StartTime=unwrapValueFromTable(doseTable.StartTime);
                dose.Amount=unwrapValueFromTable(doseTable.Amount);
                dose.Interval=unwrapValueFromTable(doseTable.Interval);
                dose.RepeatCount=unwrapValueFromTable(doseTable.RepeatCount);
                dose.Rate=unwrapValueFromTable(doseTable.Rate);

                if~isempty(variableUnits)


                    timeUnits=variableUnits{startTimeIdx};
                    if~isempty(timeUnits)&&~SimBiology.internal.areUnitsValidAndConsistent(timeUnits,'second')
                        throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_TIMEUNITS_DOSETABLE_REPEAT')));
                    end




                    if isempty(timeUnits)
                        timeUnits=variableUnits{intervalIndex};
                        if~isempty(timeUnits)&&~SimBiology.internal.areUnitsValidAndConsistent(timeUnits,'second')
                            throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_INTERVAL_UNITS_DOSETABLE_REPEAT')));
                        end
                    else
                        if~isempty(variableUnits{intervalIndex})
                            if SimBiology.internal.areUnitsValidAndConsistent(variableUnits{intervalIndex},'second')
                                dose.Interval=sbiounitcalculator(variableUnits{intervalIndex},timeUnits,dose.Interval);
                            else
                                throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_INTERVAL_UNITS_DOSETABLE_REPEAT')));
                            end
                        end
                    end


                    dose.TimeUnits=timeUnits;

                    try
                        dose.AmountUnits=variableUnits{strcmp(variableNames,'Amount')};
                    catch
                        throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_AMOUNTUNITS_DOSETABLE_REPEAT')));
                    end

                    try
                        dose.RateUnits=variableUnits{strcmp(variableNames,'Rate')};
                    catch
                        throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_RATEUNITS_DOSETABLE')));
                    end

                    repeatCountIndex=strcmp(variableNames,'RepeatCount');
                    if~isempty(variableUnits{repeatCountIndex})&&~strcmp(variableUnits{repeatCountIndex},'dimensionless')
                        throwAsCaller(MException(message('SimBiology:DoseHelper:INVALID_REPEATCOUNT_UNITS_DOSETABLE_REPEAT')));
                    end
                else
                    dose.TimeUnits='';
                    dose.AmountUnits='';
                    dose.RateUnits='';
                end

            otherwise
                throwAsCaller(MException(message('SimBiology:DoseHelper:setDoseTable_INPUT_NOT_TABLE_WITH_RIGHTCOLUMN_REPEAT')));

            end
        catch me
            dose.StartTime=startTime;
            dose.Amount=amount;
            dose.Rate=rate;
            dose.Interval=interval;
            dose.RepeatCount=repeatCount;
            dose.TimeUnits=tUnits;
            dose.RateUnits=rateUnits;
            dose.AmountUnits=amountUnits;
            rethrow(me);
        end
    end
    transaction.commit();
end

function value=wrapValueForTable(value)
    if ischar(value)
        value={value};
    end
end

function value=unwrapValueFromTable(value)
    if iscell(value)
        value=value{1};
    end
end
