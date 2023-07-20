classdef ClusteringAlgorithm<handle










    properties


        ShouldRemoveGroundPoints=true




        GroundPlaneHeightThreshold=-1.2





        MinDistToNearestCluster=2




        MinPointsToRecognizeCluster=10



        GroundRemovalGridResolution=0.4



        GroundRemovalHeightChangeFactor=0.22



        Radius=0.7





        DisplayLimits=[-50,50;-25,25;-5,5];




        UseEuclideanClustering=true




        MinClusterArea=0.5;
    end

    properties(Hidden)


ClusterLabels
PointCloud

PointCloudObj

Lengths
Heights
Widths
Centers
ClusterIdxes
NumClusters
    end


    methods
        function this=ClusteringAlgorithm(limits)



            this.DisplayLimits=limits;
        end


        function run(this,pCloud,~)





            if isa(pCloud,'pointCloud')
                pCloud=removeInvalidPoints(pCloud);
                pCloud=pCloud.Location;
            end
            pCloud=selectPointsWithinDisplayLimits(this,pCloud);

            newpCloud=this.removeGroundPlane(pCloud);





            pcZeroHeight=[newpCloud(:,[1,2]),zeros(size(newpCloud,1),1)];
            this.PointCloudObj=pointCloud(pcZeroHeight);


            [clusterLabels,numClusters]=pcsegdist(pointCloud(newpCloud),this.Radius);


            centers=zeros(0,3);
            widths=[];
            heights=[];
            lengths=[];
            clusterIdxes=[];
            for clusterId=1:numClusters
                ptsInCluster=newpCloud(clusterLabels==clusterId,:);
                if size(ptsInCluster,1)>this.MinPointsToRecognizeCluster
                    minPtsXYZ=min(ptsInCluster);
                    maxPtsXYZ=max(ptsInCluster);
                    height=maxPtsXYZ(3)-minPtsXYZ(3);
                    width=maxPtsXYZ(2)-minPtsXYZ(2);
                    length=maxPtsXYZ(1)-minPtsXYZ(1);


                    minP=min(ptsInCluster);
                    maxP=max(ptsInCluster);
                    centers(end+1,:)=(minP+maxP)/2;%#ok<AGROW>
                    lengths(end+1,1)=length;%#ok<AGROW>
                    heights(end+1,1)=height;%#ok<AGROW>
                    widths(end+1,1)=width;%#ok<AGROW>
                    clusterIdxes(end+1)=clusterId;%#ok<AGROW>
                end
            end

            this.ClusterLabels=clusterLabels;

            this.PointCloud=newpCloud;
            this.Centers=centers;
            this.Lengths=lengths;
            this.Heights=heights;
            this.Widths=widths;
            this.ClusterIdxes=clusterIdxes;
            this.NumClusters=size(centers,1);
        end

        function clusterId=findNearestCluster(this,boxXYLoc)



            idxes=findNeighborsInRadius(this.PointCloudObj,[boxXYLoc,0],this.MinDistToNearestCluster);
            if~isempty(idxes)

                clusterIds=this.ClusterLabels(idxes);
                clusterId=max(clusterIds);
            else
                clusterId=-2;
            end
        end

        function allClusterLocations=filterClusters(this,detections)




            if~isempty(this.Centers)
                allClusterLocations=[this.Centers,...
                this.Lengths,this.Widths,this.Heights];


                detectedBoxes=lidar.internal.lidarObjectTracker.getBboxForDetections(detections);
                clusterBoxes=lidar.internal.lidarObjectTracker.getBboxForDetections(allClusterLocations);



                isAreaSignificant=prod(clusterBoxes(:,3:4),2)>=this.MinClusterArea;
                isDetectedBox=any(bboxOverlapRatio(clusterBoxes,detectedBoxes)>0,2);
                filterCriteria=~isDetectedBox&isAreaSignificant;
                allClusterLocations=allClusterLocations(filterCriteria,:);
            else

                allClusterLocations=zeros(0,6);
            end
        end

    end

    methods(Access='private')
        function pCloud=removeGroundPlane(this,pCloud)



            limits=this.DisplayLimits;
            isGroundPt=lidar.internal.lidarObjectTracker.pcFindGroundPoints(pCloud,limits(1,:),limits(2,:),limits(3,:),this.GroundRemovalGridResolution,this.GroundRemovalHeightChangeFactor);
            pCloud=pCloud(~isGroundPt,:);
        end

        function pCloud=selectPointsWithinDisplayLimits(this,pCloud)



            if isa(pCloud,'pointCloud')
                indices=findPointsInROI(pCloud,this.DisplayLimits);
                pCloud=select(pCloud,indices,'OutputSize','full');
            else
                limits=this.DisplayLimits;
                x=pCloud(:,1);
                y=pCloud(:,2);
                z=pCloud(:,3);
                xlim=x>=limits(1,1)&x<=limits(1,2);
                ylim=y>=limits(2,1)&y<=limits(2,2);
                zlim=z>=limits(3,1)&z<=limits(3,2);
                pCloud=pCloud(xlim&ylim&zlim,:);
            end
        end
    end
end

