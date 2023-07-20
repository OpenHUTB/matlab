
function[result,failingElements]=isDestinationNotPositionedOnTop(context)
    result=true;
    failingElements=[];

    if isempty(context)
        return;
    end

    [parallelStates,exclusiveStates]=ModelAdvisor.internal.getStates(...
    context,1,false,false);

    junctions=ModelAdvisor.internal.getJunctions(context,1,false);

    failingElements=getDestinationsNotPositionedOnTop(...
    [parallelStates,exclusiveStates],junctions);



    boxes=context.find('-isa','Stateflow.Box','-depth',1);
    for k=1:length(boxes)
        statesInBox=boxes(k).find('-isa','Stateflow.State','-depth',1);
        junctionsInBox=boxes(k).find('-isa','Stateflow.Junction','-depth',1);
        failingElements=[failingElements;getDestinationsNotPositionedOnTop(...
        statesInBox,junctionsInBox)];%#ok<AGROW>
    end
    if isempty(failingElements)
        result=false;
    end
end

function failingElements=getDestinationsNotPositionedOnTop(states,junctions)
    failingElements=[];


    startY_topmostState=realmax;
    endY_topmostState=-1;
    startX_leftmostState=realmax;
    endX_leftmostState=-1;
    if~isempty(states)


        [startY_topmostState,endY_topmostState]=getY_TopmostState(states);


        [startX_leftmostState,endX_leftmostState]=getX_LeftmostState(states);
    end


    startY_topmostJunction=realmax;
    startX_leftmostJunction=realmax;
    if~isempty(junctions)
        startY_topmostJunction=min(arrayfun(@(x)x.Position.Center(2)+...
        x.Position.Radius,junctions));
        startX_leftmostJunction=min(arrayfun(@(x)x.Position.Center(1)+...
        x.Position.Radius,junctions));
    end

    topmostY=min(startY_topmostState,startY_topmostJunction);
    leftmostX=min(startX_leftmostState,startX_leftmostJunction);



    sinkedTrans=arrayfun(@(x)x.sinkedTransitions,[states;junctions],...
    'UniformOutput',false);

    if isempty(sinkedTrans)

        return;
    end

    sinkedTrans=vertcat(sinkedTrans{:});

    transitions=sinkedTrans.find('Source',[]);

    for i=1:length(transitions)
        if isa(transitions(i).Destination,'Stateflow.State')

            if(transitions(i).Destination.Position(2)>topmostY)||...
                (transitions(i).Destination.Position(1)>leftmostX)
                failingElements=[failingElements;transitions(i).Destination];%#ok<AGROW>
            end
        end

        if isa(transitions(i).Destination,'Stateflow.Junction')
            yVal=transitions(i).Destination.Position.Center(2);
            xVal=transitions(i).Destination.Position.Center(1);
            if(yVal>topmostY)||...
                (xVal>leftmostX)
                failingElements=[failingElements;transitions(i).Destination];%#ok<AGROW>
            end
        end
    end

    if isempty(failingElements)
    end
end


function[startY_topmostState,endY_topmostState]=getY_TopmostState(states)
    startY_topmostState=realmax;
    endY_topmostState=-1;
    for len=1:length(states)
        s=states(len);
        y=s.Position(2);
        if y<startY_topmostState
            startY_topmostState=y;
            endY_topmostState=y+s.Position(4);
        end
    end
end

function[startX_leftmostState,endX_leftmostState]=getX_LeftmostState(states)
    startX_leftmostState=realmax;
    endX_leftmostState=-1;
    for len=1:length(states)
        s=states(len);
        x=s.Position(1);
        if x<startX_leftmostState
            startX_leftmostState=x;
            endX_leftmostState=x+s.Position(3);
        end
    end
end


