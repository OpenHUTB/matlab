function result=doSplineBoundingBoxesOverlap(splineA,splineB)


    result=false;
    splineA=splineA.segments;
    splineB=splineB.segments;

    if isempty(splineA)||isempty(splineB)
        return;
    end

    bottomRightA=[max(splineA(:,1)),max(splineA(:,2))];

    topLeftA=[min(splineA(:,1)),min(splineA(:,2))];

    bottomRightB=[max(splineB(:,1)),max(splineB(:,2))];

    topLeftB=[min(splineB(:,1)),min(splineB(:,2))];

    if(topLeftB(1)>bottomRightA(1)||topLeftA(1)>bottomRightB(1))
        return;
    end


    if(topLeftB(2)>bottomRightA(2)||topLeftA(2)>bottomRightB(2))
    end

    result=true;
end
