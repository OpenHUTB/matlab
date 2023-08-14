function schema()




    mlock;



    hCreateInPackage=findpackage('mpt');


    hThisClass=schema.class(hCreateInPackage,'RTWBuildCustomizer');




    if exist('make_rtw.m','file')==2||exist('make_rtw.p','file')==6
        hThisProp=schema.prop(hThisClass,'CodeGenEntry','string');
        hThisProp.AccessFlags.PublicSet='off';
        hThisProp.AccessFlags.PrivateSet='on';
        hThisProp.Visible='off';
        hThisProp.FactoryValue='';

        hThisProp=schema.prop(hThisClass,'CodeGenBeforeTLC','string');
        hThisProp.AccessFlags.PublicSet='off';
        hThisProp.AccessFlags.PrivateSet='on';
        hThisProp.Visible='off';
        hThisProp.FactoryValue='';

        hThisProp=schema.prop(hThisClass,'CodeGenAfterTLC','string');
        hThisProp.AccessFlags.PublicSet='off';
        hThisProp.AccessFlags.PrivateSet='on';
        hThisProp.Visible='off';
        hThisProp.FactoryValue='';

        hThisProp=schema.prop(hThisClass,'CodeGenBeforeMake','string');
        hThisProp.AccessFlags.PublicSet='off';
        hThisProp.AccessFlags.PrivateSet='on';
        hThisProp.Visible='off';
        hThisProp.FactoryValue='';

        hThisProp=schema.prop(hThisClass,'CodeGenAfterMake','string');
        hThisProp.AccessFlags.PublicSet='off';
        hThisProp.AccessFlags.PrivateSet='on';
        hThisProp.Visible='off';
        hThisProp.FactoryValue='';

        hThisProp=schema.prop(hThisClass,'CodeGenExit','string');
        hThisProp.AccessFlags.PublicSet='off';
        hThisProp.AccessFlags.PrivateSet='on';
        hThisProp.Visible='off';
        hThisProp.FactoryValue='';

    end

