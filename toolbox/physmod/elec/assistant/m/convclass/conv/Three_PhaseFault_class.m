classdef Three_PhaseFault_class<ConvClass&handle



    properties

        OldParam=struct(...
        'InitialStates',[],...
        'SwitchTimes',[],...
        'SwitchStatus',[],...
        'FaultResistance',[],...
        'GroundResistance',[],...
        'SnubberResistance',[],...
        'SnubberCapacitance',[]...
        )


        OldDropdown=struct(...
        'Measurements',[],...
        'FaultA',[],...
        'FaultB',[],...
        'FaultC',[],...
        'GroundFault',[],...
        'External',[]...
        )


        NewDirectParam=struct(...
        'R_closed',[]...
        )


        NewDerivedParam=struct(...
        'G_open',[],...
        'R_ng_fault',[],...
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
        {'FaultA','off';'FaultB','off';'FaultC','off';'External','off'},'ExOffNoFalut';...

        {'FaultA','on';'FaultB','off';'FaultC','off';'External','off'},'ExOffA';...
        {'FaultA','off';'FaultB','on';'FaultC','off';'External','off'},'ExOffB';...
        {'FaultA','off';'FaultB','off';'FaultC','on';'External','off'},'ExOffC';...

        {'FaultA','on';'FaultB','on';'FaultC','off';'External','off'},'ExOffAB';...
        {'FaultA','off';'FaultB','on';'FaultC','on';'External','off'},'ExOffBC';...
        {'FaultA','on';'FaultB','off';'FaultC','on';'External','off'},'ExOffCA';...
        {'FaultA','on';'FaultB','on';'FaultC','on';'External','off'},'ExOffABC';...

        {'FaultA','off';'FaultB','off';'FaultC','off';'External','on'},'ExOnNoFalut';...

        {'FaultA','on';'FaultB','off';'FaultC','off';'External','on'},'ExOnA';...
        {'FaultA','off';'FaultB','on';'FaultC','off';'External','on'},'ExOnB';...
        {'FaultA','off';'FaultB','off';'FaultC','on';'External','on'},'ExOnC';...

        {'FaultA','on';'FaultB','on';'FaultC','off';'External','on'},'ExOnAB';...
        {'FaultA','off';'FaultB','on';'FaultC','on';'External','on'},'ExOnBC';...
        {'FaultA','on';'FaultB','off';'FaultC','on';'External','on'},'ExOnCA';...
        {'FaultA','on';'FaultB','on';'FaultC','on';'External','on'},'ExOnABC';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Three-Phase Fault'
        NewPath='elec_conv_Three_PhaseFault/Three_PhaseFault'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.R_closed=obj.OldParam.FaultResistance;
        end


        function obj=Three_PhaseFault_class(InitialStates,SwitchTimes,SwitchStatus,GroundResistance,SnubberResistance,SnubberCapacitance,GroundFault,External)
            if nargin>0
                obj.OldParam.InitialStates=InitialStates;
                obj.OldParam.SwitchTimes=SwitchTimes;
                obj.OldParam.SwitchStatus=SwitchStatus;
                obj.OldParam.GroundResistance=GroundResistance;
                obj.OldParam.SnubberResistance=SnubberResistance;
                obj.OldParam.SnubberCapacitance=SnubberCapacitance;
                obj.OldDropdown.GroundFault=GroundFault;
                obj.OldDropdown.External=External;
            end
        end

        function obj=objParamMappingDerived(obj)


            if obj.OldParam.SnubberResistance==inf||obj.OldParam.SnubberCapacitance==0
                obj.NewDerivedParam.G_open=1e-6;
            elseif obj.OldParam.SnubberCapacitance==inf
                obj.NewDerivedParam.G_open=max(1/obj.OldParam.SnubberResistance,1e-6);
            else
                obj.NewDerivedParam.G_open=1e-6;
            end

            if strcmp(obj.OldDropdown.GroundFault,'on')
                obj.NewDerivedParam.R_ng_fault=obj.OldParam.GroundResistance;
            else
                obj.NewDerivedParam.R_ng_fault=1e6;
            end

            if strcmp(obj.OldDropdown.External,'on')
                if obj.OldParam.InitialStates==0
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
            case 'None'

            case 'Fault voltages'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Fault voltages');
            case 'Fault currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Fault currents');
            case 'Fault voltages and currents'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Fault voltages and currents');
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
                if obj.OldParam.InitialStates==0
                    obj.NewDropdown.LogicalSelection='NXOR';
                else
                    obj.NewDropdown.LogicalSelection='XOR';
                end
            end

        end
    end

end
