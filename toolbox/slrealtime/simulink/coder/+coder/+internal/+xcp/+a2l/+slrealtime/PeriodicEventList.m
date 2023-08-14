classdef PeriodicEventList<handle








    properties(SetAccess=immutable,GetAccess=public)
        TIDs;
        Rates;
        NumEvents;
    end

    methods(Access=public)
        function obj=PeriodicEventList(cDesc)


            ofun=cDesc.getFunctionInterfaces('Output');

            obj.NumEvents=0;

            for ii=1:length(ofun)
                ofunTiming=ofun(ii).Timing;
                if strcmp(ofunTiming.TimingMode,'PERIODIC')
                    obj.TIDs(end+1)=ii-1;
                    obj.Rates(end+1)=ofunTiming.SamplePeriod;
                    obj.NumEvents=obj.NumEvents+1;
                end
            end
        end
    end
end