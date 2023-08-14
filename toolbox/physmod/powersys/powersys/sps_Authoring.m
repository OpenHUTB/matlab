function FullMode=sps_Authoring(system)


    switch pmsl_modelparameter(system,'EditingMode','Full')
    case 'Restricted'
        FullMode=0;
    case 'Full'
        FullMode=1;
    end