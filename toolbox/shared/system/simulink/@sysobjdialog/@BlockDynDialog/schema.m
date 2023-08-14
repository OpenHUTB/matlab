function schema




    mlock;

    DAStudio.Object;

    parentClass=findclass(findpackage('DVUnifiedFixptDlgDDG'),'SPCUniFixptDlgDDGBase');
    pk=findpackage('sysobjdialog');
    c=schema.class(pk,'BlockDynDialog',parentClass);

    p=schema.prop(c,'DialogManager','mxArray');
    set(p,'AccessFlags.Init','off');




    p=schema.prop(c,'System','string');
    set(p,'AccessFlags.Init','off',...
    'SetFunction',{@setToDialogManager,p},...
    'GetFunction',{@getFromDialogManager,p});

    m=schema.method(c,'getDialogSchema');
    set(m.Signature,'varargin','off','InputTypes',{'handle','string'},...
    'OutputTypes',{'mxArray'});

    m=schema.method(c,'propSet');
    set(m.Signature,'varargin','off',...
    'InputTypes',{'handle','handle','string','mxArray'},...
    'OutputTypes',{});

    m=schema.method(c,'callAction');
    set(m.Signature,'varargin','off',...
    'InputTypes',{'handle','handle','mxArray','string'},...
    'OutputTypes',{});

    m=schema.method(c,'propSetSystemObject');
    set(m.Signature,'varargin','off',...
    'InputTypes',{'handle','handle','mxArray','mxArray','mxArray'},...
    'OutputTypes',{});











    m=schema.method(c,'getDialogButtonSets');
    set(m.Signature,'varargin','off',...
    'InputTypes',{'handle'},'OutputTypes',{'mxArray'});

    function val=getFromDialogManager(this,~,prop)


        val=this.DialogManager.(prop.Name);

        function val=setToDialogManager(this,val,prop)


            this.DialogManager.(prop.Name)=val;


