function propertyList=getCCPropertyList




    propertyList=pm.sli.internal.ConfigsetProperty();
    propertyList(1).Name='SimscapeNormalizeSystem';
    propertyList(1).IgnoreCompare=false;
    propertyList(1).Label='Normalize using nominal values';
    propertyList(1).DataType='slbool';



    propertyList(1).RowWithButton=true;
    propertyList(1).DisplayStrings={};
    propertyList(1).Group='System Scaling';
    propertyList(1).GroupDesc='';
    propertyList(1).Visible=true;
    propertyList(1).Enabled=true;
    propertyList(1).DefaultValue='';
    propertyList(1).MatlabMethod='NetworkEngine.SystemScaling.nominalPostSet';

    propertyList(1).Listener(1).Event={'PropertyPostSet'};
    propertyList(1).Listener(1).Callback=@lMarkModelDirty;
    propertyList(1).Listener(1).CallbackTarget=@NetworkEngine.SystemScaling;

    propertyList(1).SetFcn=@(a,b)(b);

    propertyList(end+1).Name='SimscapeNominalValues';
    propertyList(end).IgnoreCompare=false;
    propertyList(end).Label='Specify nominal values...';
    propertyList(end).DataType='string';
    propertyList(end).RowWithButton=true;
    propertyList(end).DisplayStrings={};
    propertyList(end).Group='System Scaling';
    propertyList(end).GroupDesc='';
    propertyList(end).Visible=true;
    propertyList(end).Enabled=@NetworkEngine.SystemScaling.isNominalValueViewerEnabled;
    propertyList(end).DefaultValue=simscape.nominal.internal.getDefaultNominalValues();
    propertyList(end).MatlabMethod='NetworkEngine.SystemScaling.openNominalViewer';

    propertyList(end).Listener(1).Event={'PropertyPostSet'};
    propertyList(end).Listener(1).Callback=@lMarkModelDirty;
    propertyList(end).Listener(1).CallbackTarget=@NetworkEngine.SystemScaling;

    propertyList(end).SetFcn=@(a,b)(b);


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





