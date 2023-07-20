function addRenameCallback(model)





    object=get_param(model,'Object');

    lAddCallback(object);

end

function lAddCallback(object)





    currentName=object.Name;
    bdHandle=object.Handle;
    cbName='SimscapeVariableViewerRenameCallback';
    cbEvent='PostNameChange';




    if(object.hasCallback(cbEvent,cbName))
        object.removeCallback(cbEvent,cbName);
    end


    object.addCallback(cbEvent,cbName,...
    @()(lRenameCallback(bdHandle,currentName)));
end

function lRenameCallback(bdHandle,oldName)



    simscape.state.internal.clear(oldName);


    currentName=get_param(bdHandle,'Name');
    simscape.state.internal.rename(oldName,currentName);


    object=get_param(bdHandle,'Object');
    lAddCallback(object);

end
