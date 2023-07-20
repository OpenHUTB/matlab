




classdef PointCloudImpl




    methods(Static)


        function[indices_sorted,distMat_sorted]=findNearestNeighborsImpl(ptCloudCoords,queryLocation,numNghbrs)




%#codegen


            coder.gpu.kernelfun;
            coder.allowpcode('plain');
            coder.inline('never');

            [indices_sorted,distMat_sorted]=vision.internal.codegen.gpu.findNNImpl(ptCloudCoords,...
            queryLocation,numNghbrs);
        end


        function[indicesOut,distMatOut]=findNeighborsInRadiusImpl(ptCloudCoords,rangeDataCoords,queryLocation,radius,doSortDist)


%#codegen


            coder.gpu.kernelfun;
            coder.allowpcode('plain');
            coder.inline('never');

            [indicesOut,distMatOut]=vision.internal.codegen.gpu.findNRImpl(ptCloudCoords,...
            rangeDataCoords,queryLocation,radius,doSortDist);
        end


        function indicesOut=findPointsInROIImpl(ptCloudCoords,roi)


%#codegen


            coder.gpu.kernelfun;
            coder.allowpcode('plain');
            coder.inline('never');

            indicesOut=vision.internal.codegen.gpu.findPtsInROI(ptCloudCoords,roi);
        end


        function validCoords=extractValidPoints(ptCloudCoords)

%#codegen


            coder.gpu.kernelfun;
            coder.allowpcode('plain');
            coder.inline('never');

            validCoords=vision.internal.codegen.gpu.extractValidIndices(ptCloudCoords);
        end


        function[indices,distMat,validInd]=multiQueryKNNSearchImpl(refLocations,qryLocations,numNgbrs)




%#codegen


            coder.gpu.kernelfun;
            coder.allowpcode('plain');
            coder.inline('never');

            [indices,distMat,validInd]=vision.internal.codegen.gpu.multiQueryKNN(refLocations,qryLocations,numNgbrs);
        end



        function[outLoc,outCol,outNorm,outIntensity,outRangeData]=subsetImpl(location,color,...
            normal,intensity,rangeData,indices,isOrganized,outType)
%#codegen


            coder.allowpcode('plain');
            coder.gpu.kernelfun;
            coder.inline('never');

            [outLoc,outCol,outNorm,outIntensity,outRangeData]=...
            vision.internal.codegen.gpu.getSubsetPoints(location,color,...
            normal,intensity,rangeData,indices,isOrganized,outType);
        end


        function outNormalsMat=surfaceNormalImpl(inpLocations,K)
%#codegen

            coder.gpu.kernelfun;
            coder.allowpcode('plain');
            coder.inline('never');

            outNormalsMat=vision.internal.codegen.gpu.computeSurfaceNormals(inpLocations,K);
        end
    end
end
