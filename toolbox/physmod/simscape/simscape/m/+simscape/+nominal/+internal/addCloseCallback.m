function addCloseCallback(model)





    object=get_param(model,'Object');
    lAddCallback(object);

end

function lAddCallback(object)



    currentName=object.Name;
    cbName='SimscapeNominalViewerCloseCallback';
    cbEvent='PreClose';



    if(object.hasCallback(cbEvent,cbName))
        object.removeCallback(cbEvent,cbName);
    end


    object.addCallback(cbEvent,cbName,@()(lCloseCallback(currentName)));
end

function lCloseCallback(model)


    simscape.nominal.internal.close(model);
end