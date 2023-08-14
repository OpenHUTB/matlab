function removeListener(modelH,listenerCallback)






    modelObj=get_param(modelH,'slobject');


    currentListeners=i_getListeners(modelObj);

    for i=1:length(currentListeners)
        listener=currentListeners(i);
        if~isempty(findobj(listener))
            if isequal(listener.Callback,listenerCallback)
                delete(listener);
                modelObj.Listener_Storage_(i)=[];
            end
        end
    end


    function listeners=i_getListeners(modelObj)
        p=findprop(modelObj,'Listener_Storage_');
        if isempty(p)
            listeners=[];
        else
            listeners=modelObj.Listener_Storage_;
        end
