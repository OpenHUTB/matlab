function propertyList=getCCPropertyList



    import pm.sli.internal.ConfigsetProperty;
    propertyList=ConfigsetProperty(...
    'Name','SimscapeUseOperatingPoints',...
    'Label','Initialize model using operating points',...
    'DataType','slbool',...
    'Visible',false,...
    'Group','OperatingPoint');

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.OperatingPoint;



    propertyList(end+1)=ConfigsetProperty(...
    'Name','SimscapeOperatingPoint',...
    'Label','Workspace variable name',...
    'DataType','string',...
    'Visible',false,...
    'Group','OperatingPoint',...
    'Enabled',@SSC.OperatingPoint.isOpNameEnabled);

    propertyList(end).Listener.Event={'PropertyPostSet'};
    propertyList(end).Listener.Callback=@lMarkModelDirty;
    propertyList(end).Listener.CallbackTarget=@SSC.OperatingPoint;

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
