function[zcContextName,zcElementUUID]=getZCElementUUID(appName,elementUri)



    [~,mdlUri]=builtin('_get_sequence_diagram_uri_from_model_name',appName);
    [elementHandle,elementInstanceHandle]=...
    builtin('_get_sl_object_instance_handle_from_sequence_diagram_uri',...
    mdlUri,elementUri);...
%#ok<ASGLU> "elementInstanceHandle" is an array of handles to 






    archElem=systemcomposer.utils.getArchitecturePeer(elementHandle);
    zcElementUUID='';
    zcContextName='';
    if isa(archElem,'systemcomposer.architecture.model.design.BaseComponent')
        zcElementUUID=archElem.UUID;
        zcContextName=archElem.getTopLevelArchitecture.getName;
    end
end