function[TxParams,errorId]=solve(obj,dir)

    if nargin==1
        dir=pwd;
    end
    filename=fullfile(dir,'linpar.in8');


    [RLGC,errorId]=em.FieldSolver2d.Linpar(filename,'BackDoor',int8(1),int8(sum(obj.numTrace)));


    unit='meter';

    if strcmp(unit,'inch')
        meter2inch=39.3071;
        RLGC.R=RLGC.R/meter2inch;
        RLGC.C=RLGC.C/meter2inch;
        RLGC.L=RLGC.L/meter2inch;
    end

    TxParams.RLGC=RLGC;


    TxParams.Tpd=sqrt(TxParams.RLGC.L(1,1)*TxParams.RLGC.C(1,1));


    if sum(obj.numTrace)>1&&rem(sum(obj.numTrace),2)==0
        idx=(sum(obj.numTrace)+2)/2;
        L11=TxParams.RLGC.L(idx,idx);
        L12=TxParams.RLGC.L(idx,idx-1);
        C11=TxParams.RLGC.C(idx,idx);
        C12=TxParams.RLGC.C(idx,idx-1);

        TxParams.Zodd=sqrt((L11-L12)/(C11+abs(C12)));
        TxParams.Zeven=sqrt((L11+L12)/(C11-abs(C12)));

        TxParams.Zdiff=2*TxParams.Zodd;

        if abs(TxParams.Zodd-TxParams.Zeven)<eps
            TxParams.Rdiff=(2*TxParams.Zodd*TxParams.Zeven)/(TxParams.Zeven-TxParams.Zodd);
        end
    end

end