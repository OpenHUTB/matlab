function schema

    pk=findpackage('spcuddutils');
    c=schema.class(pk,'EventData',findclass(findpackage('handle'),'EventData'));

    schema.prop(c,'Data','mxArray');


