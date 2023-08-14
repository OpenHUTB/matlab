function[N1,IS1]=ee_diode_coefficient(prmExp,i12,v12,IS,ec,i1,v1,rs,tmeas)



    q=1.602176487e-19;
    k=1.3806504e-23;
    phit=k*tmeas/q;
    switch prmExp
    case{'ee.enum.diode.expParam.useTwo','1'}
        v1r=v12(1)-i12(1)*rs;
        v2r=v12(2)-i12(2)*rs;
        N1=((v1r-v2r)/phit)/(log(i12(1)/i12(2)));
        IS1=0.5*(i12(1)/(exp(v1r/(N1*k*tmeas/q))-1)+i12(2)/(exp(v2r/(N1*k*tmeas/q))-1));
    case{'ee.enum.diode.expParam.useIsN','2'}
        N1=ec;
        IS1=IS;
    case{'ee.enum.diode.expParam.useIVIs','3'}
        v1r=v1-i1*rs;
        N1=v1r/(phit*log(i1/IS+1));
        IS1=IS;
    case{'ee.enum.diode.expParam.useIVN','4'}
        N1=ec;
        v1r=v1-i1*rs;
        IS1=i1/(exp(v1r/N1/k/tmeas*q)-1);
    otherwise
        pm_error('physmod:ee:library:NotFound','666');
    end