function varargout=SetInternalModels(M,block,varargin)








    switch M
    case 'set'
        WantBlockChoice=varargin{1};
        WantBlockChoice=cellstr(WantBlockChoice);
        L=length(WantBlockChoice);
        switch L
        case 1
            InternalModel={'Model'};
            if length(varargin)==2
                L=varargin{2};
                InternalModel={'Model1','Model2','Model3'};
                WantBlockChoice=[WantBlockChoice,WantBlockChoice,WantBlockChoice];
            end
        case 2
            InternalModel={'Electrical model','Mechanical model'};
        case 3
            InternalModel={'Electrical model','Mechanical model','Measurements'};
        case 4

            InternalModel={'Diode Rsh','I Filter','V Filter'};
            L=3;
        end
        for i=1:L
            SimulinkModel=[block,'/',InternalModel{i}];
            switch get_param(SimulinkModel,'Variant')
            case 'on'

                if~isequal(get_param(SimulinkModel,'LabelModeActiveChoice'),WantBlockChoice{i})
                    switch get_param(bdroot(SimulinkModel),'SimulationStatus')
                    case 'initializing'


                    otherwise
                        set_param(SimulinkModel,'LabelModeActiveChoice',WantBlockChoice{i});
                    end
                end
            otherwise
                BC=get_param(SimulinkModel,'BlockChoice');
                if isempty(BC)

                    RB=get_param(SimulinkModel,'Referenceblock');
                    if~isempty(RB)&&~isequal(RB(find(RB=='/')+1:end),WantBlockChoice{i})
                        RB=[RB(1:(find(RB=='/'))),WantBlockChoice{i}];



                        try
                            warning_state=warning('off','Simulink:Commands:ParamUnknown');
                            set_param(SimulinkModel,'Referenceblock',RB);
                        catch ex
                            warning(warning_state);
                            rethrow(ex)
                        end
                        warning(warning_state);

                        set_param(SimulinkModel,'LinkStatus','restore');
                    end
                elseif~isequal(BC,WantBlockChoice{i})

                    set_param(SimulinkModel,'BlockChoice',WantBlockChoice{i});
                end
            end
        end

        return

    end




    [MaskType,PowerguiInfo]=varargin{1:2};


    Ts=PowerguiInfo.Ts;


    if PowerguiInfo.Continuous
        WantBlockChoice{1}='Continuous';
    end
    if PowerguiInfo.Discrete
        WantBlockChoice{1}='Discrete';
    end
    if PowerguiInfo.Phasor
        WantBlockChoice{1}='Phasor';
    end
    if PowerguiInfo.DiscretePhasor
        WantBlockChoice{1}='Discrete phasor';
    end



    [TsPowergui,TsBlock]=varargin{3:4};
    if TsPowergui~=0



        Ts=TsPowergui;
        PowerguiInfo.Discrete=1;
        PowerguiInfo.Continuous=0;
        PowerguiInfo.Phasor=0;

        WantBlockChoice{1}='Discrete';
    end
    if TsBlock~=-1

        Ts=TsBlock;
        PowerguiInfo.Discrete=1;
        PowerguiInfo.Continuous=0;
        PowerguiInfo.Phasor=0;

        WantBlockChoice{1}='Discrete';
    end



    if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
        switch MaskType
        case{'Permanent Magnet Synchronous Machine','Single Phase Asynchronous Machine','Stepper Motor','Switched Reluctance Motor','DC Machine'}

            WantBlockChoice{1}='Continuous';
        end
    end



    switch MaskType
    case 'Stepper Motor'
        [MotorType,Phases]=varargin{5:6};
        switch MotorType
        case 'Permanent-magnet / Hybrid'
            WantBlockChoice{1}=[WantBlockChoice{1},' ',num2str(Phases),' phases Hybrid'];
        case 'Variable reluctance'
            WantBlockChoice{1}=[WantBlockChoice{1},' ',num2str(Phases),' phases reluctance'];
        end
    case 'DC Machine'
        MechanicalLoad=varargin{5};
        if isequal(MechanicalLoad,'Torque TL')
            WantBlockChoice{1}=[WantBlockChoice{1},' TL input'];
        elseif isequal(MechanicalLoad,'Speed w')
            WantBlockChoice{1}=[WantBlockChoice{1},' w input'];
        else
            WantBlockChoice{1}=[WantBlockChoice{1},' Shaft input'];
        end

        FieldType=varargin{6};
        if isequal(FieldType,'Permanent magnet')
            WantBlockChoice{1}=[WantBlockChoice{1},' PMagnet'];
        end
    case 'Asynchronous Machine'
        switch varargin{7}
        case 'Double squirrel-cage'
            WantBlockChoice{1}=[WantBlockChoice{1},' double-cage'];
        end
    end



    switch MaskType
    case{'Permanent Magnet Synchronous Machine'}
        if strcmp(get_param(block,'MechanicalLoad'),'Mechanical rotational port')
            WantShaft=WantBlockChoice{1};
        end
        MeasurementBus=varargin{6};
        if strcmp(get_param(block,'FluxDistribution'),'Trapezoidal')&&strcmp(get_param(block,'NbPhases'),'3')
            WantBlockChoice{1}=[WantBlockChoice{1},' Trapezoidal'];
            if MeasurementBus
                WantBlockChoice{3}='uniform trapezoidal';
            else
                WantBlockChoice{3}='Trapezoidal Measurement';
            end
        else
            if MeasurementBus
                WantBlockChoice{3}='uniform';
            else
                WantBlockChoice{3}='Measurement';
            end
        end

        if strcmp(get_param(block,'NbPhases'),'5')
            WantBlockChoice{1}=[WantBlockChoice{1},' 5 phases'];
            if MeasurementBus
                WantBlockChoice{3}='uniform 5 phases';
            else
                WantBlockChoice{3}='Measurement 5 phases';
            end
        end

    end



    switch MaskType
    case{'Simplified Synchronous Machine','Synchronous Machine','Asynchronous Machine','Permanent Magnet Synchronous Machine','Single Phase Asynchronous Machine'}

        if(strcmp(MaskType,'Asynchronous Machine'))
            if(strcmp(varargin{7},'Double squirrel-cage'))
                if PowerguiInfo.Discrete
                    WantBlockChoice{2}='Discrete';
                elseif PowerguiInfo.Continuous
                    WantBlockChoice{2}='Continuous';
                else
                    WantBlockChoice{2}='Phasor';
                end
            else

                WantBlockChoice{2}=WantBlockChoice{1};
            end
        else

            WantBlockChoice{2}=WantBlockChoice{1};
        end


        MechanicalLoad=varargin{5};
        switch MechanicalLoad
        case 'Mechanical power Pm'
            WantBlockChoice{2}=[WantBlockChoice{2},' Pm input'];
        case 'Torque Tm'
            WantBlockChoice{2}=[WantBlockChoice{2},' Tm input'];
        case 'Mechanical rotational port'
            switch MaskType


            case 'Permanent Magnet Synchronous Machine'
                WantBlockChoice{2}=[WantShaft,' Shaft input'];
            case 'Asynchronous Machine'
                if PowerguiInfo.Phasor
                    WantBlockChoice{2}='Phasor Shaft input';
                else
                    WantBlockChoice{2}='Shaft input';
                end

            otherwise
                WantBlockChoice{2}='Shaft input';
            end

        otherwise
            WantBlockChoice{2}=[WantBlockChoice{2},' w input'];
        end
    end


    if PowerguiInfo.Discrete
        switch MaskType
        case 'Asynchronous Machine'
            switch varargin{7}
            case{'Wound','Squirrel-cage'}
                ModelSolver=varargin{6};
                switch ModelSolver
                case 'Trapezoidal non iterative'
                    WantBlockChoice{1}=[WantBlockChoice{1},' Trapezoidal'];
                    switch MechanicalLoad
                    case 'Torque Tm'
                        WantBlockChoice{2}=[WantBlockChoice{2},' Trapezoidal'];
                    end
                case 'Trapezoidal iterative (alg. loop)'
                    WantBlockChoice{1}=[WantBlockChoice{1},' Trapezoidal'];
                    switch MechanicalLoad
                    case 'Torque Tm'
                        WantBlockChoice{2}=[WantBlockChoice{2},' Trapezoidal'];
                    case 'Mechanical rotational port'
                        WantBlockChoice{2}=[WantBlockChoice{2},' BAL'];
                    end
                case 'Forward Euler'
                    switch MechanicalLoad
                    case 'Mechanical rotational port'
                        WantBlockChoice{2}=[WantBlockChoice{2},' BAL'];
                    end
                end
            otherwise
                switch MechanicalLoad
                case 'Mechanical rotational port'
                    WantBlockChoice{2}=[WantBlockChoice{2},' BAL'];
                end
            end
        case 'Synchronous Machine'
            ModelSolver=varargin{6};
            switch ModelSolver
            case 'Trapezoidal non iterative'
                WantBlockChoice{1}=[WantBlockChoice{1},' Trapezoidal'];
                switch MechanicalLoad
                case 'Mechanical power Pm'
                    WantBlockChoice{2}=[WantBlockChoice{2},' Trapezoidal'];
                end
            case 'Trapezoidal iterative (alg. loop)'
                WantBlockChoice{1}=[WantBlockChoice{1},' Trapezoidal'];
                switch MechanicalLoad
                case 'Mechanical power Pm'
                    WantBlockChoice{2}=[WantBlockChoice{2},' Trapezoidal'];
                case 'Mechanical rotational port'
                    WantBlockChoice{2}=[WantBlockChoice{2},' BAL'];
                end
            case 'Forward Euler'
                switch MechanicalLoad
                case 'Mechanical rotational port'
                    WantBlockChoice{2}=[WantBlockChoice{2},' BAL'];
                end
            end
        end
    end


    switch MaskType

    case 'Asynchronous Machine'

        RotorType=varargin{7};
        Units=varargin{8};
        MeasurementBus=varargin{9};

        switch RotorType
        case 'Double squirrel-cage'
            WantBlockChoice{3}='Double-cage ';
        otherwise
            WantBlockChoice{3}='Single-cage ';
        end

        if MeasurementBus
            WantBlockChoice{3}=[WantBlockChoice{3},'uniform'];
        else
            WantBlockChoice{3}=[WantBlockChoice{3},Units];
        end

    case{'Simplified Synchronous Machine','Synchronous Machine'}

        MeasurementBus=varargin{7};

        if MeasurementBus
            WantBlockChoice{3}='uniform';
        else
            switch varargin{8}
            case{'SI','SI fundamental parameters'}
                WantBlockChoice{3}='Measurement SI';
            case 'per unit fundamental parameters'
                WantBlockChoice{3}='Measurement puf';
            otherwise
                WantBlockChoice{3}='Measurement pu';
            end
        end

    case 'Single Phase Asynchronous Machine'

        MeasurementBus=varargin{6};

        if MeasurementBus
            WantBlockChoice{3}='uniform';
        else
            WantBlockChoice{3}='detailed';
        end

    case 'DC Machine'

        MeasurementBus=varargin{7};

        if MeasurementBus
            WantBlockChoice{2}='uniform';
        else
            WantBlockChoice{2}='Measurement list';
        end

    end

    varargout={WantBlockChoice,Ts};
