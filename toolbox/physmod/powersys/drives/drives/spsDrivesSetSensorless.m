function[]=spsDrivesSetSensorless(block,driveType,sensorless);%#ok





    switch driveType

    case 'AC3'

        if strcmp(sensorless,'on')
            WRB='spsDrivesEstimatorBlock/MRAS speed estimator';
            set_param([block,'/Induction machine'],'IterativeModel','Forward Euler')
            set_param(block,'IterativeDiscreteModel',get_param([block,'/Induction machine'],'IterativeModel'));
        else
            WRB='spsDrivesEstimatorBlock/MRAS no speed estimator';
            set_param([block,'/Induction machine'],'IterativeModel','Trapezoidal non iterative')
            set_param(block,'IterativeDiscreteModel',get_param([block,'/Induction machine'],'IterativeModel'));
        end

        if~isequal(WRB,get_param([block,'/Sensor mode'],'Referenceblock'))






            warning_state=warning('off','Simulink:Commands:ParamUnknown');
            set_param([block,'/Sensor mode'],'Referenceblock',WRB);
            warning(warning_state);

        end

    case 'AC7'

        if strcmp(sensorless,'on')
            WRB='spsDrivesEstimatorBlock/Speed and Commutation signals estimation';
        else
            WRB='spsDrivesEstimatorBlock/no speed estimator';
        end

        if~isequal(WRB,get_param([block,'/Sensor mode'],'Referenceblock'))






            warning_state=warning('off','Simulink:Commands:ParamUnknown');
            set_param([block,'/Sensor mode'],'Referenceblock',WRB);
            warning(warning_state);

        end

    end