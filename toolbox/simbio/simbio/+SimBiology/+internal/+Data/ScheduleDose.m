classdef ScheduleDose<hgsetget











    properties(Access=public,SetObservable,GetObservable)
        Amount=[];
        Compartment=[];
        Time=[];
        Rate=[];
    end

    properties(SetAccess=private)
        Type='ScheduleDose';
    end



    methods

        function obj=ScheduleDose(time,amount,rate)

            obj.Time=time;
            obj.Amount=amount;
            obj.Rate=rate;
        end



        function doseData=getData(obj)
            doseData=SimBiology.internal.Data.Dose;
            doseData.Time=obj.Time;
            doseData.Amount=obj.Amount;
            doseData.Rate=obj.Rate;
        end

    end
end