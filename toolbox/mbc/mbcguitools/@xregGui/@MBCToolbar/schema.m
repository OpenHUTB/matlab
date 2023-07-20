function schema





    pk=findpackage('xregGui');
    c=schema.class(pk,'MBCToolbar');


    p=schema.prop(c,'Children','handle vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';


    p=schema.prop(c,'hColors','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=xregGui.SystemColors;


    p=schema.prop(c,'hToolbarInterface','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';


    p=schema.prop(c,'ButtonSepCache','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=false(0);

    p=schema.prop(c,'ButtonVisCache','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=false(0);


    p=schema.prop(c,'NButtonsToRender','int');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'ButtonEdges','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'ButtonHeight','int');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';



    p=schema.prop(c,'CurrentButton','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';

    p=schema.prop(c,'CurrentButtonIndex','int');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.Listener='off';


    p=schema.prop(c,'DrawingEnabled','bool');
    p.AccessFlags.Listener='off';
    p.AccessFlags.Init='on';
    p.FactoryValue=true;
