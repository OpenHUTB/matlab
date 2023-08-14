function schema





    hDeriveFromPackage=findpackage('TaskManagerAppDlg');
    hDeriveFromClass=findclass(hDeriveFromPackage,'TaskManagerAppBase');
    hPackage=findpackage('TaskManagerAppDlg');
    this=schema.class(hPackage,'TaskManagerAppMap',hDeriveFromClass);




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

    m=schema.method(this,'taskManagerAppMapPreApplyCallback');
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
