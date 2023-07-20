function newState=createSFState(obj,parent)






    if(obj.getParentState()~=obj.parent)

        obj.cachedSFState=Stateflow.State(parent);
        obj.cachedSFState.Position=[obj.x,obj.y,obj.width,obj.height];
        obj.cachedSFState.LabelString=obj.getLabel;

        if obj.basicNodes.Size>0
            sfprivate('set_is_subchart',obj.cachedSFState.id,1);

        end
        obj.cachedSFState.LabelString=char(obj.getLabel);
        currentParent=obj.cachedSFState;
    else
        currentParent=parent;
    end

    newState=currentParent;


    for node=obj.basicNodes.toArray
        node.createSFState(currentParent);
    end


    for t=obj.transitions.toArray
        t.createSFTransition(currentParent);
    end

end
