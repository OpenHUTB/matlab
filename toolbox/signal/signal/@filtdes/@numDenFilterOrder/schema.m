function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'numDenFilterOrder');


    p=schema.prop(c,'Tag','ustring');
    p.AccessFlags.PublicSet='off';
    p.FactoryValue='numDenFilterOrder';


    p=schema.prop(c,'numOrder','spt_uint32');
    p.FactoryValue=8;

    p=schema.prop(c,'denOrder','spt_uint32');
    p.FactoryValue=6;
