function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'sosreorderdlg',pk.findclass('helpdialog'));

    p=schema.prop(c,'Filter','MATLAB array');
    set(p,'SetFunction',@setfilter);

    if isempty(findtype('sosreordertype'))
        schema.EnumType('sosreordertype',{'none','auto','up','down','custom'});
    end

    p=schema.prop(c,'ReorderType','sosreordertype');
    set(p,'GetFunction',@getreordertype,'SetFunction',@setreordertype);

    if isempty(findtype('sosscalingdlgNumConstraints'))
        schema.EnumType('sosscalingdlgNumConstraints',...
        {'None','Unit','Normalize','Powers of Two'});
    end

    if isempty(findtype('sosscalingdlgSVConstraints'))
        schema.EnumType('sosscalingdlgSVConstraints',...
        {'None','Unit','Powers of Two'});
    end

    p=schema.prop(c,'Filter','MATLAB array');
    set(p,'SetFunction',@setfilter);

    p=schema.prop(c,'Scale','on/off');


    p=schema.prop(c,'PNorm','posint');
    set(p,'AccessFlags.AbortSet','Off',...
    'Description','Scaling Norm',...
    'FactoryValue',1);

    p=schema.prop(c,'MaxNumerator','ustring');
    set(p,'FactoryValue','2','Description','Maximum Numerator');

    schema.prop(c,'NumeratorConstraint','sosscalingdlgNumConstraints');

    schema.prop(c,'OverflowMode','QToolOverflowMode');

    p=schema.prop(c,'ScaleValueConstraint','sosscalingdlgSVConstraints');
    set(p,'FactoryValue','Unit');

    p=schema.prop(c,'MaxScaleValue','ustring');
    set(p,'FactoryValue','2');

    p=[...
    schema.prop(c,'refFilter','MATLAB array');...
    schema.prop(c,'PropListener','handle.listener vector');...
    schema.prop(c,'isScaling','bool');...
    ];
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');

    schema.event(c,'NewFilter');


    function type=getreordertype(this,type)

        hoa=getcomponent(this,'tag','overall');
        type=get(hoa,'Selection');


        function type=setreordertype(this,type)

            hoa=getcomponent(this,'tag','overall');
            set(hoa,'Selection',type);


