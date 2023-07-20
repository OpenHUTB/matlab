function[outParams,varargout]=power_PMSynchronousMachineConstants_pr(inParams)








































































    isPolePairsPositive=(inParams.p>0);
    isPolePairsInteger=((round(inParams.p)-inParams.p)==0);
    if~(isPolePairsPositive&&isPolePairsInteger)
        msg=['Invalid value ''',num2str(inParams.p),''' for number of pole pairs, which ',...
        'must be a positive integer.'];
        myErrorFcn(msg);
    end



    torqueConstants.newtonMeter2OunceInch=141.61193228;

    suppliedConstant=inParams.suppliedConstant;

    switch suppliedConstant
    case 'Flux induced by magnets'
        lambda=inParams.lambda;
        validatePositiveNumeric(lambda,'lambda');
        [ke,keSt]=computeVoltageConstant(suppliedConstant,inParams,torqueConstants);
        [kt,ktSt]=computeTorqueConstant(suppliedConstant,inParams,torqueConstants);
    case 'Voltage constant'
        validatePositiveNumeric(inParams.ke,'ke');
        lambda=computeLambda(suppliedConstant,inParams,torqueConstants);

        [ke,keSt]=computeVoltageConstant(suppliedConstant,inParams,torqueConstants);
        [kt,ktSt]=computeTorqueConstant(suppliedConstant,inParams,torqueConstants);
    case 'Torque constant'
        validatePositiveNumeric(inParams.kt,'kt');
        lambda=computeLambda(suppliedConstant,inParams,torqueConstants);
        [ke,keSt]=computeVoltageConstant(suppliedConstant,inParams,torqueConstants);

        [kt,ktSt]=computeTorqueConstant(suppliedConstant,inParams,torqueConstants);
    otherwise
        invalidValueError(suppliedConstant,'suppliedConstant');
    end


    outParams.lambda=lambda;
    outParams.ke=ke;
    outParams.kt=kt;

    testParams.ke=keSt;
    testParams.kt=ktSt;

    varargout{1}=testParams;


    outParams.J=[];

    if isfield(inParams,'inertiaUnits')
        if(~isempty(inParams.J)&&~isempty(inParams.inertiaUnits))
            validatePositiveOrZeroNumeric(inParams.J,'J');

            inertiaConstants.k1=0.11298483016;
            inertiaConstants.k2=0.0980665;
            inertiaConstants.k3=3417.17186469;
            switch inParams.inertiaUnits
            case 'kg.m^2'
                J=inParams.J;
            case 'kg.cm^2'
                J=inParams.J*1e-04;
            case 'g.cm^2'
                J=inParams.J*1e-07;
            case 'lb.in^2'
                J=inParams.J/inertiaConstants.k3;
            case 'oz.in.s^2'
                J=inParams.J*inertiaConstants.k1/16;
            case 'lb.in.s^2'
                J=inParams.J*inertiaConstants.k1;
            case 'kg.cm.s^2'
                J=inParams.J*inertiaConstants.k2;
            otherwise
                invalidUnitsError(inParams.inertiaUnits,'inertiaUnits');
            end

            outParams.J=J;
        end
    end



    outParams.F=[];

    if isfield(inParams,'frictionUnits')
        if(~isempty(inParams.F)&&~isempty(inParams.frictionUnits))
            validatePositiveOrZeroNumeric(inParams.F,'F');



            frictionConstants.k1=3/(100*pi*3.5969431019*39.37007874);

            switch inParams.frictionUnits
            case 'N.m.s'
                F=inParams.F;
            case 'N.m/rpm'
                F=inParams.F*30/pi;
            case 'oz.in/rpm'
                F=inParams.F*frictionConstants.k1*1000;
            case 'oz.in/krpm'
                F=inParams.F*frictionConstants.k1;
            otherwise
                invalidUnitsError(inParams.frictionUnits,'frictionUnits');
            end

            outParams.F=F;
        end
    end



    function[ke,keSt]=computeVoltageConstant(suppliedConstant,inParams,torqueConstants)





        polePairs=inParams.p;
        keUnitsNum=inParams.keUnitsNum;
        keUnitsDenom=inParams.keUnitsDenom;
        backEMF=inParams.backEMF;

        switch suppliedConstant
        case 'Flux induced by magnets'
            lambdaUnits=inParams.lambdaUnits;
            lambda=inParams.lambda;

            switch lambdaUnits
            case 'V.s'
                switch backEMF
                case{'Sinusoidal','sinusoidal'}
                    keSt=100*pi*polePairs*lambda/sqrt(3);
                case{'Trapezoidal','trapezoidal'}
                    keSt=200*pi*lambda*polePairs/3;
                otherwise
                    invalidValueError(backEMF,'backEMF');
                end
            otherwise
                invalidUnitsError(lambdaUnits,'lambdaUnits');
            end


            ke=convertKeStandard2Custom(keSt,keUnitsNum,keUnitsDenom);

        case 'Torque constant'

            kt=convertKtCustom2Standard(inParams.kt,inParams.ktUnitsNum,...
            inParams.ktUnitsDenom,torqueConstants);


            switch backEMF
            case{'Sinusoidal','sinusoidal'}
                keSt=200*pi*kt/(3*sqrt(3));
            case{'Trapezoidal','trapezoidal'}
                keSt=100*pi*kt/3;
            otherwise
                invalidValueError(backEMF,'backEMF');
            end


            ke=convertKeStandard2Custom(keSt,keUnitsNum,keUnitsDenom);

        case 'Voltage constant'
            ke=convertKeCustom2Standard(inParams.ke,inParams.keUnitsNum,...
            inParams.keUnitsDenom);
            keSt=ke;
        otherwise
            invalidValueError(suppliedConstant,'suppliedConstant');
        end

        function[kt,ktSt]=computeTorqueConstant(suppliedConstant,inParams,torqueConstants)





            polePairs=inParams.p;
            ktUnitsNum=inParams.ktUnitsNum;
            ktUnitsDenom=inParams.ktUnitsDenom;
            backEMF=inParams.backEMF;

            switch suppliedConstant
            case 'Flux induced by magnets'
                lambdaUnits=inParams.lambdaUnits;
                lambda=inParams.lambda;
                switch lambdaUnits
                case 'V.s'
                    switch backEMF
                    case{'Sinusoidal','sinusoidal'}
                        ktSt=lambda*3*polePairs/2;
                    case{'Trapezoidal','trapezoidal'}
                        ktSt=2*lambda*polePairs;
                    otherwise
                        invalidValueError(backEMF,'backEMF');
                    end
                otherwise
                    invalidValueError(lambdaUnits,'lambdaUnits');
                end


                kt=convertKtStandard2Custom(ktSt,ktUnitsNum,ktUnitsDenom,torqueConstants);

            case 'Voltage constant'


                ke=convertKeCustom2Standard(inParams.ke,inParams.keUnitsNum,...
                inParams.keUnitsDenom);


                switch backEMF
                case{'Sinusoidal','sinusoidal'}
                    ktSt=3*sqrt(3)*ke/(200*pi);
                case{'Trapezoidal','trapezoidal'}
                    ktSt=3*ke/(100*pi);
                otherwise
                    invalidValueError(backEMF,'backEMF');
                end


                kt=convertKtStandard2Custom(ktSt,ktUnitsNum,ktUnitsDenom,torqueConstants);

            case 'Torque constant'

                kt=convertKtCustom2Standard(inParams.kt,ktUnitsNum,ktUnitsDenom,torqueConstants);
                ktSt=kt;

            otherwise
                invalidValueError(suppliedConstant,'suppliedConstant');
            end

            function lambda=computeLambda(suppliedConstant,inParams,torqueConstants)

                polePairs=inParams.p;
                backEMF=inParams.backEMF;
                lambdaUnits=inParams.lambdaUnits;

                if strcmp(lambdaUnits,'V.s')
                    switch suppliedConstant
                    case 'Torque constant'

                        kt=convertKtCustom2Standard(inParams.kt,inParams.ktUnitsNum,...
                        inParams.ktUnitsDenom,torqueConstants);


                        switch backEMF
                        case{'Sinusoidal','sinusoidal'}
                            lambda=2*kt/(3*polePairs);
                        case{'Trapezoidal','trapezoidal'}
                            lambda=kt/(2*polePairs);
                        otherwise
                            invalidValueError(backEMF,'backEMF');
                        end

                    case 'Voltage constant'

                        ke=convertKeCustom2Standard(inParams.ke,inParams.keUnitsNum,...
                        inParams.keUnitsDenom);


                        switch backEMF
                        case{'Sinusoidal','sinusoidal'}
                            lambda=sqrt(3)*ke/(100*pi*polePairs);
                        case{'Trapezoidal','trapezoidal'}
                            lambda=3*ke/(200*pi*polePairs);
                        otherwise
                            invalidValueError(backEMF,'backEMF');
                        end

                    otherwise
                        invalidValueError(suppliedConstant,'suppliedConstant');
                    end
                else

                    invalidUnitsError(lambdaUnits,'lambdaUnits');
                end

                function ke=convertKeStandard2Custom(ke,numUnits,denomUnits)


                    switch numUnits
                    case 'Vrms'
                        ke=ke/sqrt(2);
                    case 'Vpeak'

                    otherwise
                        invalidUnitsError(numUnits,'keUnitsNum');
                    end


                    switch denomUnits
                    case 'rad/s'
                        ke=ke*3/(100*pi);
                    case 'krpm'

                    otherwise
                        invalidValueError(denomUnits,'keUnitsDenom');
                    end

                    function ke=convertKeCustom2Standard(ke,numUnits,denomUnits)


                        switch numUnits
                        case 'Vrms'
                            ke=ke*sqrt(2);
                        case 'Vpeak'

                        otherwise
                            invalidUnitsError(numUnits,'keUnitsNum');
                        end


                        switch denomUnits
                        case 'rad/s'
                            ke=ke*100*pi/3;
                        case 'krpm'

                        otherwise
                            invalidUnitsError(denomUnits,'keUnitsDenom');
                        end

                        function kt=convertKtCustom2Standard(kt,numUnits,denomUnits,torqueConstants)



                            switch numUnits
                            case 'oz.in'
                                kt=kt/torqueConstants.newtonMeter2OunceInch;
                            case 'lb.in'
                                kt=kt/(torqueConstants.newtonMeter2OunceInch/16);
                            case 'lb.ft'
                                kt=kt/(torqueConstants.newtonMeter2OunceInch/(16*12));
                            case 'N.cm'
                                kt=kt/100;
                            case 'N.m'

                            otherwise
                                invalidValueError(numUnits,'ktUnitsNum');
                            end


                            switch denomUnits
                            case 'Arms'
                                kt=kt/sqrt(2);
                            case 'Apeak'

                            otherwise
                                invalidValueError(denomUnits,'ktUnitsDenom');
                            end

                            function kt=convertKtStandard2Custom(kt,numUnits,denomUnits,torqueConstants)



                                switch numUnits
                                case 'oz.in'
                                    kt=kt*torqueConstants.newtonMeter2OunceInch;
                                case 'lb.in'
                                    kt=kt*torqueConstants.newtonMeter2OunceInch/16;
                                case 'lb.ft'
                                    kt=kt*torqueConstants.newtonMeter2OunceInch/(16*12);
                                case 'N.cm'
                                    kt=kt*100;
                                case 'N.m'

                                otherwise
                                    invalidUnitsError(numUnits,'ktUnitsNum');
                                end


                                switch denomUnits
                                case 'Arms'
                                    kt=kt*sqrt(2);
                                case 'Apeak'

                                otherwise
                                    invalidUnitsError(denomUnits,'ktUnitsDenom');
                                end

                                function[]=invalidValueError(value,field)

                                    msg=['Invalid value ''',value,''' for field ''',field,''' in input ',...
                                    'structure.'];
                                    myErrorFcn(msg);

                                    function[]=invalidUnitsError(value,field)

                                        msg=['Invalid units ''',value,''' for field ''',field,''' in input ',...
                                        'structure.'];
                                        myErrorFcn(msg);

                                        function[]=myErrorFcn(msg)
                                            msgId='SpecializedPowerSystems:PowerPMSynchronousMachineConstants:InvalidInputParam';
                                            error(msgId,msg);

                                            function[]=validatePositiveNumeric(value,field)

                                                isValid=0;
                                                isInputEmpty=isempty(value);
                                                isInputNumeric=isnumeric(value);
                                                if(~isInputEmpty&&isInputNumeric)
                                                    if(value>0)
                                                        isValid=1;
                                                    end
                                                end

                                                if~isValid
                                                    if isInputNumeric
                                                        value=num2str(value);
                                                    end
                                                    msg=['Invalid value ''',value,''' for input field ''',field,...
                                                    ''', which must be a positive numeric value.'];
                                                    myErrorFcn(msg);
                                                end

                                                function[]=validatePositiveOrZeroNumeric(value,field)

                                                    isValid=0;
                                                    isInputEmpty=isempty(value);
                                                    isInputNumeric=isnumeric(value);
                                                    if(~isInputEmpty&&isInputNumeric)
                                                        if(value>=0)
                                                            isValid=1;
                                                        end
                                                    end

                                                    if~isValid
                                                        if isInputNumeric
                                                            value=num2str(value);
                                                        end
                                                        msg=['Invalid value ''',value,''' for input field ''',field,...
                                                        ''', which must be zero or a positive numeric value.'];
                                                        myErrorFcn(msg);
                                                    end
