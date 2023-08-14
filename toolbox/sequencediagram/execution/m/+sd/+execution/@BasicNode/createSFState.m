function newState=createSFState(obj,parent)




    obj.cachedSFState=Stateflow.State(parent);
    newState=obj.cachedSFState;
    obj.cachedSFState.Position=[obj.x,obj.y,obj.width,obj.height];
    obj.cachedSFState.LabelString=char(obj.getLabel);
end
