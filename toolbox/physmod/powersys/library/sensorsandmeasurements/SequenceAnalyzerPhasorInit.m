function sps=SequenceAnalyzerPhasorInit(seq)




    j=sqrt(-1);
    sps.a=exp(j*2*pi/3);
    sps.a2=exp(-j*2*pi/3);

    switch seq
    case 1,
        sps.PosOn=1;sps.NegOn=0;sps.ZeroOn=0;sps.SelectElement=1;
    case 2,
        sps.PosOn=0;sps.NegOn=1;sps.ZeroOn=0;sps.SelectElement=2;
    case 3,
        sps.PosOn=0;sps.NegOn=0;sps.ZeroOn=1;sps.SelectElement=3;
    case 4,
        sps.PosOn=1;
        sps.NegOn=1;sps.ZeroOn=1;sps.SelectElement=[1,2,3];
    end