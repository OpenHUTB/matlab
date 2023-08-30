function[nghbrsIdx,numNgbrs]=multiQueryRadiusSearch(meanCoordinates,queryPoints,radius)
%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');

    numRefPoints=size(meanCoordinates,1);
    numQryPoints=size(queryPoints,1);
    nghbrsIdx=coder.nullcopy(zeros(numRefPoints,numQryPoints,'uint32'));
    numNgbrs=zeros(numQryPoints,1,'uint32');

    coder.gpu.kernel;
    for qryIter=1:numQryPoints
        coder.gpu.kernel;
        for refIter=1:numRefPoints
            qryPt=queryPoints(qryIter,:);
            refPt=meanCoordinates(refIter,:);
            diffMat=[qryPt(1)-refPt(1),qryPt(2)-refPt(2),qryPt(3)-refPt(3)];
            diffMat_sum=diffMat(1)*diffMat(1)+diffMat(2)*diffMat(2)+diffMat(3)*diffMat(3);

            if diffMat_sum<radius*radius
                [numNgbrs(qryIter),oldVal]=gpucoder.atomicAdd(numNgbrs(qryIter),uint32(1));
                nghbrsIdx(oldVal+1,qryIter)=refIter;
            end
        end
    end
end
