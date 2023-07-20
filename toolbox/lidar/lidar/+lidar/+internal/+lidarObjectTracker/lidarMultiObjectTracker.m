classdef lidarMultiObjectTracker<handle






    properties


Tracks



NextTrackID



        MinDistanceToNearestCluster=3




        NumCoastingUpdates=4





        AgeThresholdForConfirmation=3




        PositionSelector=[1,3,5,7,8,9]




        VelocitySelector=[2,4,6]




        RequireBoxOverlapAssociationCriteria=true
    end

    methods
        function this=lidarMultiObjectTracker()




            initializeTracks(this);
        end

        function[trackPositions,trackedBoxLabels,trackIDs,trackVelocities]=...
            step(this,classifiedClusterLocations,allOtherClusterLocations,boxLabels,dt,objectIds)

































            predictNewLocationsOfTracks(this,dt);
            [assignments,unassignedTracks,unassignedDetections]=...
            detectionToTrackAssignment(this,classifiedClusterLocations,allOtherClusterLocations);
            updateAssignedTracks(this,assignments,classifiedClusterLocations,allOtherClusterLocations);
            updateUnassignedTracks(this,unassignedTracks);
            deleteLostTracks(this);


            unassignedDetectionTrackIDs=objectIds(unassignedDetections);
            createNewTracks(this,unassignedDetections,classifiedClusterLocations,boxLabels,dt,unassignedDetectionTrackIDs);
            [trackPositions,trackedBoxLabels,trackIDs,trackVelocities]=getConfirmedTrackPositions(this);
        end

        function[positions,labels,trackIDs,velocities]=getConfirmedTrackPositions(this)






            confirmedTracks=[this.Tracks(:).age]>=this.AgeThresholdForConfirmation&...
            ([this.Tracks(:).consecutiveInvisibleCount]<=1);
            positions=reshape([this.Tracks(confirmedTracks).pos],6,[])';
            trackIDs=[this.Tracks(confirmedTracks).id];
            labels={this.Tracks(confirmedTracks).objectClass};
            velocities=reshape([this.Tracks(confirmedTracks).vel],3,[])';
        end
    end

    methods(Access=protected,Hidden)

        function dist=distance(~,trackPosition,clusterLocations)

            dist=sqrt(sum((trackPosition(1:3)-clusterLocations(:,1:3)).^2,2));
        end

        function initializeTracks(this)

            this.Tracks=struct(...
            'id',{},...
            'pos',{},...
            'vel',{},...
            'objectClass',{},...
            'kalmanFilter',{},...
            'age',{},...
            'totalVisibleCount',{},...
            'consecutiveInvisibleCount',{});

            this.NextTrackID=1;
        end

        function predictNewLocationsOfTracks(this,dt)

            for i=1:length(this.Tracks)

                xPred=predict(this.Tracks(i).kalmanFilter,dt);
                this.Tracks(i).pos=xPred(this.PositionSelector)';
                this.Tracks(i).vel=xPred(this.VelocitySelector)';
            end
        end

        function[assignments,unassignedTracks,unassignedDetections]=...
            detectionToTrackAssignment(this,classifiedClusters,allOtherClusters)
            nTracks=length(this.Tracks);
            isTrackAssigned=false(nTracks,1);
            nDetections=size(classifiedClusters,1);
            isClassfiedClusterAssignedToTrack=false(nDetections,1);



            assignments=zeros(0,3);

            for trackIdx=1:nTracks
                predictedLocation=this.Tracks(trackIdx).pos;



                closestClusterIdx=findNearestClustersToTrack(this,predictedLocation,[classifiedClusters;allOtherClusters]);
                if~isempty(closestClusterIdx)


                    if closestClusterIdx<=nDetections
                        assignments(end+1,:)=[trackIdx,closestClusterIdx,1];%#ok<AGROW>
                        isTrackAssigned(trackIdx)=true;
                        isClassfiedClusterAssignedToTrack(closestClusterIdx)=true;
                    else
                        closestClusterIdx=closestClusterIdx-nDetections;
                        assignments(end+1,:)=[trackIdx,closestClusterIdx,0];%#ok<AGROW>
                        isTrackAssigned(trackIdx)=true;
                    end
                end
            end

            unassignedTracks=find(isTrackAssigned==false);
            unassignedDetections=find(isClassfiedClusterAssignedToTrack==false);
        end

        function updateAssignedTracks(this,assignments,classifiedClusters,allClusters)
            numAssignedTracks=size(assignments,1);
            for i=1:numAssignedTracks
                trackIdx=assignments(i,1);
                detectionIdx=assignments(i,2);

                if assignments(i,3)==1
                    meas=classifiedClusters(detectionIdx,:);
                else
                    meas=allClusters(detectionIdx,:);
                end



                xPred=correct(this.Tracks(trackIdx).kalmanFilter,meas);



                this.Tracks(trackIdx).pos=meas;
                this.Tracks(trackIdx).vel=xPred(this.VelocitySelector)';


                this.Tracks(trackIdx).age=this.Tracks(trackIdx).age+1;


                this.Tracks(trackIdx).totalVisibleCount=...
                this.Tracks(trackIdx).totalVisibleCount+1;
                this.Tracks(trackIdx).consecutiveInvisibleCount=0;
            end
        end

        function updateUnassignedTracks(this,unassignedTracks)


            for i=1:length(unassignedTracks)
                trackIdx=unassignedTracks(i);
                this.Tracks(trackIdx).age=this.Tracks(trackIdx).age+1;
                this.Tracks(trackIdx).consecutiveInvisibleCount=...
                this.Tracks(trackIdx).consecutiveInvisibleCount+1;
            end
        end

        function deleteLostTracks(this)

            if isempty(this.Tracks)
                return;
            end

            invisibleForTooLong=this.NumCoastingUpdates;
            ageThreshold=8;


            ages=[this.Tracks(:).age];
            totalVisibleCounts=[this.Tracks(:).totalVisibleCount];
            visibility=totalVisibleCounts./ages;


            lostInds=(ages<ageThreshold&visibility<0.5)|...
            [this.Tracks(:).consecutiveInvisibleCount]>=invisibleForTooLong;







            trackPositions=reshape([this.Tracks(:).pos],6,[])';
            nTracks=size(trackPositions,1);
            if nTracks>=2
                trackBboxes=i_getBoundingBox(trackPositions);
                for trackIdx=1:nTracks
                    if~lostInds(trackIdx)
                        overlapRatios=bboxOverlapRatio(trackBboxes(trackIdx,:),...
                        trackBboxes);
                        overlapRatios(trackIdx)=0;
                        overlappingTrackIdxes=find(overlapRatios>0);
                        if~isempty(overlappingTrackIdxes)

                            [~,ageMinTrackIdx]=min(ages(overlappingTrackIdxes));
                            trackIdxToLose=overlappingTrackIdxes(ageMinTrackIdx);
                            lostInds(trackIdxToLose)=true;
                        end
                    end
                end
            end


            this.Tracks=this.Tracks(~lostInds);
        end

        function createNewTracks(this,unassignedDetections,detections,boxLabels,t,unassignedDetectionsTrackIDs)


            meas=detections(unassignedDetections,:);
            labels=boxLabels(unassignedDetections);

            for i=1:size(meas,1)
                pos=meas(i,:);
                vel=[0,0,0];


                kalmanFilter=...
                lidar.internal.lidarObjectTracker.initUKFCustom(t,pos);



                trackID=getTrackID(this,unassignedDetectionsTrackIDs(i));


                newTrack=struct(...
                'id',trackID,...
                'pos',pos,...
                'vel',vel,...
                'objectClass',labels{i},...
                'kalmanFilter',kalmanFilter,...
                'age',1,...
                'totalVisibleCount',1,...
                'consecutiveInvisibleCount',0);


                this.Tracks(end+1)=newTrack;


                this.NextTrackID=trackID+1;
            end
        end

        function clusterIndex=findNearestClustersToTrack(this,trackPos,clusterLocations)



            if~isempty(clusterLocations)

                dist=distance(this,trackPos,clusterLocations);
                minDistanceClusterIndex=find(dist<=this.MinDistanceToNearestCluster);

                if~isempty(minDistanceClusterIndex)


                    x=trackPos(1);y=trackPos(2);Xlength=trackPos(4);YLength=trackPos(5);
                    trackBbox=[x-Xlength/2,y-YLength/2,Xlength,YLength];
                    cXs=clusterLocations(minDistanceClusterIndex,1);
                    cYs=clusterLocations(minDistanceClusterIndex,2);
                    cXLengths=clusterLocations(minDistanceClusterIndex,4);
                    cYLengths=clusterLocations(minDistanceClusterIndex,5);
                    cBboxes=[cXs-cXLengths./2,cYs-cYLengths./2,cXLengths,cYLengths];
                    overlapRatios=bboxOverlapRatio(trackBbox,cBboxes);



                    overLapThresholdCriteria=overlapRatios>0;
                    clusterIndex=minDistanceClusterIndex(overLapThresholdCriteria);
                    overlapRatios=overlapRatios(overLapThresholdCriteria);

                    [~,maxIdx]=max(overlapRatios);
                    clusterIndex=clusterIndex(maxIdx);
                else
                    clusterIndex=[];
                end

                if~this.RequireBoxOverlapAssociationCriteria&&...
                    isempty(clusterIndex)

                    minDistanceClusterIndex=find(dist<=this.MinDistanceToNearestCluster/2);
                    distancesToClusters=dist(minDistanceClusterIndex);
                    [~,idx]=min(distancesToClusters);
                    clusterIndex=minDistanceClusterIndex(idx);
                end
            else
                clusterIndex=[];
            end
        end

        function trackID=getTrackID(this,objectId)



            if objectId~=0
                trackID=objectId;
            else
                trackID=this.NextTrackID;
            end
        end
    end

    methods(Static)
        function initializationParam=startTracking(labelsInfo,clusterId)


            initializationParam.detections=zeros(0,6);
            initializationParam.boxLabels={};
            initializationParam.objectIDs=[];

            pos=labelsInfo.Position;
            for i=1:size(pos,1)
                trackID=i;
                center=pos(i,1:3)+pos(i,4:6)/2;
                boxXYLoc=center(1:2);
                label=labelsInfo.Name(i);
                if clusterId(i)>0
                    meas=[center,pos(i,4:6)];
                    initializationParam=addDetection(initializationParam,meas,boxXYLoc,label,trackID);
                end
            end
        end
    end

end

function initializationParam=addDetection(initializationParam,measurement,~,label,trackID)





    detBboxes=lidar.internal.lidarObjectTracker.getBboxForDetections(initializationParam.detections);
    measBbox=lidar.internal.lidarObjectTracker.getBboxForDetections(measurement);
    isOverlap=any(bboxOverlapRatio(measBbox,detBboxes)>0.8);
    if~isOverlap
        initializationParam.detections(end+1,:)=measurement;
        initializationParam.boxLabels{end+1}=label;
        initializationParam.objectIDs(end+1)=trackID;
    end
end

function trackBbox=i_getBoundingBox(trackPos)

    x=trackPos(:,1);y=trackPos(:,2);Xlength=trackPos(:,4);YLength=trackPos(:,5);
    trackBbox=[x-Xlength/2,y-YLength/2,Xlength,YLength];
end
