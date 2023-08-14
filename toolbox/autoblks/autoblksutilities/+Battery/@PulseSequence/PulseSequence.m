classdef PulseSequence<handle































































































































    properties
        Data=zeros(0,5)
        ModelName=''
        MetaData=Battery.MetaData.empty(0,1)
        Capacity=1
    end
    properties(Dependent=true)
CapacityAh
    end
    properties(Dependent=true,SetAccess='private')
NumPulses
TestType
Time
Voltage
Current
Charge
ChargeAh
SOC
    end
    properties
        Parameters=Battery.Parameters.empty(1,0)
    end
    properties(SetAccess='private')
        ParametersHistory=Battery.Parameters.empty(1,0)
idxEdge
idxLoad
idxRelax
        Pulse=Battery.Pulse.empty(0,1)
    end


    methods
        function obj=PulseSequence()
            obj.MetaData=Battery.MetaData();
        end
    end





    methods
        function value=get.NumPulses(obj)
            value=numel(obj.Pulse);
        end
        function value=get.TestType(obj)
            if isempty(obj.Pulse)
                value='none';
            elseif all([obj.Pulse.IsDischarge])
                value='discharge';
            elseif~any([obj.Pulse.IsDischarge])
                value='charge';
            else
                value='mixed';
            end
        end
        function value=get.Time(obj)
            value=obj.Data(:,1);
        end
        function value=get.Voltage(obj)
            value=obj.Data(:,2);
        end
        function value=get.Current(obj)
            value=obj.Data(:,3);
        end
        function value=get.Charge(obj)
            value=obj.Data(:,4);
        end
        function value=get.ChargeAh(obj)
            value=obj.Data(:,4)/3600;
        end
        function value=get.SOC(obj)
            value=obj.Data(:,5);
        end
        function value=get.CapacityAh(obj)
            value=obj.Capacity/3600;
        end
    end





    methods

        function set.Capacity(obj,value)
            validateattributes(value,{'numeric'},{'scalar','positive'})
            obj.Capacity=value;
        end

        function set.CapacityAh(obj,value)
            validateattributes(value,{'numeric'},{'scalar','positive'})

            obj.Capacity=value*3600;
        end

        function set.Parameters(obj,value)
            validateattributes(value,{'Battery.Parameters'},{})


            if~isempty(value)
                obj.ParametersHistory(end+1)=value;%#ok<MCSUP>
            end
            obj.Parameters=value;

        end

    end

end
