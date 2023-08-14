function result=isUnnecessaryJunction(junctionObj)




    result=false;
    if isempty(junctionObj)
        return;
    end

    if(isa(junctionObj,'Stateflow.Junction')&&...
        isequal(junctionObj.Type,'CONNECTIVE')&&...
...
        ~isa(getParent(junctionObj),'Stateflow.TruthTable'))

        sinkTrans=junctionObj.sinkedTransitions;
        sourceTrans=junctionObj.sourcedTransitions;

        if(numel(sinkTrans)==1&&numel(sourceTrans)==1)

            if(isTransitionStraight(sinkTrans)&&...
                isTransitionStraight(sourceTrans))
                if~doTransitionsIntersectOrthogonally(sinkTrans,sourceTrans)

                    if(isTransitionLabelEmpty(sinkTrans)||...
                        isTransitionLabelEmpty(sourceTrans))
                        result=true;
                    end
                end
            else
                if(isTransitionLabelEmpty(sinkTrans)&&...
                    isTransitionLabelEmpty(sourceTrans))
                    result=true;
                end
            end
        end
    end
end


function result=isTransitionLabelEmpty(trans)


    result=false;
    if isempty(trans)
        return
    end
    exp='\%.*\n+|\/\/.*\n+|\%.*\n*|\/\/.*\n*|\/\*.*\*\/';
    if isempty(regexprep(trans.LabelString,exp,''))
        result=true;
    end
end

function result=doTransitionsIntersectOrthogonally(transition1,transition2)
    result=false;
    if isempty(transition1)||isempty(transition2)
        return;
    end
    x1=fix(transition1.SourceEndpoint(1));
    y1=fix(transition1.SourceEndpoint(2));
    x2=fix(transition1.DestinationEndpoint(1));
    y2=fix(transition1.DestinationEndpoint(2));
    x3=fix(transition2.SourceEndpoint(1));
    y3=fix(transition2.SourceEndpoint(2));
    x4=fix(transition2.DestinationEndpoint(1));
    y4=fix(transition2.DestinationEndpoint(2));

    a1=getDiff(x1,x2);
    a2=getDiff(y1,y2);
    b1=-getDiff(x3,x4);
    b2=-getDiff(y3,y4);







    if((a1*b1+a2*b2)==0)
        result=true;
    end
end

function result=isTransitionStraight(transition)
    result=false;
    if isempty(transition)
        return;
    end
    Threshold=2;
    srcPt=transition.SourceEndpoint;
    midPt=transition.Midpoint;
    endPt=transition.DestinationEndpoint;

    if((abs(srcPt(2)-midPt(2))<Threshold&&abs(endPt(2)-midPt(2))<Threshold)||...
        (abs(srcPt(1)-midPt(1))<Threshold&&abs(endPt(1)-midPt(1))<Threshold))
        result=true;
    end
end

function val=getDiff(a,b)
    Thres=5;
    val=b-a;
    if(abs(b-a))<Thres
        val=0;
    end
end