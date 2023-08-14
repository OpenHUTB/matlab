function schema




    hDeriveFromPackage=findpackage('DAStudio');
    hDeriveFromClass=findclass(hDeriveFromPackage,'Object');

    hCreateInPackage=findpackage('TflDesigner');
    clsH=schema.class(hCreateInPackage,'widgetnode',hDeriveFromClass);


    p=schema.prop(clsH,'Name','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'Tag','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'Type','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'Entries','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue={};

    p=schema.prop(clsH,'Source','handle');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=[];

    p=schema.prop(clsH,'Value','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'Visible','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=true;

    p=schema.prop(clsH,'Enabled','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=true;

    p=schema.prop(clsH,'ObjectMethod','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'MethodArgs','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'ArgDataTypes','mxArray');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

    p=schema.prop(clsH,'DialogRefresh','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'Editable','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'MultiSelect','bool');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue=false;

    p=schema.prop(clsH,'ToolTip','string');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p.FactoryValue='';

