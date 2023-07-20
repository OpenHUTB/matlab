function schema





    p=findpackage('Simulink');
    pparent=findpackage('tsdata');
    c=schema.class(p,'TimeInfo',findclass(pparent,'abstracttimemetadata'));
    c.Handle='off';


    p=schema.prop(c,'Start','MATLAB array');
    p.SetFunction=[];
    schema.prop(c,'End','MATLAB array');
    schema.prop(c,'Increment','MATLAB array');

    p=schema.prop(c,'IntervalLength','MATLAB array');
    p.FactoryValue=NaN;
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'Length','double');
    p.FactoryValue=0;
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.AbortSet='on';
    p.AccessFlags.Copy='off';
    p.AccessFlags.Serialize='off';
    p.GetFunction=@getlength;
    p=schema.prop(c,'Length_','double');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'Format','string');
    p.Visible='off';
    p=schema.prop(c,'Startdate','string');
    p.Visible='off';
    p=schema.prop(c,'Time_','MATLAB array');
    p.Visible='off';



