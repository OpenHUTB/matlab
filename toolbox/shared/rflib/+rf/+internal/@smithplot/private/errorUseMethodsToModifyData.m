function errorUseMethodsToModifyData

    me=MException(...
    'smithplot:DataPropertiesAreReadOnly',...
    ['Frequency and data may be modified by using the\n'...
    ,'<a href="matlab:help rf.internal.smithplot.add">add</a> and '...
    ,'<a href="matlab:help rf.internal.smithplot.replace">replace</a> functions.'...
    ],'');
    throwAsCaller(me);
