function varargout=powergui(varargin)











    switch nargin

    case 2

        PowerguiBlock=varargin{1};

        islicensed=power_initmask(PowerguiBlock);

        if islicensed==0

            beep;
            Erreur.message='Unable to check out a Simscape Electrical license.  Check installation and license';
            Erreur.identifier='SpecializedPowerSystems:CheckLicense:UnckeckedLicense';
            psberror(Erreur.message,Erreur.identifier,'NoUiwait');
            return
        end

        RootSystem=bdroot(PowerguiBlock);
        if strcmp(RootSystem,'powerlib')
            open_system(PowerguiBlock,'mask');
            return
        end

        [GUI_is_already_open,~,handles]=InitializePowerguiTools(nargout,{RootSystem,PowerguiBlock},'powergui',mfilename);
        if GUI_is_already_open
            if nargout==1
                varargout{1}=handles.Data;
            end
            return
        end


        set(handles.figure1,'name',PowerguiBlock);


        kids=get(handles.figure1,'children');
        set(kids,'BackgroundColor',get(handles.figure1,'DefaultUIcontrolBackgroundColor'));
        set(findobj(kids,'Style','Edit'),'BackgroundColor',[1,1,1]);

        kids=get(handles.uipanel3,'children');
        set(kids,'BackgroundColor',get(handles.figure1,'DefaultUIcontrolBackgroundColor'));

    otherwise

        if ischar(varargin{1})
            try
                [varargout{1:nargout}]=feval(varargin{:});
            catch err
                warning(err.identifier,'%s',err.message);
            end
        end

    end

    function varargout=InitFcn_Callback(block,eventdata,handles,varargin)%#ok

        [~,NoCompilation]=powersysdomain_netlist('get');
        if NoCompilation

            return
        end
        PowerguiBlocks=get_param(block,'blocks');
        NbBlocks=length(PowerguiBlocks);

        if NbBlocks>2

            Dirty=get_param(bdroot(block),'Dirty');

            for m=1:NbBlocks
                if strncmp(PowerguiBlocks{m},'EquivalentModel',15)
                    delete_block([block,'/',PowerguiBlocks{m}]);
                end
            end
            set_param(bdroot(block),'Dirty',Dirty);
        end

        function varargout=MaskInitialization(block,SimulationMode,SampleTime)

            set_param(block,'UserDataPersistent','off');
            sys=bdroot(block);

            if strcmp(sys,'powerlib')

                message='powergui';

            else


                WS=get_param(sys,'FileName');
                switch WS
                case{'','new Simulink model'}

                otherwise
                    [~,resolved]=sls_resolvename(sys);
                    if resolved
                        RN=Simulink.MDLInfo(WS).ReleaseName;
                        if str2double(RN(2:5))<2017
                            if SimulationMode==1
                                switch get_param(block,'SPID')
                                case 'off'


                                    if strcmp(get_param(bdroot(block),'dirty'),'off')


                                        set_param(block,'CurrentSourceSwitches','on')
                                    end
                                end
                            end
                        end
                    end
                end

                switch SimulationMode
                case 1
                    message=sprintf('Continuous');
                case 2
                    if isempty(SampleTime)
                        message=sprintf('Discrete\n%s s.',get_param(block,'Sampletime'));
                    else
                        message=sprintf('Discrete\n%.4g s.',SampleTime);
                    end
                case 3
                    message=sprintf('Phasor\n%s Hz',get_param(block,'frequency'));
                case 4
                    if isempty(SampleTime)
                        message=sprintf('Discrete phasor\n%s Hz %s s.',get_param(block,'frequency'),get_param(block,'Sampletime'));
                    else
                        message=sprintf('Discrete phasor\n%s Hz %.4g s.',get_param(block,'frequency'),SampleTime);
                    end
                end

            end

            varargout{1}=message;
            power_initmask();

            function varargout=PreSaveFcn_Callback(block,eventdata,handles,varargin)%#ok

                if isequal('inactive',get_param(block,'LinkStatus'))
                    set_param(block,'LinkStatus','restore')
                end

                function varargout=SimulationType(h,eventdata,block)%#ok

                    aMaskObj=Simulink.Mask.get(block);
                    SOLVER=aMaskObj.getDialogControl('Solver');
                    SOLVERDETAILS=aMaskObj.getDialogControl('SolverDetails');

                    SampleTime=strcmp(get_param(block,'MaskNames'),'SampleTime')==1;
                    PhasorFrequency=strcmp(get_param(block,'MaskNames'),'frequency')==1;
                    EnableTLC=strcmp(get_param(block,'MaskNames'),'EnableUseOfTLC')==1;
                    CurrentSourceSwitch=strcmp(get_param(block,'MaskNames'),'CurrentSourceSwitches')==1;
                    DisableSnubbers=strcmp(get_param(block,'MaskNames'),'DisableSnubberDevices')==1;
                    DisableRon=strcmp(get_param(block,'MaskNames'),'DisableRonSwitches')==1;
                    DisableVf=strcmp(get_param(block,'MaskNames'),'DisableVfSwitches')==1;
                    DisableEqns=strcmp(get_param(block,'MaskNames'),'DisplayEquations')==1;
                    AutomaticSolver=strcmp(get_param(block,'MaskNames'),'AutomaticDiscreteSolvers')==1;
                    SolverType=strcmp(get_param(block,'MaskNames'),'SolverType')==1;
                    Interpol=strcmp(get_param(block,'MaskNames'),'Interpol')==1;
                    ExternalGates=strcmp(get_param(block,'MaskNames'),'ExternalGateDelay')==1;
                    StoreTopologies=strcmp(get_param(block,'MaskNames'),'methode')==1;
                    BufferSize=strcmp(get_param(block,'MaskNames'),'Ts')==1;
                    StartWithInitstates=strcmp(get_param(block,'MaskNames'),'x0status')==1;

                    Parameters=Simulink.Mask.get(block).Parameters;

                    switch get_param(block,'SimulationMode')

                    case 'Continuous'

                        SetTheMeasurementOutputSignalType(block,'off');

                        Parameters(SampleTime).Visible='off';
                        Parameters(PhasorFrequency).Visible='off';
                        Parameters(EnableTLC).Visible='off';
                        Parameters(CurrentSourceSwitch).Visible='on';

                        switch get_param(block,'currentSourceSwitches')
                        case 'on'
                            Parameters(DisableSnubbers).Visible='off';
                            Parameters(DisableRon).Visible='off';
                            Parameters(DisableVf).Visible='off';
                            Parameters(DisableEqns).Visible='off';
                        case 'off'
                            Parameters(DisableSnubbers).Visible='on';
                            Parameters(DisableRon).Visible='on';
                            Parameters(DisableVf).Visible='on';
                            Parameters(DisableEqns).Visible='on';
                        end

                        Parameters(AutomaticSolver).Visible='off';
                        Parameters(SolverType).Visible='off';
                        Parameters(Interpol).Visible='off';
                        Parameters(ExternalGates).Visible='off';
                        Parameters(StoreTopologies).Visible='on';

                        switch get_param(block,'methode')
                        case 'on'
                            Parameters(BufferSize).Visible='on';
                        otherwise
                            Parameters(BufferSize).Visible='off';
                        end

                        Parameters(StartWithInitstates).Visible='on';

                        SOLVER.Visible='on';
                        SOLVERDETAILS.Visible='off';

                    case 'Discrete'

                        SetTheMeasurementOutputSignalType(block,'off');

                        Parameters(SampleTime).Visible='on';
                        Parameters(PhasorFrequency).Visible='off';
                        Parameters(EnableTLC).Visible='on';
                        Parameters(CurrentSourceSwitch).Visible='off';
                        Parameters(DisableSnubbers).Visible='off';
                        Parameters(DisableRon).Visible='off';
                        Parameters(DisableVf).Visible='off';
                        Parameters(DisableEqns).Visible='off';
                        Parameters(AutomaticSolver).Visible='on';

                        switch get_param(block,'automaticDiscreteSolvers')
                        case 'off'
                            Parameters(SolverType).Visible='on';

                            switch get_param(block,'SolverType')
                            case 'Tustin'
                                Parameters(Interpol).Visible='on';
                                switch get_param(block,'Interpol')
                                case 'on'
                                    Parameters(ExternalGates).Visible='on';
                                otherwise
                                    Parameters(ExternalGates).Visible='off';
                                end
                            otherwise
                                Parameters(Interpol).Visible='off';
                                Parameters(ExternalGates).Visible='off';
                            end

                            Parameters(StoreTopologies).Visible='on';

                            switch get_param(block,'methode')
                            case 'on'
                                Parameters(BufferSize).Visible='on';
                            otherwise
                                Parameters(BufferSize).Visible='off';
                            end

                            Parameters(StartWithInitstates).Visible='on';

                        case 'on'
                            Parameters(SolverType).Visible='off';
                            Parameters(Interpol).Visible='off';
                            Parameters(ExternalGates).Visible='off';
                            Parameters(StoreTopologies).Visible='off';
                            Parameters(BufferSize).Visible='off';
                            Parameters(StartWithInitstates).Visible='off';

                        end

                        SOLVER.Visible='on';
                        SOLVERDETAILS.Visible='on';

                    case 'Phasor'

                        SetTheMeasurementOutputSignalType(block,'on');

                        Parameters(SampleTime).Visible='off';
                        Parameters(PhasorFrequency).Visible='on';
                        Parameters(EnableTLC).Visible='off';
                        Parameters(CurrentSourceSwitch).Visible='off';
                        Parameters(DisableSnubbers).Visible='off';
                        Parameters(DisableRon).Visible='off';
                        Parameters(DisableVf).Visible='off';
                        Parameters(DisableEqns).Visible='off';
                        Parameters(AutomaticSolver).Visible='off';
                        Parameters(SolverType).Visible='off';
                        Parameters(Interpol).Visible='off';
                        Parameters(ExternalGates).Visible='off';
                        Parameters(StoreTopologies).Visible='off';
                        Parameters(BufferSize).Visible='off';
                        Parameters(StartWithInitstates).Visible='off';

                        SOLVER.Visible='off';
                        SOLVERDETAILS.Visible='off';

                    case 'Discrete phasor'

                        SetTheMeasurementOutputSignalType(block,'on');

                        Parameters(SampleTime).Visible='on';
                        Parameters(PhasorFrequency).Visible='on';
                        Parameters(EnableTLC).Visible='off';
                        Parameters(CurrentSourceSwitch).Visible='off';
                        Parameters(DisableSnubbers).Visible='off';
                        Parameters(DisableRon).Visible='off';
                        Parameters(DisableVf).Visible='off';
                        Parameters(DisableEqns).Visible='off';
                        Parameters(AutomaticSolver).Visible='off';
                        Parameters(SolverType).Visible='off';
                        Parameters(Interpol).Visible='off';
                        Parameters(ExternalGates).Visible='off';
                        Parameters(StoreTopologies).Visible='off';
                        Parameters(BufferSize).Visible='off';
                        Parameters(StartWithInitstates).Visible='off';

                        SOLVER.Visible='off';
                        SOLVERDETAILS.Visible='off';

                    end

                    function SetTheMeasurementOutputSignalType(PowerguiBlock,NewStatus)


                        sys=get_param(PowerguiBlock,'Parent');


                        ThreePhaseMeasurements=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','MaskType','Three-Phase VI Measurement');
                        if~isempty(ThreePhaseMeasurements)&&~strcmp(get_param(bdroot(PowerguiBlock),'EditingMode'),'Restricted')
                            for i=1:length(ThreePhaseMeasurements)
                                set_param(ThreePhaseMeasurements{i},'PhasorSimulation',NewStatus);
                                EnabledParameters=get_param(ThreePhaseMeasurements{i},'MaskEnables');
                                EnabledParameters{12}=NewStatus;
                                set_param(ThreePhaseMeasurements{i},'MaskEnables',EnabledParameters);
                            end
                        end


                        CurrentMeasurements=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','on','MaskType','Current Measurement');
                        if~isempty(CurrentMeasurements)&&~strcmp(get_param(bdroot(PowerguiBlock),'EditingMode'),'Restricted')
                            for i=1:length(CurrentMeasurements)
                                set_param(CurrentMeasurements{i},'PhasorSimulation',NewStatus);
                            end
                        end


                        VoltageMeasurements=find_system(sys,'LookUnderMasks','on',...
                        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                        'MaskType','Voltage Measurement');
                        if~isempty(VoltageMeasurements)&&~strcmp(get_param(bdroot(PowerguiBlock),'EditingMode'),'Restricted')
                            for i=1:length(VoltageMeasurements)
                                set_param(VoltageMeasurements{i},'PhasorSimulation',NewStatus);
                            end
                        end
