function schema












    mlock;

    pkg=findpackage('rptgen_sf');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'appdata_sf',pkgRG.findclass('appdata'));

    newSchema(h,'CurrentMachine','mxArray');
    newSchema(h,'CurrentChart','mxArray');
    newSchema(h,'CurrentChartBlock','mxArray');




    newSchema(h,'CurrentState','mxArray');
    newSchema(h,'CurrentObject','mxArray');
    newSchema(h,'Context','ustring','');
    newSchema(h,'LegibleSize','double',8.1);
    newSchema(h,'LegiblePictureObjects','MATLAB array',[]);









    typeTable={

    'Root','R',false,true,false
    'Machine','M',true,true,false
    'Chart','C',true,true,true
    'Data','D',true,false,false
    'State','S',true,true,true
    'Event','E',true,false,false
    'Transition','T',true,false,true
    'Junction','J',true,false,true
    'Target','Trgt',true,false,false
    'Box','B',true,true,true
    'Function','F',true,true,true
    'Editor','-',false,true,false
    'Clipboard','-',false,true,true

    'Annotation','N',true,false,true
    'TruthTable','TT',true,true,true
    'EMFunction','EM',true,true,true
    'SLFunction','SL',true,true,true
    'AtomicSubchart','AS',true,true,true
    'Port','P',true,false,true
    };




    typeTable=struct('Name',typeTable(:,1),...
    'Abbrev',typeTable(:,2),...
    'isReportable',typeTable(:,3),...
    'isParentable',typeTable(:,4),...
    'isGraphical',typeTable(:,5));

    p=newSchema(h,'TypeTable','MATLAB array',typeTable);
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.Default='off';
    p.AccessFlags.Reset='off';
    p.AccessFlags.Serialize='off';
    p.AccessFlags.Copy='on';


    function p=newSchema(h,name,dataType,factoryValue)

        p=schema.prop(h,name,dataType);
        p.AccessFlags.Init='on';
        p.AccessFlags.Reset='on';
        p.AccessFlags.AbortSet='off';

        if nargin>3
            p.FactoryValue=factoryValue;
        end
