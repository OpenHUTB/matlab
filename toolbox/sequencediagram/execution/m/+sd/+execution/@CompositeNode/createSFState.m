function newState=createSFState(obj,parent)

    if(isempty(obj.parent)||(obj.getParentState~=obj.parent))

        obj.cachedSFState=Stateflow.State(parent);
        obj.cachedSFState.Position=[obj.x,obj.y,obj.width,obj.height];
        obj.cachedSFState.LabelString=obj.getLabel();

        sfprivate('set_is_subchart',obj.cachedSFState.id,1);

        currentParent=obj.cachedSFState;
        if obj.getParentState==obj&&obj.isParallel
            currentParent.cachedSFState.Decomposition='PARALLEL_AND';
        end
    else
        currentParent=parent;
    end

    newState=currentParent;


    for node=obj.basicNodes.toArray
        node.createSFState(currentParent);


        if(obj.getParentState==node)
            sfprivate('set_is_subchart',node.cachedSFState.id,1);

            if obj.isParallel
                node.cachedSFState.Decomposition='PARALLEL_AND';
            end
        end

    end


    for node=obj.children.toArray
        node.createSFState(obj.getParentState.cachedSFState);
    end


    for t=obj.transitions.toArray
        t.createSFTransition(currentParent);
    end

end
