classdef Three_PhaseBreaker_class<ConvClass&handle



    properties

        OldParam=struct(...
        'SwitchTimes',[],...
        'BreakerResistance',[],...
        'SnubberResistance',[],...
        'SnubberCapacitance',[]...
        )


        OldDropdown=struct(...
        'InitialState',[],...
        'Measurements',[],...
        'SwitchA',[],...
        'SwitchB',[],...
        'SwitchC',[],...
        'External',[]...
        )


        NewDirectParam=struct(...
        'R_closed',[]...
        )


        NewDerivedParam=struct(...
        'G_open',[],...
        'InitialOnOff',[],...
        'StepInitialValue',[],...
        'switchTime1',[],...
        'switchTime2',[],...
        'switchTime3',[],...
        'switchTime4',[],...
        'switchTime5',[]...
        )


        NewDropdown=struct(...
        'LogicalSelection',[]...
        )


        BlockOption={...
        {'SwitchA','off';'SwitchB','off';'SwitchC','off';'External','off'},'ExOff';...
        {'SwitchA','on';'SwitchB','on';'SwitchC','on';'External','off'},'ExOffABC';...
        {'SwitchA','on';'SwitchB','off';'SwitchC','off';'External','off'},'ExOffA';...
        {'SwitchA','off';'SwitchB','on';'SwitchC','off';'External','off'},'ExOffB';...
        {'SwitchA','off';'SwitchB','off';'SwitchC','on';'External','off'},'ExOffC';...
        {'SwitchA','on';'SwitchB','on';'SwitchC','off';'External','off'},'ExOffAB';...
        {'SwitchA','off';'SwitchB','on';'SwitchC','on';'External','off'},'ExOffBC';...
        {'SwitchA','on';'SwitchB','off';'SwitchC','on';'External','off'},'ExOffCA';...

        {'SwitchA','off';'SwitchB','off';'SwitchC','off';'External','on'},'ExOn';...
        {'SwitchA','on';'SwitchB','on';'SwitchC','on';'External','on'},'ExOnABC';...
        {'SwitchA','on';'SwitchB','off';'SwitchC','off';'External','on'},'ExOnA';...
        {'SwitchA','off';'SwitchB','on';'SwitchC','off';'External','on'},'ExOnB';...
        {'SwitchA','off';'SwitchB','off';'SwitchC','on';'External','on'},'ExOnC';...
        {'SwitchA','on';'SwitchB','on';'SwitchC','off';'External','on'},'ExOnAB';...
        {'SwitchA','off';'SwitchB','on';'SwitchC','on';'External','on'},'ExOnBC';...
        {'SwitchA','on';'SwitchB','off';'SwitchC','on';'External','on'},'ExOnCA';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Breaker'
        NewPath='elec_conv_Three_PhaseBreaker/Three_PhaseBreaker'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.R_closed=obj.OldParam.BreakerResistance;
        end


        function obj=Three_PhaseBreaker_class(InitialState,SnubberResistance,SnubberCapacitance,SwitchTimes,External)
            if nargin>0
                obj.OldDropdown.InitialState=InitialState;
                obj.OldParam.SnubberResistance=SnubberResistance;
                obj.OldParam.SnubberCapacitance=SnubberCapacitance;
                obj.OldParam.SwitchTimes=SwitchTimes;
                obj.OldDropdown.External=External;
            end
        end

        function obj=objParamMappingDerived(obj)


            if strcmp(obj.OldDropdown.InitialState,'open')
                obj.NewDerivedParam.InitialOnOff=1;
            else
                obj.NewDerivedParam.InitialOnOff=0;
            end

            if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                obj.NewDerivedParam.G_open=1e-6;
            elseif obj.OldParam.SnubberCapacitance==inf
                obj.NewDerivedParam.G_open=max(1/obj.OldParam.SnubberResistance,1e-6);
            else
                obj.NewDerivedParam.G_open=1e-6;
            end

            if strcmp(obj.OldDropdown.External,'on')
                if strcmp(obj.OldDropdown.InitialState,'open')
                    obj.NewDerivedParam.StepInitialValue=0;
                else
                    obj.NewDerivedParam.StepInitialValue=1;
                end
            end

            nTime=numel(obj.OldParam.SwitchTimes);
            switch nTime
            case 1
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchTimes(1);
                obj.NewDerivedParam.switchTime2=1e4;
                obj.NewDerivedParam.switchTime3=1e4;
                obj.NewDerivedParam.switchTime4=1e4;
                obj.NewDerivedParam.switchTime5=1e4;
            case 2
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchTimes(2);
                obj.NewDerivedParam.switchTime3=1e4;
                obj.NewDerivedParam.switchTime4=1e4;
                obj.NewDerivedParam.switchTime5=1e4;
            case 3
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchTimes(2);
                obj.NewDerivedParam.switchTime3=obj.OldParam.SwitchTimes(3);
                obj.NewDerivedParam.switchTime4=1e4;
                obj.NewDerivedParam.switchTime5=1e4;
            case 4
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchTimes(2);
                obj.NewDerivedParam.switchTime3=obj.OldParam.SwitchTimes(3);
                obj.NewDerivedParam.switchTime4=obj.OldParam.SwitchTimes(4);
                obj.NewDerivedParam.switchTime5=1e4;
            otherwise
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchTimes(2);
                obj.NewDerivedParam.switchTime3=obj.OldParam.SwitchTimes(3);
                obj.NewDerivedParam.switchTime4=obj.OldParam.SwitchTimes(4);
                obj.NewDerivedParam.switchTime5=obj.OldParam.SwitchTimes(5);
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();

            switch obj.OldDropdown.Measurements
            case 'Breaker voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Breaker voltages');
            case 'Breaker currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Breaker currents');
            case 'Breaker voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Breaker voltages and currents');
            otherwise

            end

            if ischar(obj.OldParam.SnubberResistance)
                SnubberResistanceValue=evalin('base',obj.OldParam.SnubberResistance);
            else
                SnubberResistanceValue=obj.OldParam.SnubberResistance;
            end

            if ischar(obj.OldParam.SnubberCapacitance)
                SnubberCapacitanceValue=evalin('base',obj.OldParam.SnubberCapacitance);
            else
                SnubberCapacitanceValue=obj.OldParam.SnubberCapacitance;
            end

            if SnubberResistanceValue==inf||SnubberCapacitanceValue==0
                logObj.addMessage(obj,'CustomMessage','The case of no snubber is not supported. Open conductance of breaker is set to be 1e-6.');
            elseif SnubberCapacitanceValue==inf

            else
                logObj.addMessage(obj,'CustomMessage','The case of RC snubber is not supported. Open conductance of breaker is set to be 1e-6.');
            end

            if strcmp(obj.OldDropdown.External,'off')&&numel(obj.OldParam.SwitchTimes)>5
                logObj.addMessage(obj,'CustomMessage','The case of more than five switching times is not supported if the external control of the switching times is not selected.');
                logObj.addMessage(obj,'CustomMessage','The first five switching times are imported. Other switching times are ignored.');
            end

            if strcmp(obj.OldDropdown.External,'off')
                if strcmp(obj.OldDropdown.InitialState,'open')
                    obj.NewDropdown.LogicalSelection='NXOR';
                else
                    obj.NewDropdown.LogicalSelection='XOR';
                end
            end

        end
    end

end
