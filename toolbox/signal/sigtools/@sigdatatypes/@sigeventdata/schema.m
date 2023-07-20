function schema





    pk=findpackage('sigdatatypes');

    cEventData=findclass(findpackage('handle'),'EventData');

    c=schema.class(pk,'sigeventdata',cEventData);


    schema.prop(c,'Data','MATLAB array');


