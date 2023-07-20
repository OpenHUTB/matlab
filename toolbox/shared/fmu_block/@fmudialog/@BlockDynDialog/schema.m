function schema





    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('fmudialog');


    hThisClass=schema.class(hCreateInPackage,'BlockDynDialog',hDeriveFromClass);


    p=schema.prop(hThisClass,'DialogData','mxArray');
    p.FactoryValue={};


    m=schema.method(hThisClass,'getDialogSchema');
    set(m.Signature,'varargin','off','InputTypes',{'handle','string'},...
    'OutputTypes',{'mxArray'});



    m=schema.method(hThisClass,'iniDialogData');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'iniDynData');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'dialogCallback');
    set(m.Signature,'varargin','on','InputTypes',{'handle','handle','string','mxArray'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'onBrowseFMU');
    set(m.Signature,'varargin','off',...
    'InputTypes',{'handle','handle','string'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'getBlockDialogSchema');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{'mxArray'});

    m=schema.method(hThisClass,'getMaskDialogSchema');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{'mxArray'});

    m=schema.method(hThisClass,'fmuPreApplyCallback');
    set(m.Signature,'varargin','off','InputTypes',{'handle','handle'},...
    'OutputTypes',{'bool','string'});

    m=schema.method(hThisClass,'fmuCloseCallback');
    set(m.Signature,'varargin','off','InputTypes',{'handle','handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'createInputGroup');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'createOutputGroup');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{});

    m=schema.method(hThisClass,'fmuResetCallback');
    set(m.Signature,'varargin','off','InputTypes',{'handle','handle','string'},...
    'OutputTypes',{});

