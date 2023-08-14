










function[indices,distMat,validInd]=multiQueryKNN(refLocations,qryLocations,numNgbrs)




%#codegen




    coder.gpu.kernelfun;
    coder.allowpcode('plain');

    numPointsRef=numel(refLocations)/3;
    numPointsQry=numel(qryLocations)/3;

    distMat=coder.internal.inf(numNgbrs,numPointsQry,'like',refLocations);
    indices=zeros(numNgbrs,numPointsQry,'uint32');
    validInd=zeros(numPointsQry,1,'uint32');




    coder.gpu.kernel;
    for qryIter=1:numPointsQry
        if isfinite(qryLocations(qryIter))
            for refIter=1:numPointsRef
                refPt=[refLocations(refIter),refLocations(refIter+numPointsRef),...
                refLocations(refIter+2*numPointsRef)];
                qryPt=[qryLocations(qryIter),qryLocations(qryIter+numPointsQry),...
                qryLocations(qryIter+2*numPointsQry)];
                distVal=(refPt(1)-qryPt(1))*(refPt(1)-qryPt(1))+...
                (refPt(2)-qryPt(2))*(refPt(2)-qryPt(2))+...
                (refPt(3)-qryPt(3))*(refPt(3)-qryPt(3));
                if isfinite(distVal)

                    maxVal=-coder.internal.inf(1,'like',refLocations);
                    maxIdx=cast(0,'like',refLocations);
                    for maxIter=1:numNgbrs
                        if distMat(maxIter,qryIter)>maxVal
                            maxVal=distMat(maxIter,qryIter);
                            maxIdx=cast(maxIter,'like',refLocations);
                        end
                    end


                    if distVal<maxVal
                        distMat(maxIdx,qryIter)=distVal;
                        indices(maxIdx,qryIter)=refIter;
                    end
                end
            end
        else
            distMat(:,qryIter)=coder.internal.nan(numNgbrs,1,'like',refLocations);
        end
    end



    coder.gpu.kernel;
    for qryIter=1:numPointsQry
        for ngbrIter=1:numNgbrs
            validInd(qryIter)=gpucoder.atomicAdd(...
            validInd(qryIter),uint32(isfinite(distMat(ngbrIter,qryIter))));
        end
    end
end
