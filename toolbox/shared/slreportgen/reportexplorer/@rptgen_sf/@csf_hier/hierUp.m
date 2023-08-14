function nUp=hierUp(this,thisNode)




    if isa(thisNode,'Stateflow.Machine')
        nUp=[];

    elseif isa(thisNode,'Stateflow.Chart')
        nUp=thisNode.Machine;
    elseif isa(thisNode,'Stateflow.Object')
        nUp=up(thisNode);
    else
        nUp=[];
    end
