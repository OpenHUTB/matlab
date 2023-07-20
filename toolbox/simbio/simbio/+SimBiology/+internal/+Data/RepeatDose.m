classdef RepeatDose<hgsetget











    properties(Access=public,SetObservable,GetObservable)
        Amount=0;
        Compartment=[];
        Interval=0;
        Rate=0;
        Repeat=0;
        TimeOffset=0;
    end

    properties(SetAccess=private)
        Type='RepeatDose';
    end


    methods

        function obj=RepeatDose(amount,interval,repeat,rate)

            obj.Amount=amount;
            obj.Interval=interval;
            obj.Repeat=repeat;
            obj.Rate=rate;

            if isnan(obj.Interval)
                obj.Interval=0;
            end
            if isnan(obj.Repeat)
                obj.Repeat=0;
            end
        end



        function doseData=getData(obj)
            if(obj.Interval==0)

                time=obj.TimeOffset;
                value=obj.Amount;
                rate=obj.Rate;
            else
                time=(obj.TimeOffset+((0:obj.Repeat)*obj.Interval))';
                value=ones(obj.Repeat+1,1)*obj.Amount;
                rate=ones(obj.Repeat+1,1)*obj.Rate;
            end
            doseData=SimBiology.internal.Data.Dose;
            doseData.Time=time;
            doseData.Amount=value;
            doseData.Rate=rate;
        end

    end
end
