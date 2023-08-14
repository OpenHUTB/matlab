function schema







    pk=findpackage('xregtools');


    c=schema.class(pk,'MBrowser');


    p=schema.prop(c,'RootNode','MATLAB array');
    p.AccessFlags.PublicSet='off';
    schema.prop(c,'CurrentNode','MATLAB array');

    p=schema.prop(c,'Figure','MATLAB array');
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'GUIExists','bool');
    p.FactoryValue=false;p.AccessFlags.Init='on';
    p.AccessFlags.PublicSet='off';
    p=schema.prop(c,'GUILocked','bool');
    p.FactoryValue=false;p.AccessFlags.Init='on';
    schema.prop(c,'GUILockTime','double');

    p=schema.prop(c,'SelectedListItem','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.GetFunction=@getSelectedListItem;

    p=schema.prop(c,'ListView','MATLAB array');
    p.AccessFlags.PublicSet='off';




    p=schema.prop(c,'Hand','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';

    p=schema.prop(c,'ViewCardObj','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';
    p=schema.prop(c,'InfoCard','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';


    p=schema.prop(c,'ViewData','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';
    p=schema.prop(c,'ViewGUIDs','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';
    p=schema.prop(c,'ViewMenus','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';
    p=schema.prop(c,'ViewCurrent','MATLAB array');
    p.AccessFlags.PublicSet='on';p.AccessFlags.PublicGet='on';

    p=schema.prop(c,'ViewToolBar','MATLAB array');
    p.AccessFlags.PublicSet='on';p.AccessFlags.PublicGet='on';

    p=schema.prop(c,'SubFigures','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';
    p=schema.prop(c,'DefaultSupport','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';
    p.FactoryValue=struct('print',0,'validate',0,'newmodel',0,'export',1,'evaluate',0,'helptopics',{{}});
    p.AccessFlags.Init='on';
    p=schema.prop(c,'FileMod','bool');
    p.AccessFlags.Init='on';p.FactoryValue=false;
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';

    p=schema.prop(c,'ContextMenus','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';
    p.FactoryValue=struct('NewMenus',[],'DeleteMenus',[]);p.AccessFlags.Init='on';
    p=schema.prop(c,'DefaultTreeContext','MATLAB array');
    p.AccessFlags.PublicSet='off';


    p=schema.prop(c,'Listeners','MATLAB array');
    p.AccessFlags.PublicSet='off';p.AccessFlags.PublicGet='off';










