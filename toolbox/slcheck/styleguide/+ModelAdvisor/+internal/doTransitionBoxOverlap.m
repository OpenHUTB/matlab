


function result=doTransitionBoxOverlap(transition,box)
    result=false;

    if isempty(transition)||isempty(box)
        return;
    end

    spline=transition.getSpline;
    if isequal(transition.Source,box)
        spline=spline(2:size(spline,1),:);
    end

    numPointsArrow=4;
    if isequal(transition.Destination,box)
        spline=spline(1:size(spline,1)-numPointsArrow,:);
    end

    [segmentB1,segmentB2,segmentB3,segmentB4]=getSegmentsFromBox(box);






    for n=1:length(spline)-1
        segmentA=struct('srcX',spline(n,1),'srcY',spline(n,2),...
        'dstX',spline(n+1,1),'dstY',spline(n+1,2));

        if ModelAdvisor.internal.doSegmentsIntersect(segmentA,segmentB1)||...
            ModelAdvisor.internal.doSegmentsIntersect(segmentA,segmentB2)||...
            ModelAdvisor.internal.doSegmentsIntersect(segmentA,segmentB3)||...
            ModelAdvisor.internal.doSegmentsIntersect(segmentA,segmentB4)



            result=true;
            return;

        end
    end
end

function[s1,s2,s3,s4]=getSegmentsFromBox(box)
    s1=[];s2=[];s3=[];s4=[];
    if isempty(box)
        return;
    end
    x=box.Position(1);y=box.Position(2);
    dx=box.Position(3);dy=box.Position(4);



    s1=struct('srcX',x,'srcY',y,'dstX',x+dx,'dstY',y);
    s2=struct('srcX',x,'srcY',y,'dstX',x,'dstY',y+dy);
    s3=struct('srcX',x+dx,'srcY',y,'dstX',x+dx,'dstY',y+dy);
    s4=struct('srcX',x,'srcY',y+dy,'dstX',x+dx,'dstY',y+dy);
end