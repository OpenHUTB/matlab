function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('SLSearchableDialog');


    hThisClass=schema.class(hCreateInPackage,'DDG_SearchableDialogBase',hDeriveFromClass);


    p=schema.prop(hThisClass,'DialogData','mxArray');
    p.FactoryValue={};

    p=schema.prop(hThisClass,'TimerObj','mxArray');
    p.FactoryValue={};



    m=schema.method(hThisClass,'getDialogSchema');
    set(m.Signature,'varargin','off','InputTypes',{'handle','string'},...
    'OutputTypes',{'mxArray'});



    m=schema.method(hThisClass,'applyFilter');
    set(m.Signature,'varargin','on','InputTypes',{'handle','handle','mxArray'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'dialogCallback');
    set(m.Signature,'varargin','on','InputTypes',{'handle','handle','string','mxArray'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'iniDialogData');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'iniDynData');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'refreshResultsImp');
    set(m.Signature,'varargin','off','InputTypes',{'handle','handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'setupSearchableDialogData');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'showCompleteList');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'str2logic');
    set(m.Signature,'varargin','off','InputTypes',{'handle','mxArray'},...
    'OutputTypes',{'mxArray'});



    m=schema.method(hThisClass,'createSearchableParamsContainer');
    set(m.Signature,'varargin','on','InputTypes',{'handle','mxArray'},...
    'OutputTypes',{'mxArray'});

    m=schema.method(hThisClass,'dialogCloseCallback');
    set(m.Signature,'varargin','off','InputTypes',{'handle','handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'dialogPreApplyCallback');
    set(m.Signature,'varargin','off','InputTypes',{'handle','handle'},...
    'OutputTypes',{'bool','string'});

    m=schema.method(hThisClass,'getBaseDialogStruct');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{'mxArray'});


