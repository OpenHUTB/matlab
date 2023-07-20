function schema





    pk=findpackage('sigio');
    pk1=findpackage('siggui');
    c=schema.class(pk,'export',pk1.findclass('actionclosedlg'));

    pk2=findpackage('sigutils');
    findclass(pk2,'vector');
    p=schema.prop(c,'Data','mxArray');
    set(p,'SetFunction',@lclsetdata,'GetFunction',@getdata,'AccessFlags.Init','Off');



    p=schema.prop(c,'privData','sigutils.vector');
    set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off',...
    'SetFunction',@setprivdata);



    p=schema.prop(c,'DefaultLabels','string vector');
    set(p,'SetFunction',@setdefaultlabels);

    p=schema.prop(c,'AvailableDestinations','MATLAB array');


    set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off',...
    'SetFunction',@setavaildes,'GetFunction',@getavaildes,'AccessFlags.AbortSet','Off');

    schema.prop(c,'ExcludeItem','ustring');

    findclass(pk,'abstractxpdestination');

    p=[...
    schema.prop(c,'PreviousState','mxArray')...
    ,schema.prop(c,'privAvailableDestinations','mxArray')...
    ,schema.prop(c,'privAvailableConstructors','mxArray')...
    ,schema.prop(c,'VectorChangedListener','handle.listener')...
    ];
    set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');

    p=schema.prop(c,'AvailableConstructors','MATLAB array');
    set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off',...
    'SetFunction',@setavailconstr,'GetFunction',@getavailconstr);


    p=schema.prop(c,'CurrentDestination','ustring');
    set(p,'SetFunction',@setcurrentdest);

    p=schema.prop(c,'Destination','sigio.abstractxpdestination');
    set(p,'SetFunction',@setdestination,'AccessFlags.PublicSet','off','AccessFlags.Init','Off');

    p=schema.prop(c,'Toolbox','ustring');
    set(p,'FactoryValue','signal');


    function out=lclsetdata(this,out)



        out=this.setdata(out);

