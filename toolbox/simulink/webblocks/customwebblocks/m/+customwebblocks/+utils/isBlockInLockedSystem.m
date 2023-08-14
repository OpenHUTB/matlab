

function result=isBlockInLockedSystem(obj)
    result=false;

    model=get_param(bdroot(obj.handle),'Object');
    if model.isLibrary
        result=strcmpi(model.Lock,'on');
        return;
    end

    parent=get_param(obj.Parent,'Object');
    while isa(parent,'Simulink.SubSystem')
        if parent.isLinked
            result=true;
            return;
        end
        parent=get_param(parent.Parent,'Object');
    end
end