classdef powergui_class<ConvClass&handle


    properties

        OldParam=struct(...
        'SampleTime',[],...
        'frequency',[],...
        'Iterations',[],...
        'frequencyindice',[],...
        'Pbase',[],...
        'ErrMax',[],...
        'buscounter',[],...
        'Ts',[],...
        'SwTol',[],...
        'Frange',[],...
        'variable',[],...
        'structure',[],...
        'StartTime',[],...
        'cycles',[],...
        'DisplayStyle',[],...
        'fundamental',[],...
        'MaxFrequency',[],...
        'frequencyindicesteady',[],...
        'RmsSteady',[]...
        )


        OldDropdown=struct(...
        'SimulationMode',[],...
        'UnitsV',[],...
        'UnitsW',[],...
        'SolverType',[],...
        'x0status',[],...
        'RestoreLinks',[],...
        'FunctionMessages',[],...
        'echomessages',[],...
        'EnableUseOfTLC',[],...
        'CurrentSourceSwitches',[],...
        'DisableSnubberDevices',[],...
        'DisableRonSwitches',[],...
        'DisableVfSwitches',[],...
        'DisplayEquations',[],...
        'Interpol',[],...
        'ExternalGateDelay',[],...
        'methode',[],...
        'SPID',[],...
        'HookPort',[],...
        'ResistiveCurrentMeasurement',[],...
        'Ylog',[],...
        'Xlog',[],...
        'ShowGrid',[],...
        'save',[],...
        'ZoomFFT',[],...
        'FreqAxis',[],...
        'display',[]...
        )


        NewDirectParam=struct(...
        'LocalSolverSampleTime',[]...
        )


        NewDerivedParam=struct(...
        )


        NewDropdown=struct(...
        'LocalSolverChoice',[]...
        )


        BlockOption={...
        };

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/powergui'
        NewPath='elec_conv_sl_powergui/powergui'
    end

    methods
        function obj=objParamMappingDirect(obj)

            if strcmp(obj.OldDropdown.SimulationMode,'Discrete')
                if ischar(obj.OldParam.SampleTime)
                    obj.NewDirectParam.LocalSolverSampleTime=obj.OldParam.SampleTime;
                else
                    if obj.OldParam.SampleTime~=0
                        obj.NewDirectParam.LocalSolverSampleTime=obj.OldParam.SampleTime;
                    else
                        obj.NewDirectParam.LocalSolverSampleTime=1e-4;
                    end
                end
            end

        end


        function obj=objParamMappingDerived(obj)
        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            if strcmp(obj.OldDropdown.SimulationMode,'Continuous')&&strcmp(obj.OldDropdown.CurrentSourceSwitches,'off')

                logObj.addMessage(obj,'OptionNotSupported','Preference','Ideal switching mode');

                if strcmp(obj.OldDropdown.DisableSnubberDevices,'on')
                    logObj.addMessage(obj,'OptionNotSupported','Preference','Disable snubbers in switching devices');
                    logObj.addMessage(obj,'CustomMessage','Parameters in switching devices need to be reviewed carefully.');
                end

                if strcmp(obj.OldDropdown.DisableRonSwitches,'on')
                    logObj.addMessage(obj,'OptionNotSupported','Preference','Disable Ron resistances in switching devices');
                    logObj.addMessage(obj,'CustomMessage','Parameters in switching devices need to be reviewed carefully.');
                end

                if strcmp(obj.OldDropdown.DisableVfSwitches,'on')
                    logObj.addMessage(obj,'OptionNotSupported','Preference','Disable forward voltages in switching devices');
                    logObj.addMessage(obj,'CustomMessage','Parameters in switching devices need to be reviewed carefully.');
                end

            end

            if strcmp(obj.OldDropdown.SimulationMode,'Discrete')
                switch obj.OldDropdown.SolverType
                case 'Tustin/Backward Euler (TBE)'
                    obj.NewDropdown.LocalSolverChoice='NE_BACKWARD_EULER_ADVANCER';
                    logObj.addMessage(obj,'OptionNotSupported','Discrete solver','Tustin/Backward Euler (TBE)');
                    logObj.addMessage(obj,'CustomMessage','Local solver type is set to be Backward Euler.');
                case 'Tustin'
                    obj.NewDropdown.LocalSolverChoice='NE_TRAPEZOIDAL_ADVANCER';
                    if strcmp(obj.OldDropdown.Interpol,'on')
                        logObj.addMessage(obj,'OptionNotSupported','Discrete solver','Interpolate switching events');
                    end
                    if strcmp(obj.OldDropdown.ExternalGateDelay,'on')
                        logObj.addMessage(obj,'OptionNotSupported','Discrete solver','Use time-stamped gate signals');
                    end
                otherwise
                    obj.NewDropdown.LocalSolverChoice='NE_BACKWARD_EULER_ADVANCER';
                end
            end

        end

        function obj=iFinalLoadFcn(obj)

            blockName=obj.OldBlockName;
            switch obj.OldDropdown.SimulationMode
            case 'Continuous'
                set_param(blockName,'UseLocalSolver','off');
                if strcmp(get_param(blockName,'LocalSolverSampleTime'),'0')
                    set_param(blockName,'LocalSolverSampleTime','1e-5');
                end
            case 'Discrete'
                set_param(blockName,'UseLocalSolver','on');
                set_param(blockName,'DoFixedCost','on');
                set_param(blockName,'MaxNonlinIter','4');
            case 'Phasor'
                fprintf('FIXME: %s: iFinalLoadFcn: phasor\n',mfilename);
            otherwise
            end








        end
    end

end

