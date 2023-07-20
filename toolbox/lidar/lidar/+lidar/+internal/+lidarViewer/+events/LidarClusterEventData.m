classdef(ConstructOnLoad)LidarClusterEventData<event.EventData





    properties
ClusterData
Mode
DistanceThreshold
AngleThreshold
NumClusters
MinDistance
    end

    methods
        function eventData=LidarClusterEventData(clust,mode,dist,ang,mindist,k)
            eventData.ClusterData=clust;
            eventData.Mode=mode;
            eventData.DistanceThreshold=dist;
            eventData.AngleThreshold=ang;
            eventData.NumClusters=k;
            eventData.MinDistance=mindist;
        end
    end
end
