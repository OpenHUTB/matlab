function propertyList=getCCPropertyList



    import pm.sli.internal.ConfigsetProperty;
    propertyList=ConfigsetProperty(...
    'Name','SimscapeCompileComponentReuse',...
    'Label','Reuse components during compilation',...
    'DataType','slbool',...
    'DefaultValue','off');

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.ScalableBuild;

end

function lMarkModelDirty(~,eventData)


    owner=eventData.AffectedObject;
    event=eventData.Type;
    switch event
    case 'PropertyPostSet'
        dirtyModel=pmsl_private('pmsl_markmodeldirty');
        dirtyModel(owner.getBlockDiagram);
    otherwise
        pm_assert(0,'unsupported callback in propertyCallback_errorOptions');
    end
end
