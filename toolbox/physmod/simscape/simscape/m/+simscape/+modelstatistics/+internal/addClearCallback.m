function addClearCallback(model)





    object=get_param(model,'Object');
    lAddCallback(object);

end

function lAddCallback(object)



    currentName=object.Name;
    cbName='SimscapeStatisticsViewerClearCallback';
    cbEvent='PreClose';


    if(object.hasCallback(cbEvent,cbName))
        object.removeCallback(cbEvent,cbName);
    end


    object.addCallback(cbEvent,cbName,@()(lClearCallback(currentName)));
end

function lClearCallback(model)


    simscape.modelstatistics.internal.clear(model);

end

