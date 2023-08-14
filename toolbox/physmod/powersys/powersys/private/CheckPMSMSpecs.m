function S=CheckPMSMSpecs(spec,CmdLineCall)

    S=false;
    errMsgId='SpecializedPowerSystems:PowerPMSynchronousMachineParams:InvalidSetting';

    if CmdLineCall




        RF={'backEMF',{'sinusoidal','trapezoidal'};
        'rotorType',{'round','salient','salient-pole'};
        'R',{};
        'suppliedConstant',{'voltage','torque','flux','torque constant','voltage constant'};
        'k',{};
        'kUnitsNum',{'vpeak','vrms','n.m','n.cm','oz.in','lb.in','lb.ft','v.s'};
        'kUnitsDenom',{'krpm','rad/s','apeak','arms'};
        'J',{};
        'inertiaUnits',{'kg.m^2','kg.cm^2','g.cm^2','lb.in.s^2','oz.in.s^2'}
        'F',{};
        'frictionUnits',{'n.m.s','n.m/rpm','oz.in/rpm','oz.in/krpm'}
        'p',{};};



        if~isstruct(spec)

            error(message('physmod:powersys:library:PMSMParamsInvalidSpec'));
        end



        for i=1:length(RF)


            if~isfield(spec,RF{i,1})

                error(message('physmod:powersys:library:PMSMParamsSpecMissingField',RF{i,1}));
            end


            if~isempty(RF{i,2})

                if isempty(spec.(RF{i,1}))
keyboard
                end
                if isempty(cell2mat(strfind(RF{i,2},lower(spec.(RF{i,1})))))

                    error(message('physmod:powersys:library:PMSMParamsSpecUnknownOption',spec.(RF{i,1}),RF{i,1}));
                end

            end

        end



        switch lower(spec.rotorType)
        case 'round'
            if~isfield(spec,'Lab')

                error(message('physmod:powersys:library:PMSMParamsSpecMissingField','Lab'));
            end
        case{'salient','salient-pole'}
            if~isfield(spec,'Ld')

                error(message('physmod:powersys:library:PMSMParamsSpecMissingField','Ld'));
            end
            if~isfield(spec,'Lq')

                error(message('physmod:powersys:library:PMSMParamsSpecMissingField','Lq'));
            end
        end


        switch lower(spec.rotorType)
        case{'salient','salient-pole'}
            switch lower(spec.backEMF)
            case 'trapezoidal'
                error(message('physmod:powersys:library:PMSMParamsSpecUnsupportedRotorType'));
            end
        end

    end



    if~validatePositiveNumeric(spec.R,'R',CmdLineCall)
        return
    end

    switch lower(spec.rotorType)
    case 'round'
        if~validatePositiveNumeric(spec.Lab,'Lab',CmdLineCall)
            return
        end
    case{'salient','salient-pole'}
        if~validatePositiveNumeric(spec.Ld,'Ld',CmdLineCall)
            return
        end
        if~validatePositiveNumeric(spec.Lq,'Lq',CmdLineCall)
            return
        end
    end

    if~validatePositiveNumeric(spec.k,'k',CmdLineCall)
        return
    end

    if~validatePositiveOrZeroNumeric(spec.J,'J',CmdLineCall)
        return
    end

    if~validatePositiveOrZeroNumeric(spec.F,'F',CmdLineCall)
        return
    end

    isPolePairsPositive=(spec.p>0);
    isPolePairsInteger=((round(spec.p)-spec.p)==0);
    if~(isPolePairsPositive&&isPolePairsInteger)
        errMessage=message('physmod:powersys:common:NonZeroPositiveInteger','Pole pairs');
        if CmdLineCall
            error(errMessage);
        else
            errordlg(errMessage.getString,errMessage.Identifier,'modal');
            return
        end
    end

    S=true;

    return

    function isValid=validatePositiveOrZeroNumeric(value,field,CmdLineCall)

        isValid=0;
        isInputEmpty=isempty(value);
        isInputNumeric=isnumeric(value);
        if(~isInputEmpty&&isInputNumeric)
            if(value>=0)
                isValid=1;
            end
        end

        if~isValid
            errMessage=message('physmod:powersys:common:GreaterThanOrEqualTo','Specifications',field,'0');
            if CmdLineCall
                error(errMessage);
            else
                errordlg(errMessage.getString,errMessage.Identifier,'modal');
            end
        end

        function isValid=validatePositiveNumeric(value,field,CmdLineCall)

            isValid=0;
            isInputEmpty=isempty(value);
            isInputNumeric=isnumeric(value);
            if(~isInputEmpty&&isInputNumeric)
                if(value>0)
                    isValid=1;
                end
            end

            if~isValid
                errMessage=message('physmod:powersys:common:GreaterThan','Specifications',field,'0');
                if CmdLineCall
                    error(errMessage);
                else
                    errordlg(errMessage.getString,errMessage.Identifier,'modal');
                end
            end
