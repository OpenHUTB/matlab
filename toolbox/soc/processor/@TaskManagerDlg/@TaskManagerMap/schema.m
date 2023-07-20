function schema





    hDeriveFromPackage=findpackage('TaskManagerDlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'TaskManagerBase');
    hPackage=findpackage('TaskManagerDlg');
    this=schema.class(hPackage,'TaskManagerMap',hDeriveFromClass);




    schema.prop(this,'allTaskData','string vector');
    schema.prop(this,'taskMappingData','MATLAB array');
    schema.prop(this,'selectedTableRow','double');
    schema.prop(this,'selectedTableCol','double');
    schema.prop(this,'eventList','MATLAB array');



    m=schema.method(this,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'taskManagerMapPreApplyCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(this,'tableCurrentItemChangedCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={'mxArray'};

    m=schema.method(this,'tableValueChangedCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray','MATLAB array'};
    s.OutputTypes={'mxArray'};
end
