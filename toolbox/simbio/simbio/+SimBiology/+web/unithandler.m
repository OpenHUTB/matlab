function out=unithandler(action,varargin)











    switch(action)
    case 'verifyUnits'
        out=verifyUnits(action,[varargin{:}]);
    case 'getUnitType'
        out=getUnitType(action,[varargin{:}]);
    case 'verifyDoseUnits'
        out=verifyDoseUnits(varargin{:});
    end

end

function out=verifyUnits(action,inputs)


    allowEmpty=inputs.allowEmpty;
    inputs=inputs.inputs;


    info=struct('valid','','value','','oldValue','','userData','');
    info=repmat(info,1,numel(inputs));

    for i=1:numel(inputs)
        input=inputs(i);

        if allowEmpty&&isempty(input.value)
            isvalid=true;
        else

            if startsWith(input.type,'dose')
                input.type='dose';
            end

            if startsWith(input.type,'rate')
                input.type='rate';
            end

            switch input.type
            case{'time','independent'}
                isvalid=SimBiology.internal.isValidTimeUnit(input.value);
            case 'rate'
                isvalid=SimBiology.internal.isValidRateUnit(input.value);
            case{'amount','dose'}
                isvalid=SimBiology.internal.isValidAmountUnit(input.value);
            case{'dependent','','covariate'}
                isvalid=SimBiology.internal.isValidUnit(input.value);
            case 'group'
                isvalid=strcmp(input.value,'dimensionless');
            otherwise
                isvalid=false;
            end
        end


        info(i).valid=isvalid;
        info(i).value=input.value;
        info(i).oldValue=input.oldValue;
        info(i).userData=input.userData;
    end

    out.action=action;
    out.info=info;

end

function out=verifyDoseUnits(input)

    if~isempty(input.amount)
        out.isvalidAmount=SimBiology.internal.isValidAmountUnit(input.amount);
    else
        out.isvalidAmount=true;
    end

    if~isempty(input.rate)
        out.isvalidRate=SimBiology.internal.isValidRateUnit(input.rate);
    else
        out.isvalidRate=true;
    end

    if~isempty(input.amount)
        out.isvalidTime=SimBiology.internal.isValidTimeUnit(input.time);
    else
        out.isvalidTime=true;
    end

end

function out=getUnitType(action,unit)

    type='dimensionless';
    if SimBiology.internal.isValidTimeUnit(unit)
        type='time';
    elseif SimBiology.internal.isValidRateUnit(unit)
        type='rate';
    elseif SimBiology.internal.isValidAmountUnit(unit)||SimBiology.internal.isValidVolumeUnit(unit)
        type='amount';
    elseif SimBiology.internal.isValidConcentrationUnit(unit)
        type='concentration';
    end

    out.action=action;
    out.type=type;


end
