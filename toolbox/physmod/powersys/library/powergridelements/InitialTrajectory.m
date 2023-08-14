function HT=InitialTrajectory(HT,fluxinit,initialslope)









    npuis=HT.npuis;
    sgn=1;
    lim=(2^npuis)/2;
    dx=HT.Is/lim;

    HT.Jmax=(2^npuis)+1;


    HT.delFj=(2*HT.Fs)/(HT.Jmax-1);

    for J=1:HT.Jmax
        HT.Fj(J)=-HT.Fs+((J-1)*HT.delFj);
















        NA=-lim;
        NB=lim;

        FNA=1;

        for L=1:npuis,
            NN=(NA+NB)/2;
            COUR=NN*dx;
            FNN=HT.Fj(J)+sgn*(HT.a*atan((HT.b*(-sgn)*COUR)+HT.c)-(sgn*HT.alpha*COUR)+HT.e);
            if((FNA*FNN)>0)
                NA=NN;
                FNA=FNN;
            elseif((FNA*FNN)<0)
                NB=NN;
                FNB=FNN;%#ok
            else

                break
            end
        end


        IA=NA*dx;
        IB=IA+dx;
        FA=HT.Fj(J)+sgn*(HT.a*atan((HT.b*(-sgn)*IA)+HT.c)-(sgn*HT.alpha*IA)+HT.e);
        FB=HT.Fj(J)+sgn*(HT.a*atan((HT.b*(-sgn)*IB)+HT.c)-(sgn*HT.alpha*IB)+HT.e);
        Ij(J)=IA-(FA*dx/(FB-FA));%#ok


        DLIMj(J)=HT.a*(atan(HT.b*Ij(J)+HT.c)+atan(HT.c-HT.b*Ij(J)))+(2*HT.e);%#ok

    end





    JmaxM1=HT.Jmax-1;
    for J=1:JmaxM1,
        HT.Mj(J)=(Ij(J+1)-Ij(J))/HT.delFj;
        HT.Bj(J)=Ij(J)-(HT.Mj(J)*HT.Fj(J));
    end


    HT.Mj(HT.Jmax)=0;
    HT.Bj(HT.Jmax)=0;

    HT.Fr_ini=fluxinit;
    HT.sgn_ini=initialslope;


    NPUIS=14;

    sgn=HT.sgn_ini;

    HT.Tr_ini=2;

    if((HT.Fr_ini>=HT.Fr)&&(sgn==-1))
        HT.Fr_ini=HT.Fr;
        HT.Tr_ini=1;

    elseif((HT.Fr_ini<=-HT.Fr)&&(sgn==1))
        HT.Fr_ini=-HT.Fr;
        HT.Tr_ini=1;

    elseif(abs(HT.Fr_ini)>HT.Fr)
        HT.Fr_ini=HT.Fr*sgn;

    end

    HT.Db=HT.Fs*(HT.Fr_ini*sgn+HT.Fr)/(HT.Fs*sgn-HT.Fr_ini);
    HT.Dk=-HT.Db*sgn/HT.Fs;

    LIM=(2^NPUIS)/2;
    NA=-LIM;
    NB=LIM;
    DX=HT.Is/LIM;

    FNA=sgn*(HT.a*atan((HT.b*sgn*(-HT.Is))+HT.c)+(sgn*HT.alpha*(-HT.Is))+HT.e)...
    -((-sgn*(HT.a*atan((HT.b*sgn*(HT.Is))+HT.c)...
    +(sgn*HT.alpha*(HT.Is))+HT.e)+HT.Db)/(1-HT.Dk));

    for L=1:NPUIS,
        NN=(NA+NB)/2;
        COUR=NN*DX;
        FNN=sgn*(HT.a*atan((HT.b*sgn*(COUR))+HT.c)+(sgn*HT.alpha*(COUR))+HT.e)...
        -((-sgn*(HT.a*atan((HT.b*sgn*(-COUR))+HT.c)...
        +(sgn*HT.alpha*(-COUR))+HT.e)+HT.Db)/(1-HT.Dk));

        if((FNA*FNN)>0)
            NA=NN;
            FNA=FNN;
        elseif((FNA*FNN)<0)
            NB=NN;
            FNB=FNN;%#ok
        else

            break
        end
    end


    IA=NA*DX;
    IB=IA+DX;

    FA=sgn*(HT.a*atan((HT.b*sgn*(IA))+HT.c)+(sgn*HT.alpha*(IA))+HT.e)...
    -((-sgn*(HT.a*atan((HT.b*sgn*(-IA))+HT.c)...
    +(sgn*HT.alpha*(-IA))+HT.e)+HT.Db)/(1-HT.Dk));

    FB=sgn*(HT.a*atan((HT.b*sgn*(IB))+HT.c)+(sgn*HT.alpha*(IB))+HT.e)...
    -((-sgn*(HT.a*atan((HT.b*sgn*(-IB))+HT.c)...
    +(sgn*HT.alpha*(-IB))+HT.e)+HT.Db)/(1-HT.Dk));

    HT.I_inv_ini=IA-(FA*DX/(FB-FA));



    HT.F_inv_ini=sgn*(HT.a*atan((HT.b*sgn*HT.I_inv_ini)+HT.c)+(sgn*HT.alpha*HT.I_inv_ini)+HT.e);



    HT.dmax_ini=(HT.Dk*HT.F_inv_ini)+HT.Db;



    HT.Dk_ini=HT.Dk;



    HT.Db_ini=HT.Db;


    HT.dmin_ini=0;
    HT.I_old_ini=0;
    HT.F_old_ini=0;

