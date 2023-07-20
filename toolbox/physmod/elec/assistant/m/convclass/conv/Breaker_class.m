classdef Breaker_class<ConvClass&handle



    properties

        OldParam=struct(...
        'InitialState',[],...
        'SwitchingTimes',[],...
        'BreakerResistance',[],...
        'SnubberResistance',[],...
        'SnubberCapacitance',[]...
        )


        OldDropdown=struct(...
        'Measurements',[],...
        'External',[],...
        'MoreParameters',[],...
        'NoBreakLoop',[]...
        )


        NewDirectParam=struct(...
        'R_closed',[]...
        )


        NewDerivedParam=struct(...
        'G_open',[],...
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
        {'External','on'},'ExOn';...
        {'External','off'},'ExOff';...
        }

        OldBlockName=[];
        NewBlockPath=[];
        ConversionType=[];
    end

    properties(Constant)
        OldPath='powerlib/Elements/Breaker'
        NewPath='elec_conv_Breaker/Breaker'
    end

    methods
        function obj=objParamMappingDirect(obj)
            obj.NewDirectParam.R_closed=obj.OldParam.BreakerResistance;
        end


        function obj=Breaker_class(SnubberResistance,SnubberCapacitance,SwitchingTimes,InitialState,External)
            if nargin>0
                obj.OldParam.SnubberResistance=SnubberResistance;
                obj.OldParam.SnubberCapacitance=SnubberCapacitance;
                obj.OldParam.SwitchingTimes=SwitchingTimes;
                obj.OldParam.InitialState=InitialState;
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

            if strcmp(obj.OldDropdown.External,'on')
                if obj.OldParam.InitialState==0
                    obj.NewDerivedParam.StepInitialValue=0;
                else
                    obj.NewDerivedParam.StepInitialValue=1;
                end
            end

            nTime=numel(obj.OldParam.SwitchingTimes);
            switch nTime
            case 1
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchingTimes(1);
                obj.NewDerivedParam.switchTime2=1e4;
                obj.NewDerivedParam.switchTime3=1e4;
                obj.NewDerivedParam.switchTime4=1e4;
                obj.NewDerivedParam.switchTime5=1e4;
            case 2
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchingTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchingTimes(2);
                obj.NewDerivedParam.switchTime3=1e4;
                obj.NewDerivedParam.switchTime4=1e4;
                obj.NewDerivedParam.switchTime5=1e4;
            case 3
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchingTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchingTimes(2);
                obj.NewDerivedParam.switchTime3=obj.OldParam.SwitchingTimes(3);
                obj.NewDerivedParam.switchTime4=1e4;
                obj.NewDerivedParam.switchTime5=1e4;
            case 4
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchingTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchingTimes(2);
                obj.NewDerivedParam.switchTime3=obj.OldParam.SwitchingTimes(3);
                obj.NewDerivedParam.switchTime4=obj.OldParam.SwitchingTimes(4);
                obj.NewDerivedParam.switchTime5=1e4;
            otherwise
                obj.NewDerivedParam.switchTime1=obj.OldParam.SwitchingTimes(1);
                obj.NewDerivedParam.switchTime2=obj.OldParam.SwitchingTimes(2);
                obj.NewDerivedParam.switchTime3=obj.OldParam.SwitchingTimes(3);
                obj.NewDerivedParam.switchTime4=obj.OldParam.SwitchingTimes(4);
                obj.NewDerivedParam.switchTime5=obj.OldParam.SwitchingTimes(5);
            end

        end

        function obj=objDropdownMapping(obj)
            logObj=ElecAssistantLog.getInstance();


            switch obj.OldDropdown.Measurements
            case 'Branch voltage'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltage');
            case 'Branch current'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch current');
            case 'Branch voltage and current'
                logObj.addMessage(obj,'OptionNotSupported','Measurements','Branch voltage and current');
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

            if strcmp(obj.OldDropdown.External,'off')&&numel(obj.OldParam.SwitchingTimes)>5
                logObj.addMessage(obj,'CustomMessage','The case of more than five switching times is not supported if the external control of the switching times is not selected.');
                logObj.addMessage(obj,'CustomMessage','The first five switching times are imported. Other switching times are ignored.');
            end

            if strcmp(obj.OldDropdown.External,'off')
                if obj.OldParam.InitialState==0
                    obj.NewDropdown.LogicalSelection='NXOR';
                else
                    obj.NewDropdown.LogicalSelection='XOR';
                end
            end

        end
    end

end
