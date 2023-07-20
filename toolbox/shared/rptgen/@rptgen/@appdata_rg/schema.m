function schema




    mlock;

    pkg=findpackage('rptgen');
    pkgRG=findpackage('rptgen');
    h=schema.class(pkg,'appdata_rg',pkgRG.findclass('appdata'));


    p=schema.prop(h,'ImageDirectory','ustring');
    p.FactoryValue='';
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getImageDirectory;
    p.setFunction=@setImageDirectory;


    p=schema.prop(h,'ImageDirectoryRelative','ustring');
    p.FactoryValue='';
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getImageDirectoryRelative;


    p=schema.prop(h,'ImageCounter','int32');
    p.FactoryValue=0;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';
    p.AccessFlags.PublicSet='off';


    p=schema.prop(h,'ImageDescriptions','MATLAB array');
    p.FactoryValue=[];
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';

    p=schema.prop(h,'ImageFileListName','ustring');
    p.FactoryValue='';
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';


    p=schema.prop(h,'CheckImageDirectory','bool');
    p.FactoryValue=true;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';


    p=schema.prop(h,'HasCustomPageBreaks','bool');
    p.FactoryValue=false;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';


    p=schema.prop(h,'Language','ustring');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';


    p=schema.prop(h,'HaltGenerate','bool');
    p.FactoryValue=true;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';


    p=schema.prop(h,'DebugMode','bool');
    p.FactoryValue=false;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';


    p=schema.prop(h,'RetainFO','bool');
    p.FactoryValue=false;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';


    p=schema.prop(h,'PostConvertImport','bool');
    p.FactoryValue=false;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';


    rptgen.prop(h,'GenerationStatus',{
    'unset','Unset'
    'report','Generating report'
    'none','None'
    },'unset','Status',1);


    p=schema.prop(h,'UpdateEditor','bool');
    p.FactoryValue=false;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.Visible='off';


    p=schema.prop(h,'RootComponent','handle');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getRootComponent;


    p=schema.prop(h,'Editor','handle');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';


    findclass(findpackage('rpt_xml'),'document');
    p=schema.prop(h,'CurrentDocument','rpt_xml.document');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getCurrentDocument;


    p=schema.prop(h,'DocbookSectionCounter','int32');
    p.FactoryValue=-1;
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getDocbookSectionCounter;


    p=schema.prop(h,'EntityManager','MATLAB array');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getEntityManager;


    p=schema.prop(h,'Language','ustring');
    p.AccessFlags.Init='on';
    p.AccessFlags.Reset='on';
    p.AccessFlags.AbortSet='off';
    p.getFunction=@getLanguage;










