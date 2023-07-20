function schema









    cEventData=findclass(findpackage('handle'),'EventData');
    c=schema.class(findpackage('Simulink'),'SigSelectorDDGSelectEvent',cEventData);


    schema.prop(c,'Dialog','MATLAB array');
    schema.prop(c,'TC','MATLAB array');


