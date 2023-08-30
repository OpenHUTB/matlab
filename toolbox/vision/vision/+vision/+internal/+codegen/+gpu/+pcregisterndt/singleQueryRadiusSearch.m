function[nghbrsIdx,numNgbrs]=singleQueryRadiusSearch(meanCoordinates,queryPoint,radius)
%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');

    numRefPoints=size(meanCoordinates,1);
    nghbrsIdx=coder.nullcopy(zeros(numRefPoints,1,'uint32'));
    numNgbrs=uint32(0);

    coder.gpu.kernel;
    for refIter=1:numRefPoints
        qryPt=queryPoint;
        refPt=meanCoordinates(refIter,:);
        diffMat=[qryPt(1)-refPt(1),qryPt(2)-refPt(2),qryPt(3)-refPt(3)];
        diffMat_sum=diffMat(1)*diffMat(1)+diffMat(2)*diffMat(2)+diffMat(3)*diffMat(3);

        if diffMat_sum<=radius*radius
            [numNgbrs,oldVal]=gpucoder.atomicAdd(numNgbrs,uint32(1));
            nghbrsIdx(oldVal+1)=refIter;
        end
    end
end
