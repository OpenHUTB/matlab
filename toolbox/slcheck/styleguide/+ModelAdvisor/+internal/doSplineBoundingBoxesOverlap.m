function result=doSplineBoundingBoxesOverlap(splineA,splineB)


    result=false;

    if isempty(splineA)||isempty(splineB)
        return;
    end

    bottomRightA=struct('x',max(splineA.segments(splineA.start:splineA.end,1)),...
    'y',max(splineA.segments(splineA.start:splineA.end,2)));

    topLeftA=struct('x',min(splineA.segments(splineA.start:splineA.end,1)),...
    'y',min(splineA.segments(splineA.start:splineA.end,2)));

    bottomRightB=struct('x',max(splineB.segments(splineB.start:splineB.end,1)),...
    'y',max(splineB.segments(splineB.start:splineB.end,2)));

    topLeftB=struct('x',min(splineB.segments(splineB.start:splineB.end,1)),...
    'y',min(splineB.segments(splineB.start:splineB.end,2)));

    if(topLeftB.x>bottomRightA.x||topLeftA.x>bottomRightB.x)
        return;
    end


    if(topLeftB.y>bottomRightA.y||topLeftA.y>bottomRightB.y)
        return;
    end

    result=true;
end
