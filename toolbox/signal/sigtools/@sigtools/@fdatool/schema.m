function schema




    pk=findpackage('sigtools');
    spk=findpackage('siggui');


    c=schema.class(pk,'fdatool',spk.findclass('sigcontainer'));



    schema.prop(c,'Filename','ustring');




    p=[...
    schema.prop(c,'filterMadeBy','ustring');...
    schema.prop(c,'FileDirty','bool');...
    schema.prop(c,'MCode','mxArray');...
    ];
    set(p,'AccessFlags.PublicSet','off');

    p(2).FactoryValue=0;

    schema.prop(c,'LastLoadState','mxArray');




    schema.prop(c,'Filter','mxArray');

    p=[...
    schema.prop(c,'sessionType','ustring');...
    schema.prop(c,'ApplicationData','MATLAB array');...
    schema.prop(c,'Listeners','handle.listener vector');...
    schema.prop(c,'OverWrite','on/off');...
    schema.prop(c,'FigureTitle','ustring');...
    schema.prop(c,'SubTitle','ustring');...
    ];
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');



    p=schema.prop(c,'McodeType','mxArray');
    set(p,'FactoryValue',[]);

    p=schema.prop(c,'BaseMCode','mxArray');
    set(p,'FactoryValue',[]);

    schema.prop(c,'FvtoolHandle','mxArray');

    p=schema.prop(c,'MultirateMCode','mxArray');
    set(p,'FactoryValue',[]);

    p=schema.prop(c,'FxPtMCode','mxArray');
    set(p,'FactoryValue',[]);

    p=schema.prop(c,'DesignedCoefficientsInputVar','ustring');
    set(p,'FactoryValue','');

    p=schema.prop(c,'SysObjMCodeSupported','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'MCodeSupported','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'SysObjConvertStructLines','mxArray');
    set(p,'FactoryValue',{});

    p=schema.prop(c,'IsSOSConvertedMCode','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'IsSpecialCaseStructMCode','bool');
    set(p,'FactoryValue',false);


    schema.event(c,'FilterUpdated');
    schema.event(c,'FastFilterUpdated');
    schema.event(c,'NewAnalysis');
    schema.event(c,'DefaultAnalysis');
    schema.event(c,'FullViewAnalysis');
    schema.event(c,'Print');
    schema.event(c,'PrintPreview');
    schema.event(c,'CloseDialog');


