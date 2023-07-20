

function[segmentsA,segmentsB]=getSegmentIntersectionFromSplines(splineA,splineB,unit)
    segmentsA=[];segmentsB=[];
    splinesStack={[splineA,splineB]};








    while~isempty(splinesStack)
        s=splinesStack{1};splineA=s(1);splineB=s(2);
        splinesStack(1,:)=[];

        if~ModelAdvisor.internal.doSplineBoundingBoxesOverlap(splineA,splineB)
            continue;
        end












        if(splineA.end-splineA.start)<=unit&&...
            (splineB.end-splineB.start)<=unit






            segmentsA=getSegementsFromSpline(splineA);
            segmentsB=getSegementsFromSpline(splineB);










            break;
        end


        splineA_1=splineA;
        splineA_2=splineA;
        splineA_1.end=splineA.start+fix((splineA.end-splineA.start)/2);
        splineA_2.start=splineA_1.end+1;

        splineB_1=splineB;
        splineB_2=splineB;
        splineB_1.end=splineB.start+fix((splineB.end-splineB.start)/2);
        splineB_2.start=splineB_1.end+1;

        splinesStack=[splinesStack;{[splineA_1,splineB_1]};...
        {[splineA_2,splineB_1]};{[splineA_1,splineB_2]};...
        {[splineA_2,splineB_2]}];%#ok<AGROW>
    end
end

function segments=getSegementsFromSpline(spline)
    partialSpline=spline.segments(spline.start:spline.end,:);
    sz=size(partialSpline,1)-1;
    segments=repmat(struct('srcX',0,'dstX',0,'srcY',0,'dstY',0),sz);
    for idx=1:sz
        srcX=partialSpline(idx,1);
        srcY=partialSpline(idx,2);
        dstX=partialSpline(idx+1,1);
        dstY=partialSpline(idx+1,2);
        segments(idx)=struct('srcX',srcX,'dstX',...
        dstX,'srcY',srcY,'dstY',dstY);
    end
end