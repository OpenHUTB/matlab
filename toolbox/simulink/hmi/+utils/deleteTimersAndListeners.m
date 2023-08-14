

function deleteTimersAndListeners(obj)

    if(~isempty(obj.timer)&&isvalid(obj.timer))
        stop(obj.timer);
        delete(obj.timer);
    end

    for idx=1:length(obj.listeners)
        delete(obj.listeners(idx));
    end
    obj.listeners=[];

end