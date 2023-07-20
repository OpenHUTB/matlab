function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'abstractDesignMethod');






    pk.findclass('abstractFilterType');
    p=[...
    schema.prop(c,'responseTypeSpecs','filtdes.abstractFilterType');...
    schema.prop(c,'availableTypes','MATLAB array');...
    schema.prop(c,'dynamicProps','schema.prop vector');...
    schema.prop(c,'dynamicPropsListener','handle.listener vector');...
    schema.prop(c,'listeners','handle.listener vector');...
    ];
    set(p,'AccessFlags.PublicSet','off','AccessFlags.PublicGet','off');


    p=schema.prop(c,'Tag','ustring');
    p.AccessFlags.PublicSet='off';

