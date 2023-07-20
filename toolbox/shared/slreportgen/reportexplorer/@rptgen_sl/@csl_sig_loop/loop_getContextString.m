function cs=loop_getContextString(c)






    switch lower(getContextType(rptgen_sl.appdata_sl,c,false))
    case 'model'
        cs='Signals in reported systems of current model';
    case 'system';
        cs='Signals in current system';
    case 'signal'
        cs='Current signal';
    case 'block'
        cs='Signals connected to current block';
    case{'annotation','configset'}
        cs='No signals';
    otherwise
        cs='Signals in all models';
    end
