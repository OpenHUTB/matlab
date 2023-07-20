










function outNormalsMat=computeSurfaceNormals(inpLocations,K)
%#codegen



    coder.gpu.kernelfun;
    coder.allowpcode('plain');



    [ngbrIndices,~,validIndices]=...
    vision.internal.codegen.gpu.PointCloudImpl.multiQueryKNNSearchImpl(...
    inpLocations,inpLocations,K);

    numPoints=numel(inpLocations)/3;
    numNeighbors=size(ngbrIndices,1);

    covMatBatch=zeros(3,3,numPoints,'like',inpLocations);

    coder.gpu.kernel;
    for ptIter=1:numPoints
        if validIndices(ptIter)<numNeighbors
            covMatBatch(:,:,ptIter)=coder.internal.nan(3,3);
        else

            ngbrMat=coder.nullcopy(zeros(numNeighbors,3,'like',inpLocations));
            meanVal=zeros(1,3,'like',inpLocations);

            coder.gpu.nokernel;
            for ngbrIter=1:numNeighbors
                ngbrMat(ngbrIter,1)=inpLocations(ngbrIndices(ngbrIter,ptIter));
                ngbrMat(ngbrIter,2)=inpLocations(ngbrIndices(ngbrIter,ptIter)+numPoints);
                ngbrMat(ngbrIter,3)=inpLocations(ngbrIndices(ngbrIter,ptIter)+2*numPoints);
                meanVal(1)=meanVal(1)+ngbrMat(ngbrIter,1);
                meanVal(2)=meanVal(2)+ngbrMat(ngbrIter,2);
                meanVal(3)=meanVal(3)+ngbrMat(ngbrIter,3);
            end
            meanVal=meanVal./numNeighbors;


            coder.gpu.nokernel;
            for ngbrIter=1:numNeighbors
                ngbrMat(ngbrIter,:)=ngbrMat(ngbrIter,:)-meanVal;
            end


            coder.gpu.nokernel;
            for c=1:3
                coder.gpu.nokernel;
                for r=1:3
                    sumVal=cast(0,'like',ngbrMat);
                    for ngbrIter=1:numNeighbors
                        sumVal=sumVal+ngbrMat(ngbrIter,r)*ngbrMat(ngbrIter,c);
                    end
                    covMatBatch(r,c,ptIter)=sumVal;
                end
            end
        end
    end







    [~,eigVal,eigVec]=vision.internal.codegen.gpu.computeBatchedSvd(covMatBatch);


    outNormalsMat=coder.nullcopy(inpLocations);
    coder.gpu.kernel
    for ptIter=1:numPoints
        if isfinite(inpLocations(ptIter))&&...
            isfinite(inpLocations(ptIter+numPoints))&&...
            isfinite(inpLocations(ptIter+2*numPoints))

            minEigVal=coder.internal.inf(1,'like',covMatBatch);
            minIdx=1;
            for i=1:3
                if eigVal(i,ptIter)<minEigVal
                    minEigVal=eigVal(i,ptIter);
                    minIdx=i;
                end
            end



            outNormalsMat(ptIter)=eigVec(1,minIdx,ptIter);
            outNormalsMat(ptIter+numPoints)=eigVec(2,minIdx,ptIter);
            outNormalsMat(ptIter+2*numPoints)=eigVec(3,minIdx,ptIter);
        else
            outNormalsMat(ptIter)=coder.internal.nan(1,'like',covMatBatch);
            outNormalsMat(ptIter+numPoints)=coder.internal.nan(1,'like',covMatBatch);
            outNormalsMat(ptIter+2*numPoints)=coder.internal.nan(1,'like',covMatBatch);
        end
    end
end
