function out=getSampleTimeMask(type)









    out=0;

    switch(type)
    case 'AllButConstant'
        out=28;
    case 'InheritedPeriodic'
        out=12;
    end


