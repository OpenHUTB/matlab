classdef SimpleOccupancyMap<nav.algs.internal.InternalAccess





























%#codegen

    properties(Access={?nav.algs.internal.Submap,...
        ?nav.algs.internal.MultiResolutionGridStack,...
        ?nav.algs.internal.CorrelativeScanMatcher,...
        ?tSimpleOccupancyMap})

GridMatrix


GridSize


Resolution


ProbSaturation


ProbSatIntLogodds


LogoddsHit


LogoddsMiss


InvSensorModel


GridLocationInWorld


Lookup


Linspace
    end

    methods(Access={?nav.algs.internal.Submap,...
        ?nav.algs.internal.MultiResolutionGridStack,...
        ?nav.algs.internal.CorrelativeScanMatcher,...
        ?tSimpleOccupancyMap})

        function obj=SimpleOccupancyMap(gridSize,resolution)





            coder.allowpcode('plain');
            obj.GridMatrix=zeros(gridSize,'int16');
            obj.GridSize=gridSize;
            obj.Resolution=resolution;
            obj.InvSensorModel=[0.4,0.7];
            obj.ProbSaturation=[0.001,0.999];
            obj.GridLocationInWorld=[0,0];
            obj.Linspace=intmin('int16'):intmax('int16');
            l=coder.load("+nav/+algs/+internal/lookup.mat");
            obj.Lookup=l.lookup;
            obj.LogoddsHit=obj.probToIntLogodds(0.7);
            obj.LogoddsMiss=obj.probToIntLogodds(0.4);
            obj.ProbSatIntLogodds=obj.probToIntLogodds([0.001,0.999]);
        end

        function insertRay(obj,pose,scan,maxRange)






            startPt=[pose(1),pose(2)];
            endPt=[pose(1)+scan.Ranges.*cos(pose(3)+scan.Angles),...
            pose(2)+scan.Ranges.*sin(pose(3)+scan.Angles)];
            rangeIsMax=(scan.Ranges>=maxRange);
            inverseModelLogodds=[obj.LogoddsMiss,obj.LogoddsHit];
            numRays=size(endPt,1);

            if numRays==0
                return;
            else


                [~,~,endPts,middlePts]=nav.algs.internal.impl.raycastInternal(startPt,endPt,...
                obj.GridSize(1),obj.GridSize(2),obj.Resolution,obj.GridLocationInWorld,rangeIsMax);

                if~isempty(middlePts)


                    linIdxMid=middlePts(:,1)+obj.GridSize(1)*(middlePts(:,2)-1);
                    [linIdxMidUn,~,occurrenceMid]=unique(linIdxMid);

                    numRepeat=int16(accumarray(occurrenceMid,1));
                    updateValuesMiss=obj.GridMatrix(linIdxMidUn)+numRepeat*inverseModelLogodds(1);
                    updateValuesMiss(updateValuesMiss<obj.ProbSatIntLogodds(1))=obj.ProbSatIntLogodds(1);
                    obj.GridMatrix(linIdxMidUn)=updateValuesMiss;
                end
                if~isempty(endPts)


                    linIdxEnd=endPts(:,1)+obj.GridSize(1)*(endPts(:,2)-1);
                    [linIdxMidUn,~,occurrenceEnd]=unique(linIdxEnd);

                    numRepeat=int16(accumarray(occurrenceEnd,1));
                    updateValuesHit=obj.GridMatrix(linIdxMidUn)+numRepeat*inverseModelLogodds(2);
                    updateValuesHit(updateValuesHit>obj.ProbSatIntLogodds(2))=obj.ProbSatIntLogodds(2);
                    obj.GridMatrix(linIdxMidUn)=updateValuesHit;
                end
            end
        end

        function mat=occupancyMatrix(obj)



            mat=obj.intLogoddsToProb(obj.GridMatrix);
        end

        function logodds=probToIntLogodds(obj,prob)


            logodds=int16(interp1(obj.Lookup,...
            single(obj.Linspace),prob,'nearest','extrap'));
        end

        function probability=intLogoddsToProb(obj,logodds)


            probability=reshape(double(...
            obj.Lookup(int32(logodds(:))-int32(obj.Linspace(1))+1)),size(logodds));
        end
    end
end