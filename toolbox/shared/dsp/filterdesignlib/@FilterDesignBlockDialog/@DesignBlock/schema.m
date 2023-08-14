function schema





    pk=findpackage('FilterDesignBlockDialog');
    c=schema.class(pk,'DesignBlock',...
    findclass(findpackage('dspdialog'),'DSPDDG'));

    findclass(pk,'AbstractDesign');

    schema.prop(c,'CurrentDesigner','MATLAB array');


    schema.prop(c,'Block','double');

    p=schema.prop(c,'ActiveTab','double');
    set(p,'SetFunction',@set_activetab,'GetFunction',@get_activetab);

    m=schema.method(c,'getDialogSchema');
    set(m.Signature,'varargin','off','InputTypes',{'handle','string'},...
    'OutputTypes',{'mxArray'});

    m=schema.method(c,'postApply');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{'bool','ustring'});

    m=schema.method(c,'preApply');
    set(m.Signature,'varargin','off','InputTypes',{'handle'},...
    'OutputTypes',{'bool','ustring'});


    function atab=set_activetab(this,atab)

        this.CurrentDesigner.ActiveTab=atab;


        function atab=get_activetab(this,~)

            atab=this.CurrentDesigner.ActiveTab;


