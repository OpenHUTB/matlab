classdef Pulse<handle










































































































    properties
        Data=zeros(0,5)
        InitialCapVoltage=[]
        InitialChargeDeficit=0
    end
    properties(Dependent=true)
InitialChargeDeficitAh
InitialSOC
Time
Voltage
Current
Charge
ChargeAh
SOC
MeanCurrent
MeanCurrentMagnitude
LoadFrequency
RelaxationFrequency
LoadTime
RelaxationTime
SOCRange
PulseSOCRange
    end
    properties
        idxLoad=[1,0]
        idxRelax=[1,0]
        idxPulseSequence=[]
        IsDischarge=true
        Parameters=Battery.Parameters.empty(1,0)
    end
    properties(SetAccess=private)
        ParametersHistory=Battery.Parameters.empty(1,0)
        Parent=Battery.PulseSequence.empty(0,1)
    end



    methods
        function obj=Pulse(Parent)
            obj.Parent=Parent;
        end
    end





    methods

        function value=get.InitialChargeDeficitAh(obj)
            value=obj.InitialChargeDeficit/3600;
        end

        function value=get.InitialSOC(obj)
            value=obj.Data(1,5);
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

        function value=get.MeanCurrent(obj)
            idxRange=obj.idxLoad(1):obj.idxLoad(2);
            value=mean(obj.Data(idxRange,3));
        end

        function value=get.MeanCurrentMagnitude(obj)
            value=abs(obj.MeanCurrent);
        end

        function value=get.LoadFrequency(obj)
            idxRange=obj.idxLoad(1):obj.idxLoad(2);
            deltaTime=diff(obj.Data(idxRange,1));
            if isempty(deltaTime)
                value=nan;
            else
                value=1/mean(deltaTime);
            end
        end

        function value=get.RelaxationFrequency(obj)
            idxRange=obj.idxRelax(1):obj.idxRelax(2);
            deltaTime=diff(obj.Data(idxRange,1));
            if isempty(deltaTime)
                value=nan;
            else
                value=1/mean(deltaTime);
            end
        end

        function value=get.LoadTime(obj)
            value=diff(obj.Time(obj.idxLoad));
        end

        function value=get.RelaxationTime(obj)
            value=diff(obj.Time(obj.idxRelax));
        end

        function value=get.SOCRange(obj)
            value=[min(obj.Data(:,5)),max(obj.Data(:,5))];
        end

        function value=get.PulseSOCRange(obj)


            StartSOC=obj.SOC(max(obj.idxLoad(1)-1,1));
            EndSOC=obj.SOC(obj.idxRelax(1));
            value=[StartSOC,EndSOC];
        end

    end




    methods

        function set.Parameters(obj,value)
            validateattributes(value,{'Battery.Parameters'},{})


            if~isempty(value)
                obj.ParametersHistory(end+1)=value;%#ok<MCSUP>
            end
            obj.Parameters=value;

        end

    end

end
