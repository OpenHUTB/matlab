function[sys,x0,str,ts]=AnimateHysteresis(t,x,u,flag,fluxinit,HTinit,indice,Ts,Tolerances,initialslope)







    persistent HT
    persistent M
mlock
    MLOOPS=200;

    if flag==0

        if Ts>0
            ts=[Ts,0];
            continuous=0;
            discrete=0;
            x0=[];
        else
            ts=[-1,1];
            continuous=0;
            discrete=0;
            x0=[];
        end

        output=2;
        input=1;

        sys=[continuous,discrete,output,input,0,1,1];

        HT{indice}=InitialTrajectory(HTinit,fluxinit,initialslope);


        M{indice}.sgn=HT{indice}.sgn_ini;
        M{indice}.Tr=HT{indice}.Tr_ini;
        M{indice}.I_inv=HT{indice}.I_inv_ini*ones(MLOOPS,1);
        M{indice}.F_inv=HT{indice}.F_inv_ini*ones(MLOOPS,1);
        M{indice}.I_old=0;
        M{indice}.F_old=-HT{indice}.Fs*HT{indice}.sgn_ini;
        M{indice}.Dk=HT{indice}.Dk_ini*ones(MLOOPS,1);
        M{indice}.Db=HT{indice}.Db_ini*ones(MLOOPS,1);
        M{indice}.dmax=HT{indice}.dmax_ini*ones(MLOOPS,1);
        M{indice}.dmin=zeros(MLOOPS,1);
        M{indice}.dp_2=0;
        M{indice}.P=0;
        M{indice}.B=0;
        M{indice}.Fa_dp2=0;
        M{indice}.Fb_dp2=0;


        M{indice}.I_inv(1)=HT{indice}.Is*HT{indice}.sgn_ini;
        M{indice}.F_inv(1)=HT{indice}.Fs*HT{indice}.sgn_ini;




        str=[];

    elseif flag==1

        sys=[];


    elseif flag==2

        if Ts>0
            [sys,M]=ComputeCurrent(M,u,x,HT{indice},indice,flag,Tolerances,MLOOPS);
            sys=[];


        else
            sys=[];



        end

    elseif flag==3



        if Ts<=0
            x=[];
        end

        [sys,Mcontinu]=ComputeCurrent(M,u,x,HT{indice},indice,flag,Tolerances,MLOOPS);

        if Ts>0
            M{indice}.I_old=sys(1);

        else
            M=Mcontinu;

        end

    elseif flag==9
        clear M
    end





    function[sys,M]=ComputeCurrent(M,u,x,HT,indice,flag,Tolerances,MLOOPS)


        F=u(1);

        sgn=M{indice}.sgn;
        Tr=M{indice}.Tr;
        I_inv=M{indice}.I_inv;
        F_inv=M{indice}.F_inv;
        I_old=M{indice}.I_old;

        if~isempty(x)
            I_old=x;
        end

        F_old=M{indice}.F_old;
        Dk=M{indice}.Dk;
        Db=M{indice}.Db;
        dmax=M{indice}.dmax;
        dmin=M{indice}.dmin;
        dp_2=M{indice}.dp_2;
        P=M{indice}.P;
        B=M{indice}.B;
        Fa_dp2=M{indice}.Fa_dp2;
        Fb_dp2=M{indice}.Fb_dp2;
        TEST1=0;
        TOL_F=Tolerances(1);
        TOL_I=Tolerances(2);





        if(((F>F_old)&(sgn==-1))|((F<F_old)&(sgn==1)))
            sgn=-sgn;
            D_inv=1;
        else
            D_inv=0;
        end




        if(D_inv==0)

            if(Tr>2)

                if(((F>F_inv(Tr-1))&(sgn==1))|((F<F_inv(Tr-1))&(sgn==-1)))

                    Tr=Tr-2;


                    if(F>Fa_dp2&F>Fb_dp2)|(F<Fa_dp2&F<Fb_dp2)
                        dp_2=0;
                    end
                end
            end
            if(abs(F)>HT.Fs)

                Tr=1;
            end




        else





            if((abs(F)>HT.Fs)|(abs(F)<=HT.Fs&abs(F_old)>HT.Fs))
                Tr=1;
                I_inv(Tr)=-HT.Is*sgn;
                F_inv(Tr)=-HT.Fs*sgn;

            elseif(Tr==1)
                Tr=2;
                I_inv(Tr)=I_old;
                F_inv(Tr)=F_old;
                dmax(Tr)=F_inv(Tr)-(-sgn*(HT.a*atan((HT.b*(-sgn)*I_inv(Tr))+HT.c)-(sgn*HT.alpha*I_inv(Tr))+HT.e));
                dmin(Tr)=0;
                Dk(Tr)=dmax(Tr)/(F_inv(Tr)-sgn*HT.Fs);
                Db(Tr)=dmax(Tr)-(Dk(Tr)*F_inv(Tr));

            elseif(Tr==2)
                Tr=3;
                I_inv(Tr)=I_old;
                F_inv(Tr)=F_old;

                dmax(Tr)=F_inv(Tr)-(-sgn*(HT.a*atan((HT.b*(-sgn)*I_inv(Tr))+HT.c)-(sgn*HT.alpha*I_inv(Tr))+HT.e));
                dmin(Tr)=0;
                Dk(Tr)=dmax(Tr)/(F_inv(Tr)-F_inv(Tr-1));
                Db(Tr)=dmax(Tr)-(Dk(Tr)*F_inv(Tr));

            elseif(Tr>2)


                if(abs(F_old-F_inv(Tr-1))<TOL_F);
                    dp_1=1;
                    Tr=Tr-1;
                else
                    dp_1=0;
                    Tr=Tr+1;

                    if(Tr>MLOOPS)


                        Erreur.identifier='SpecializedPowerSystems:HysteresisTool:MaxLoopReached';
                        Erreur.message='Maximum number of internal loops reached.';
                        psberror(Erreur);
                    end
                end

                I_inv(Tr)=I_old;
                F_inv(Tr)=F_old;


                dmax(Tr)=F_inv(Tr)-(-sgn*(HT.a*atan((HT.b*(-sgn)*I_inv(Tr))+HT.c)-(sgn*HT.alpha*I_inv(Tr))+HT.e));
                if(~dp_1)
                    dmin(Tr)=F_inv(Tr-1)-(-sgn*(HT.a*atan((HT.b*(-sgn)*I_inv(Tr-1))+HT.c)-(sgn*HT.alpha*I_inv(Tr-1))+HT.e));
                    Dk(Tr)=(dmin(Tr)-dmax(Tr))/(F_inv(Tr-1)-F_inv(Tr));
                    Db(Tr)=dmax(Tr)-(Dk(Tr)*F_inv(Tr));
                end
            end




            if Tr>1

                DELTA_F=F_inv(Tr)-F_inv(Tr-1);
                DELTA_I=I_inv(Tr)-I_inv(Tr-1);


                if((abs(DELTA_I)<TOL_I)&(dp_2==0))



                    P=DELTA_I/DELTA_F;

                    B=I_inv(Tr)-P*F_inv(Tr);

                    Fb_dp2=F_inv(Tr-1);
                    Fa_dp2=F_inv(Tr);

                    dp_2=1;
                end











            end
        end





        DLim=0;
        if(F>HT.Fs)

            I=HT.Is;

        elseif(F<-HT.Fs)

            I=-HT.Is;

        elseif(Tr==1)

            I=sgn*i_f(sgn*F,HT.Fj,HT.Mj,HT.Bj,HT.delFj,HT.Jmax);

        elseif(Tr>1)


            if dp_2
                I=P*F+B;
            else

                d=(Dk(Tr)*F)+Db(Tr);
                I=sgn*i_f(sgn*(F-d),HT.Fj,HT.Mj,HT.Bj,HT.delFj,HT.Jmax);


                Ie=-sgn*i_f(-sgn*F,HT.Fj,HT.Mj,HT.Bj,HT.delFj,HT.Jmax);
                if((((I<Ie)&(sgn==1))|((I>Ie)&(sgn==-1)))&~TEST1)
                    I=Ie;
                    DLim=1;
                end
            end
        end








        sys(1)=I;
        sys(2)=Tr;



        M{indice}.sgn=sgn;
        M{indice}.Tr=Tr;
        M{indice}.I_inv=I_inv;
        M{indice}.F_inv=F_inv;
        M{indice}.I_old=I;
        M{indice}.F_old=F;
        M{indice}.Dk=Dk;
        M{indice}.Db=Db;
        M{indice}.dmax=dmax;
        M{indice}.dmin=dmin;
        M{indice}.dp_2=dp_2;
        M{indice}.P=P;
        M{indice}.B=B;
        M{indice}.Fa_dp2=Fa_dp2;
        M{indice}.Fb_dp2=Fb_dp2;


        function out=i_f(X,XT,DFXT,BFXT,DELXT,NF)














            j=fix(((X-XT(1))/DELXT)+1);
            if(j<=1)
                j=1;
            elseif(j>NF-1)
                j=NF-1;
            end
            out=BFXT(j)+DFXT(j)*X;



            function out=i_f_sat(X,XT,DFXT,BFXT,DELXT,NF)














                j=fix(((X-XT(1))/DELXT)+1);

                if(j>NF-1)
                    j=NF-1;
                end
                out=BFXT(j)+DFXT(j)*X;


                function HT=InitialTrajectory(HT,fluxinit,initialslope);






                    switch HT.Segments
                    case 32
                        npuis=5;
                    case 64
                        npuis=6;
                    case 128
                        npuis=7;
                    case 256
                        npuis=8;
                    case 512
                        npuis=9;
                    end

                    sgn=1;
                    lim=HT.Segments/2;
                    dx=HT.Is/lim;

                    HT.Jmax=HT.Segments+1;


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
                                FNB=FNN;
                            else

                                break
                            end
                        end


                        IA=NA*dx;
                        IB=IA+dx;
                        FA=HT.Fj(J)+sgn*(HT.a*atan((HT.b*(-sgn)*IA)+HT.c)-(sgn*HT.alpha*IA)+HT.e);
                        FB=HT.Fj(J)+sgn*(HT.a*atan((HT.b*(-sgn)*IB)+HT.c)-(sgn*HT.alpha*IB)+HT.e);
                        Ij(J)=IA-(FA*dx/(FB-FA));


                        DLIMj(J)=HT.a*(atan(HT.b*Ij(J)+HT.c)+atan(HT.c-HT.b*Ij(J)))+(2*HT.e);

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

                    if((HT.Fr_ini>=HT.Fr)&(sgn==-1))
                        HT.Fr_ini=HT.Fr;
                        HT.Tr_ini=1;

                    elseif((HT.Fr_ini<=-HT.Fr)&(sgn==1))
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
                            FNB=FNN;
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


