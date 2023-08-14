


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
        segmentA=[spline(n,1),spline(n,2),spline(n+1,1),spline(n+1,2)];

        if Advisor.Utils.Stateflow.doSegmentsIntersect(segmentA,segmentB1)||...
            Advisor.Utils.Stateflow.doSegmentsIntersect(segmentA,segmentB2)||...
            Advisor.Utils.Stateflow.doSegmentsIntersect(segmentA,segmentB3)||...
            Advisor.Utils.Stateflow.doSegmentsIntersect(segmentA,segmentB4)



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



    s1=[x,y,x+dx,y];
    s2=[x,y,x,y+dy];
    s3=[x+dx,y,x+dx,y+dy];
    s4=[x,y+dy,x+dx,y+dy];
end