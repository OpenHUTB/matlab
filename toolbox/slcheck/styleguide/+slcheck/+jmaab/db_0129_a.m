classdef db_0129_a<slcheck.subcheck
    methods
        function obj=db_0129_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0129_a';
        end
        function result=run(this)
            result=false;
            violations=[];
            obj=this.getEntity();

            if isa(obj,'Stateflow.Chart')
                sfTransitions=obj.find('-isa','Stateflow.Transition');
                violations=[violations;getTransitionsCrossingOtherTransitions(sfTransitions)];

                if~isempty(violations)
                    result=this.setResult(violations);
                end
            end
        end
    end
end





function violationObj=getTransitionsCrossingOtherTransitions(sfTransitions)
    violationObj=[];

    if isempty(sfTransitions)
        return;
    end

    allSFIds=arrayfun(@(x)x.Id,sfTransitions);


    adjacencyMatrix=zeros(length(allSFIds));




    errTrans=[];
    for k=1:length(sfTransitions)
        for p=1:length(sfTransitions)
            if isequal(k,p)||~isequal(sfTransitions(k).Path,sfTransitions(p).Path)
                continue;
            end


            if 1==adjacencyMatrix(allSFIds==sfTransitions(k).Id,...
                allSFIds==sfTransitions(p).Id)||...
                1==adjacencyMatrix(allSFIds==sfTransitions(p).Id,...
                allSFIds==sfTransitions(k).Id)
                continue;
            end
            adjacencyMatrix(allSFIds==sfTransitions(k).Id,...
            allSFIds==sfTransitions(p).Id)=1;
            adjacencyMatrix(allSFIds==sfTransitions(p).Id,...
            allSFIds==sfTransitions(k).Id)=1;

            if isempty(sfTransitions(k).Source)
                splineK=getSplineDefaultTransition(sfTransitions(k));
            else
                splineK=sfTransitions(k).getSpline;
            end

            if isempty(sfTransitions(p).Source)
                splineP=getSplineDefaultTransition(sfTransitions(p));
            else
                splineP=sfTransitions(p).getSpline;
            end


            isTransKStraight=isTransitionStraight(sfTransitions(k));
            isTransPStraight=isTransitionStraight(sfTransitions(p));

            hasViolation=false;%#ok<NASGU>


            if isTransKStraight&&isTransPStraight


                hasViolation=Advisor.Utils.Stateflow.doSegmentsIntersect(...
                getSegmentFromSpline(splineK),getSegmentFromSpline(splineP));


            elseif~isTransKStraight&&isTransPStraight
                hasViolation=doCurvedStraightTransitionIntersect(...
                sfTransitions(k),sfTransitions(p));


            elseif isTransKStraight&&~isTransPStraight
                hasViolation=doCurvedStraightTransitionIntersect(...
                sfTransitions(p),sfTransitions(k));


            else

                splineObjK=struct('segments',splineK,'start',1,'end',length(splineK));
                splineObjP=struct('segments',splineP,'start',1,'end',length(splineP));

                hasViolation=~doSegmentsOverlap(sfTransitions(p),sfTransitions(k))&&...
                hasIntersectionBetweenSplines(splineObjK,splineObjP,3);




                if~hasViolation&&Advisor.Utils.Stateflow.doSplineBoundingBoxesOverlap(splineObjK,splineObjP)
                    hasViolation=~doSegmentsOverlap(sfTransitions(p),sfTransitions(k))&&...
                    hasIntersectionBetweenSplines(...
                    splineObjK,splineObjP,min(splineObjK.end,splineObjP.end));
                end
            end
            if hasViolation
                errTrans=[errTrans;sfTransitions(k);sfTransitions(p)];%#ok<AGROW>
            end
        end
    end
    errTrans=unique(errTrans);
    for idx=1:length(errTrans)
        vObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(vObj,'SID',errTrans(idx));
        violationObj=[violationObj;vObj];%#ok<AGROW>
    end
end
function spline=getSplineDefaultTransition(transition)
    spline=[];
    if isempty(transition)||~isa(transition,'Stateflow.Transition')
        return;
    end

    spline=transition.getSpline;

    x=2*sign(spline(1,1)-spline(2,1));
    y=2*sign(spline(1,2)-spline(2,2));
    spline=[[spline(1,1)+x,spline(1,2)+y];spline];
end
function segments=getSegmentFromSpline(spline)
    segments=[spline(1,1),spline(1,2),spline(end,1),spline(end,2)];
end


function hasViolation=doCurvedStraightTransitionIntersect(curved,straight)


    spline1=[curved.SourceEndpoint;curved.MidPoint];
    spline2=[curved.MidPoint;curved.DestinationEndpoint];
    stLine=[straight.SourceEndpoint;straight.DestinationEndpoint];

    hasViolation=Advisor.Utils.Stateflow.doSegmentsIntersect(...
    getSegmentFromSpline(spline1),getSegmentFromSpline(stLine))||...
    Advisor.Utils.Stateflow.doSegmentsIntersect(...
    getSegmentFromSpline(spline2),getSegmentFromSpline(stLine));
end
function hasViolation=hasIntersectionsBetweenSegments(segmentsA,segmentsB)
    hasViolation=false;
    for k=1:length(segmentsA)
        for p=1:length(segmentsB)
            splineK=[segmentsA(k).srcX,segmentsA(k).srcY,segmentsA(k).dstX,segmentsA(k).dstY];
            splineP=[segmentsB(p).srcX,segmentsB(p).srcY,segmentsB(p).dstX,segmentsB(p).dstY];

            hasViolation=Advisor.Utils.Stateflow.doSegmentsIntersect(...
            splineK,splineP);
            if hasViolation
                return;
            end
        end
    end
end

function hasViolation=hasIntersectionBetweenSplines(splineObjK,splineObjP,unit)
    hasViolation=false;

    [segmentsA,segmentsB]=ModelAdvisor.internal.getSegmentIntersectionFromSplines(...
    splineObjK,splineObjP,unit);

    if isempty(segmentsA)||isempty(segmentsB)
        return;
    end

    hasViolation=hasIntersectionsBetweenSegments(...
    segmentsA,segmentsB);
end

function result=isTransitionStraight(transition)
    result=true;
    if isempty(transition)
        return;
    end
    Threshold=2;
    srcPt=transition.SourceEndpoint;
    midPt=transition.Midpoint;
    endPt=transition.DestinationEndpoint;
    if~((abs(srcPt(2)-midPt(2))<Threshold&&abs(endPt(2)-midPt(2))<Threshold)||...
        (abs(srcPt(1)-midPt(1))<Threshold&&abs(endPt(1)-midPt(1))<Threshold))
        result=false;
        return;
    else
        slope1=abs(srcPt(2)-midPt(2))/abs(srcPt(1)-midPt(1));
        slope2=abs(endPt(2)-midPt(2))/abs(endPt(1)-midPt(1));
        if(slope1~=slope2)
            result=false;
            return;
        end
    end
end
function result=doSegmentsOverlap(trans1,trans2)
    result=false;
    if isempty(trans1)||isempty(trans2)
        return;
    end
    Threshold=6;
    srcPt1=trans1.SourceEndpoint;
    midPt1=trans1.Midpoint;
    endPt1=trans1.DestinationEndpoint;
    srcPt2=trans2.SourceEndpoint;
    midPt2=trans2.Midpoint;
    endPt2=trans2.DestinationEndpoint;
    if((any(abs(srcPt1-srcPt2)<Threshold))&&(any(abs(midPt1-midPt2)<Threshold))&&...
        (any(abs(endPt1-endPt2)<Threshold)))||...
        ((any(abs(srcPt1-endPt2)<Threshold))&&(any(abs(midPt1-midPt2)<Threshold))&&...
        (any(abs(srcPt2-endPt1)<Threshold)))
        result=true;
        return;
    end
end