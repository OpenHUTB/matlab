classdef(ConstructOnLoad)MetricsUpdatedEventData<event.EventData





    properties

VolumeFraction
NumberRegions
LargestRegion
SmallestRegion
Jaccard
Dice
BFScore
Custom

    end

    methods

        function data=MetricsUpdatedEventData(vf,numRegion,largeRegion,smallregion,jac,dicemetric,bfmetric,custommetric)

            data.VolumeFraction=vf;
            data.NumberRegions=numRegion;
            data.LargestRegion=largeRegion;
            data.SmallestRegion=smallregion;
            data.Jaccard=jac;
            data.Dice=dicemetric;
            data.BFScore=bfmetric;
            data.Custom=custommetric;

        end

    end

end