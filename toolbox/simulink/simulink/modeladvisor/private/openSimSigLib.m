function openSimSigLib(subLib)






    isOk=ismember(subLib,{'Routing','Attributes'});
    assert(isOk,'Invalid call to openSimSigLib');

    cr=sprintf('\n');
    subLib=['simulink/Signal',cr,subLib];
    open_system('simulink');
    open_system(subLib);
