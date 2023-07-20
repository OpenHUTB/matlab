function stfname=getSTFName(codegen)









    switch lower(codegen)
    case{'ert'}
        stfname='idelink_ert.tlc';
    case{'grt'}
        stfname='idelink_grt.tlc';
    otherwise
        stfname=[];
    end
