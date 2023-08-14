function propertyList=getCCPropertyList




    configData=RunTimeModule_config;
    editingMode=configData.EditingMode;

    propertyList=pm.sli.internal.ConfigsetProperty();
    propertyList(1).Name=editingMode.PropertyName;
    propertyList(1).IgnoreCompare=false;
    propertyList(1).Label=pm_message(editingMode.Label_msgid);
    propertyList(1).DataType=editingMode.DataType;
    propertyList(1).RowWithButton=false;



    propertyList(1).DisplayStrings={};
    propertyList(1).Group=pm_message(editingMode.Group_msgid);
    propertyList(1).GroupDesc=editingMode.GroupDesc;
    propertyList(1).Visible=editingMode.Visible;
    propertyList(1).Enabled=true;
    propertyList(1).DefaultValue='';
    propertyList(1).MatlabMethod='';

    propertyList(1).Listener.Event={'PropertyPostSet'};
    propertyList(1).Listener.Callback=@propertyCallback_editingMode;
    propertyList(1).Listener.CallbackTarget=@PmSli.RunTimeModule.getInstance;

    propertyList(1).SetFcn=@PmSli.RunTimeModule.propertySetFcn_editingMode;





