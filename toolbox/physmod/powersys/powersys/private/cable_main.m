function[R,L,G,C]=cable_main(cs,f)










    cs.MU0=1.2566e-06;
    cs.EPS0=8.8542e-12;
    cs.earth.MUE=1;
    cs.earth.FG0=0;



    cs.phases=[];
    cs.Isheath=[];
    ConductorPosition=0;
    for cable=1:length(cs.cables)
        NumberOfConductors=length(cs.types(cs.cables(cable).type).conductors);
        for conductor=1:NumberOfConductors
            cs.cables(cable).conductor(conductor).R_in=cs.types(cs.cables(cable).type).conductors(conductor).R_in;
            cs.cables(cable).conductor(conductor).R_out=cs.types(cs.cables(cable).type).conductors(conductor).R_out;
            cs.cables(cable).conductor(conductor).Rho=cs.types(cs.cables(cable).type).conductors(conductor).Rho;
            cs.cables(cable).conductor(conductor).MUE=cs.types(cs.cables(cable).type).conductors(conductor).MUE;
            cs.cables(cable).conductor(conductor).MUE_IN=cs.types(cs.cables(cable).type).conductors(conductor).MUE_IN;
            cs.cables(cable).conductor(conductor).EPS_IN=cs.types(cs.cables(cable).type).conductors(conductor).EPS_IN;
            cs.cables(cable).conductor(conductor).LFCT_IN=cs.types(cs.cables(cable).type).conductors(conductor).LFCT_IN;
            cs.phases(end+1)=cs.cables(cable).phase(conductor);
            if conductor==2

                cs.Isheath(end+1)=ConductorPosition+2;
                ConductorPosition=ConductorPosition+NumberOfConductors;
            elseif conductor>2
                if~isequal(0,cs.cables(cable).phase(conductor))


                    cs.crossbondTheSheaths=0;
                end
            end
        end
    end

    cs=PipeDistanceSAndAngles(cs);
    cs=ComputeInternalImpedances(cs,f);
    cs=ComputEarthImpedances(cs,f);
    cs=loop_phase_impedances(cs);
    cs=loop_phase_admitances(cs,f);


    if cs.crossbondTheSheaths
        cs.Zphase=crossbond(cs,cs.Zphase);
        cs.Yphase=crossbond(cs,cs.Yphase);
        cs.Pphase=inv(imag(cs.Yphase));
    end

    cs.Zphase=reorder_phase_matrix(cs,cs.Zphase,1);
    cs.Yphase=reorder_phase_matrix(cs,cs.Yphase,0);
    cs.Pphase=reorder_phase_matrix(cs,cs.Pphase,0);

    R=real(cs.Zphase)*1000;
    L=imag(cs.Zphase)*1000/(2*pi*f);
    G=real(cs.Yphase)*1000;
    C=imag(cs.Yphase)*1000/(2*pi*f);


    N=size(C,1);
    col_avg=mean(abs(G),1);
    for i=1:N
        G(i,:)=G(i,:).*(abs(G(i,:)/col_avg(i))>1e-6);
    end
    col_avg=mean(abs(C),1);
    for i=1:N
        C(i,:)=C(i,:).*(abs(C(i,:)/col_avg(i))>1e-6);
    end


    R=(R+R')/2;
    L=(L+L')/2;
    G=(G+G')/2;
    C=(C+C')/2;

    function cs=PipeDistanceSAndAngles(cs)
        switch cs.configuration
        case 'pipe'
            for cable=1:length(cs.cables)
                cs.distance(cable,cable)=cs.cables(cable).Vdist;
                angle=(2*pi)*cs.cables(cable).Hdist/(360.0);
                if angle>(2*pi)
                    angle=angle-2*pi;
                end
                cs.angle(cable,cable)=angle;
                for othercable=cable+1:length(cs.cables)
                    angle=(2*pi)*abs(cs.cables(cable).Hdist-cs.cables(othercable).Hdist)/(360.0);
                    if angle>(2*pi)
                        angle=angle-2*pi;
                    end
                    if angle>pi
                        angle=2*pi-angle;
                    end
                    cs.distance(cable,othercable)=sqrt(cs.cables(cable).Vdist^2+cs.cables(othercable).Vdist^2-2*cs.cables(cable).Vdist*cs.cables(othercable).Vdist*cos(angle));
                    cs.angle(cable,othercable)=angle;
                    cs.distance(othercable,cable)=cs.distance(cable,othercable);
                    cs.angle(othercable,cable)=cs.angle(cable,othercable);
                end
            end




            cs.phases(end+1)=cs.pipe.phase;
        end

        function cs=ComputeInternalImpedances(cs,f)



            w=2*pi*f;
            for cable=1:length(cs.cables)
                NumberOfConductors=length(cs.cables(cable).conductor);
                for conductor=1:NumberOfConductors
                    mu=cs.cables(cable).conductor(conductor).MUE*cs.MU0;
                    rho=cs.cables(cable).conductor(conductor).Rho;
                    Rin=cs.cables(cable).conductor(conductor).R_in;
                    Rout=cs.cables(cable).conductor(conductor).R_out;
                    cs.cables(cable).conductor(conductor).Rdc=rho/(pi*((Rout)^2-(Rin)^2));

                    if f<=0.0
                        cs.cables(cable).conductor(conductor).Zin=cs.cables(cable).conductor(conductor).Rdc;
                        cs.cables(cable).conductor(conductor).Zout=cs.cables(cable).conductor(conductor).Rdc;
                        cs.cables(cable).conductor(conductor).Zmut=cs.cables(cable).conductor(conductor).Rdc;
                    else
                        m=sqrt(1i*w*mu./rho);
                        [cs.cables(cable).conductor(conductor).Zin,...
                        cs.cables(cable).conductor(conductor).Zout,...
                        cs.cables(cable).conductor(conductor).Zmut]=skin_cable(m,rho,Rin,Rout);
                    end

                    muin=cs.cables(cable).conductor(conductor).MUE_IN*cs.MU0;
                    Rin_ins=Rout;
                    if conductor==NumberOfConductors
                        Rout_ins=cs.cables(cable).R_out;
                    else
                        Rout_ins=cs.cables(cable).conductor(conductor+1).R_in;
                    end
                    cs.cables(cable).conductor(conductor).Zins=((1i*w*muin)/(2*pi))*log(Rout_ins/Rin_ins);
                end
            end

            switch cs.configuration
            case 'pipe'
                mu=cs.pipe.MUE*cs.MU0;
                rho=cs.pipe.Rho;
                m=sqrt(1i*w*mu./rho);
                cs.pipe.Rdc=rho/(pi*((cs.pipe.R_out)^2-(cs.pipe.R_in)^2));

                if f<=0.0
                    cs.pipe.Zin=cs.pipe.Rdc;
                    cs.pipe.Zout=cs.pipe.Rdc;
                    cs.pipe.Zmut=cs.pipe.Rdc;
                else
                    [cs.pipe.Zin,cs.pipe.Zout,cs.pipe.Zmut]=skin_cable(m,rho,cs.pipe.R_in,cs.pipe.R_out);
                end


                if(cs.pipe.phase==0)
                    cs.pipe.Zins=0;
                else
                    mu=cs.pipe.MUE_out*cs.MU0;
                    cs.pipe.Zins=((1i*w*mu)/(2*pi))*log(cs.pipe.R_ext/cs.pipe.R_out);
                end


                for cable=1:length(cs.cables)
                    NumberOfConductors=length(cs.cables(cable).conductor);
                    mu=cs.MU0;
                    Rin=cs.cables(cable).R_out;
                    q=cs.pipe.R_in;
                    di=cs.cables(cable).Vdist;
                    cs.cables(cable).conductor(NumberOfConductors).Zinspip=((1i*w*mu)/(2*pi))*log((q/Rin)*(1-(di/q)^2));
                end
            end

            function cs=ComputEarthImpedances(cs,f)





                w=2*pi*f;

                if f<=0.0
                    cs.pipe.Zearth=0.0;
                    cs.Zearth=zeros(length(cs.cables));
                else
                    switch cs.configuration
                    case 'pipe'
                        rho=cs.pipe.Rho;
                        mu=cs.pipe.MUE*cs.MU0;
                        m=sqrt(1i*w*mu./rho);
                        nb_sum=9;

                        h=cs.pipe.V_dpth;
                        R=cs.pipe.R_ext;
                        m_earth=sqrt(1i*w*cs.earth.MUE*cs.MU0/cs.groundResistivity);

                        if(h<0)
                            hp=abs(h);
                            cs.pipe.Zearth=((cs.groundResistivity*m_earth^2)/(2*pi))*(besselk(0,m_earth*R)+(2/(4+m_earth^2*R^2))*exp(-2*hp*m_earth));

                        else
                            cs.pipe.Zearth=Zearth(cs,0,w,h,R,0,0);
                        end
                        for cable=1:length(cs.cables)

                            q=cs.pipe.R_in;
                            di=cs.cables(cable).Vdist;





                            cs.Zearth(cable,cable)=(1i*w*mu/(2*pi))*(2*sum_self_pipe(nb_sum,m,q,di,cs.pipe.MUE))+...
                            cs.pipe.Zin+cs.cables(cable).conductor(length(cs.cables(cable).conductor)).Zinspip;

                            for othercable=cable+1:length(cs.cables)
                                dk=cs.cables(othercable).Vdist;
                                dik=cs.distance(cable,othercable);
                                ang=cs.angle(cable,othercable);


                                cs.Zearth(cable,othercable)=(1i*w*cs.MU0/(2*pi))*(log(q/dik)+sum_mutual_pipe(nb_sum,m,q,di,dk,ang,cs.pipe.MUE))+...
                                cs.pipe.Zin;
                                cs.Zearth(othercable,cable)=cs.Zearth(cable,othercable);
                            end
                        end
                    otherwise
                        mu=cs.earth.MUE*cs.MU0;
                        m=sqrt(1i*w*mu./cs.groundResistivity);
                        for cable=1:length(cs.cables)

                            x=cs.cables(cable).Hdist;
                            h=cs.cables(cable).Vdist;
                            R=cs.cables(cable).R_out;

                            if(h<0)
                                hp=abs(h);
                                cs.Zearth(cable,cable)=((cs.groundResistivity*m^2)/(2*pi))*(besselk(0,m*R)+(2/(4+m^2*R^2))*exp(-2*hp*m));

                            else
                                cs.Zearth(cable,cable)=Zearth(cs,0,cs.groundResistivity,w,h,R,0,0);
                            end

                            for othercable=cable+1:length(cs.cables)
                                x1=cs.cables(othercable).Hdist;
                                y=cs.cables(othercable).Vdist;
                                d=sqrt((x1-x)^2+(h-y)^2);
                                l=h+y;

                                if(y<0)
                                    hp=abs(l);
                                    cs.Zearth(cable,othercable)=((cs.groundResistivity*m^2)/(2*pi))*(besselk(0,m*d)+(2/(4+m^2*(x1-x)^2))*exp(-hp*m));

                                else
                                    cs.Zearth(cable,othercable)=Zearth(cs,1,cs.groundResistivity,w,h,y,x,x1);
                                end
                                cs.Zearth(othercable,cable)=cs.Zearth(cable,othercable);
                            end
                        end
                    end
                end

                function cs=loop_phase_impedances(cs)


                    for cable=1:length(cs.cables)
                        NumberOfConductors=length(cs.cables(cable).conductor);
                        cs.cables(cable).Zloop=zeros(NumberOfConductors,NumberOfConductors);
                        for conductor=1:NumberOfConductors
                            if conductor<NumberOfConductors
                                cs.cables(cable).Zloop(conductor,conductor)=...
                                cs.cables(cable).conductor(conductor).Zout+...
                                cs.cables(cable).conductor(conductor).Zins+...
                                cs.cables(cable).conductor(conductor+1).Zin;
                                cs.cables(cable).Zloop(conductor,conductor+1)=...
                                -cs.cables(cable).conductor(conductor+1).Zmut;
                                cs.cables(cable).Zloop(conductor+1,conductor)=cs.cables(cable).Zloop(conductor,conductor+1);
                            else
                                cs.cables(cable).Zloop(conductor,conductor)=...
                                cs.cables(cable).conductor(conductor).Zout+...
                                cs.cables(cable).conductor(conductor).Zins+...
                                cs.Zearth(cable,cable);
                            end
                        end



                        trans_mat=tril(ones(NumberOfConductors,NumberOfConductors),0);
                        cs.cables(cable).Zphase=trans_mat.'*cs.cables(cable).Zloop*trans_mat;
                    end

                    cs.Zphase=[];
                    for cable=1:length(cs.cables)
                        Zphase_cell(cable,cable)={cs.cables(cable).Zphase};%#ok
                        for index=cable+1:length(cs.cables)
                            Ztemp=cs.Zearth(cable,index)*ones(length(cs.cables(cable).conductor),length(cs.cables(index).conductor));
                            Zphase_cell(cable,index)={Ztemp};
                            Zphase_cell(index,cable)={Ztemp.'};
                        end

                        cs.Zphase=[cs.Zphase;Zphase_cell{cable,:}];
                    end

                    switch cs.configuration
                    case 'pipe'
                        nb_element=length(cs.Zphase);

                        Zm=cs.pipe.Zmut;
                        Zs=cs.pipe.Zout+cs.pipe.Zins+cs.pipe.Zearth;
                        Ze=Zs-Zm;
                        Z=Zs-2*Zm;

                        cs.Zphase(nb_element+1,:)=zeros(1,nb_element);
                        cs.Zphase(:,nb_element+1)=zeros(nb_element+1,1);

                        Zmat=Z*ones(nb_element);
                        Zmat(nb_element+1,:)=Ze*ones(1,nb_element);
                        Zmat(:,nb_element+1)=Ze*ones(nb_element+1,1);
                        Zmat(nb_element+1,nb_element+1)=Zs;
                        cs.pipe.Zmat=Zmat;
                        cs.Zphase=cs.Zphase+Zmat;
                    end

                    function cs=loop_phase_admitances(cs,f)


                        nb_sum=19;
                        w=2*pi*f;
                        wg=2*pi*(f+cs.earth.FG0);
                        for cable=1:length(cs.cables)
                            NumberOfConductors=length(cs.cables(cable).conductor);
                            cs.cables(cable).Yloop=[];
                            cs.cables(cable).Gloop=[];
                            cs.cables(cable).Ploop=[];
                            for conductor=1:NumberOfConductors
                                Rout=cs.cables(cable).conductor(conductor).R_out;

                                epsin=cs.cables(cable).conductor(conductor).EPS_IN*cs.EPS0;
                                lfct=cs.cables(cable).conductor(conductor).LFCT_IN;
                                Rin_ins=Rout;
                                if conductor==NumberOfConductors
                                    Rout_ins=cs.cables(cable).R_out;
                                else
                                    Rout_ins=cs.cables(cable).conductor(conductor+1).R_in;
                                end
                                Capacitance=(2*pi*epsin)/(log(Rout_ins/Rin_ins));
                                potential=1/Capacitance;
                                Conductance=Capacitance*lfct;
                                Yadm=wg*Conductance+1i*w*Capacitance;
                                cs.cables(cable).conductor(conductor).Yins=Yadm;
                                cs.cables(cable).Yloop=[cs.cables(cable).Yloop,Yadm];
                                cs.cables(cable).Gloop=[cs.cables(cable).Gloop,potential*lfct];
                                cs.cables(cable).Ploop=[cs.cables(cable).Ploop,potential];
                            end

                            cs.cables(cable).Yloop=diag(cs.cables(cable).Yloop);
                            cs.cables(cable).Gloop=diag(cs.cables(cable).Gloop);
                            cs.cables(cable).Ploop=diag(cs.cables(cable).Ploop);



                            trans_pot=tril(ones(NumberOfConductors,NumberOfConductors),0);
                            trans_mat=inv(trans_pot).';
                            cs.cables(cable).Yphase=trans_mat.'*cs.cables(cable).Yloop*trans_mat;
                            cs.cables(cable).Gphase=trans_pot.'*cs.cables(cable).Gloop*trans_pot;
                            cs.cables(cable).Pphase=trans_pot.'*cs.cables(cable).Ploop*trans_pot;
                        end

                        cs.Yphase=[];
                        cs.Pphase=[];
                        cs.Gphase=[];
                        for cable=1:length(cs.cables)
                            NumberOfConductors=length(cs.cables(cable).conductor);
                            Yphase_cell(cable,cable)={cs.cables(cable).Yphase};


                            switch cs.configuration
                            case 'pipe'
                                eps=cs.pipe.EPS_in*cs.EPS0;
                                Ri=cs.cables(cable).R_out;
                                q=cs.pipe.R_in;
                                di=cs.cables(cable).Vdist;
                                pii=(1/(2*pi*eps))*log((q/Ri)*(1-(di/q)^2));
                                cs.cables(cable).Pphase=cs.cables(cable).Pphase+pii*ones(NumberOfConductors);
                                cs.cables(cable).Gphase=cs.cables(cable).Gphase+pii*cs.pipe.LFCT_out*ones(NumberOfConductors);
                                Gphase_cell(cable,cable)={cs.cables(cable).Gphase};
                            case 'aerial'

                                eps=cs.EPS0;
                                Ri=cs.cables(cable).R_out;
                                di=cs.cables(cable).Vdist;
                                pii=(1/(2*pi*eps))*log(2*di/Ri);
                                cs.cables(cable).Pphase=cs.cables(cable).Pphase+pii*ones(NumberOfConductors);
                            end
                            Pphase_cell(cable,cable)={cs.cables(cable).Pphase};
                            for othercable=cable+1:length(cs.cables)
                                NumberOfOtherConductors=length(cs.cables(othercable).conductor);

                                Ytemp=zeros(NumberOfConductors,NumberOfOtherConductors);
                                Yphase_cell(cable,othercable)={Ytemp};
                                Yphase_cell(othercable,cable)={Ytemp.'};
                                switch cs.configuration
                                case 'pipe'
                                    sum=0;
                                    for k=1:nb_sum
                                        arg=(cs.distance(cable,cable)*cs.distance(othercable,othercable)/q^2)^k*...
                                        cos(k*cs.angle(cable,othercable))/k;
                                        sum=sum+arg;
                                    end
                                    pij=(log(q/cs.distance(cable,othercable))-sum)/(2*pi*eps);
                                    Ptemp=pij*ones(NumberOfConductors,NumberOfOtherConductors);
                                    Gtemp=pij*cs.pipe.LFCT_out*ones(NumberOfConductors,NumberOfOtherConductors);
                                    Gphase_cell(cable,othercable)={Gtemp};
                                    Gphase_cell(othercable,cable)={Gtemp.'};
                                case 'aerial'

                                    a=cs.cables(othercable).Hdist-cs.cables(cable).Hdist;
                                    y1=cs.cables(othercable).Vdist;
                                    y2=cs.cables(cable).Vdist;
                                    dij=sqrt(a^2+(y1-y2)^2);
                                    Dij=sqrt(a^2+(y1+y2)^2);

                                    pij=log(Dij/dij)/(2*pi*cs.EPS0);
                                    Ptemp=pij.*ones(NumberOfConductors,NumberOfOtherConductors);
                                case 'underground'
                                    Ptemp=zeros(NumberOfConductors,NumberOfOtherConductors);
                                end
                                Pphase_cell(cable,othercable)={Ptemp};
                                Pphase_cell(othercable,cable)={Ptemp.'};
                            end

                            cs.Yphase=[cs.Yphase;Yphase_cell{cable,:}];
                            switch cs.configuration
                            case 'pipe'
                                cs.Gphase=[cs.Gphase;Gphase_cell{cable,:}];
                            end

                            cs.Pphase=[cs.Pphase;Pphase_cell{cable,:}];
                        end

                        switch cs.configuration
                        case 'pipe'
                            eps=cs.pipe.EPS_out*cs.EPS0;
                            nb_element=length(cs.Pphase);
                            Pot=(1/(2*pi*eps))*log(cs.pipe.R_ext/cs.pipe.R_out);
                            Gpipe=Pot*cs.pipe.LFCT_out;

                            cs.Pphase(nb_element+1,:)=zeros(1,nb_element);
                            cs.Pphase(:,nb_element+1)=zeros(nb_element+1,1);
                            Pmat=Pot*ones(nb_element+1);
                            cs.Pphase=cs.Pphase+Pmat;

                            cs.Gphase(nb_element+1,:)=zeros(1,nb_element);
                            cs.Gphase(:,nb_element+1)=zeros(nb_element+1,1);
                            Gmat=Gpipe*ones(nb_element+1);
                            cs.Gphase=cs.Gphase+Gmat;
                            cs.Yphase(nb_element+1,:)=zeros(1,nb_element);
                            cs.Yphase(:,nb_element+1)=zeros(nb_element+1,1);
                            Adm=inv(cs.Gphase-1i*cs.Pphase);
                            Adm=Adm.*(abs(Adm)>1e-20);
                            cs.Yphase=wg*real(Adm)+1i*w*imag(Adm);
                        case 'aerial'

                            Cond_mat=real(cs.Yphase);

                            Capacitance=inv(cs.Pphase);
                            cs.Yphase=Cond_mat+1i*w*Capacitance;
                        end

                        function phase_mat=crossbond(cs,phase_mat)

                            average_col=mean(phase_mat(:,cs.Isheath),2);
                            sum_col=sum(phase_mat(:,cs.Isheath),2);

                            phase_diag=diag(phase_mat);

                            ZSM=sum(sum_col(cs.Isheath));

                            ZSD=sum(phase_diag(cs.Isheath));

                            ZSM=(ZSM-ZSD)/(length(cs.cables)*(length(cs.cables)-1));
                            ZSD=ZSD/length(cs.cables);
                            average_col(cs.Isheath)=ZSM;

                            for index=1:length(cs.Isheath)
                                phase_mat(:,cs.Isheath(index))=average_col;
                                phase_mat(cs.Isheath(index),:)=average_col.';
                                phase_mat(cs.Isheath(index),cs.Isheath(index))=ZSD;
                            end

                            function phase_mat=reorder_phase_matrix(cs,phase_mat,type)



                                NPHS=max(cs.phases);
                                NbTot=length(phase_mat);
                                if isequal(phase_mat,zeros(NbTot))
                                    phase_mat=zeros(NPHS);
                                    return;
                                end

                                KR=NPHS+1;
                                for index=0:NPHS
                                    x=find(cs.phases==index);
                                    if index==0
                                        WRK(KR:KR+length(x)-1,:)=phase_mat(x,:);
                                        KR=KR+length(x);
                                    else
                                        WRK(index,:)=phase_mat(x(1),:);
                                        if length(x)>1
                                            for KK=2:length(x)
                                                WRK(KR,:)=phase_mat(x(KK),:)-WRK(index,:);
                                                KR=KR+1;
                                            end
                                        end
                                    end
                                end
                                KR=NPHS+1;

                                for index=0:NPHS
                                    x=find(cs.phases==index);
                                    if index==0
                                        phase_mat(:,KR:KR+length(x)-1)=WRK(:,x);
                                        KR=KR+length(x);
                                    else
                                        phase_mat(:,index)=WRK(:,x(1));
                                        if length(x)>1
                                            for KK=2:length(x)
                                                phase_mat(:,KR)=WRK(:,x(KK))-phase_mat(:,index);
                                                KR=KR+1;
                                            end
                                        end
                                    end
                                end


                                if NPHS<NbTot
                                    if type==1

                                        phase_mat=phase_mat(1:NPHS,1:NPHS)-(phase_mat(1:NPHS,NPHS+1:NbTot)/phase_mat(NPHS+1:NbTot,NPHS+1:NbTot))*phase_mat(NPHS+1:NbTot,1:NPHS);
                                    else
                                        phase_mat=phase_mat(1:NPHS,1:NPHS);
                                    end
                                end

                                function[Zin,Zout,Zmut]=skin_cable(m,rho,Rin,Rout)







                                    x2=m*Rout;
                                    if(Rin<1e-15)
                                        Rin=1e-15;
                                    end
                                    if abs(x2)>500
                                        Zin=((m*rho)/(2*pi*Rin));
                                        Zout=((m*rho)/(2*pi*Rout));
                                        Zmut=0.0;
                                    else

                                        Din=besseli(0,m*Rin).*besselk(1,m*Rout)+besseli(1,m*Rout).*besselk(0,m*Rin);
                                        Dout=besseli(0,m*Rout).*besselk(1,m*Rin)+besseli(1,m*Rin).*besselk(0,m*Rout);
                                        D=besseli(1,m*Rout).*besselk(1,m*Rin)-besseli(1,m*Rin).*besselk(1,m*Rout);
                                        Zin=(m*rho.*Din)./(2*pi*Rin.*D);
                                        Zout=(m*rho.*Dout)./(2*pi*Rout.*D);
                                        Zmut=rho./(2*pi*Rin.*Rout.*D);
                                    end

                                    function sum=sum_mutual_pipe(n,m,q,di,dk,ang,mu)


                                        sum=0.0;
                                        for i=1:n
                                            term1=((di*dk)/q^2)^i;
                                            if abs(m*q)>500
                                                term2=i*(mu-1)+m*q;
                                            else
                                                term2=i*(mu-1)+m*q*(besselk(i+1,m*q)/besselk(i,m*q));
                                            end
                                            sum=sum+term1*cos(i*ang)*((2*mu)/term2-1/i);
                                        end

                                        function sum=sum_self_pipe(n,m,q,d,mu)


                                            sum=0.0;
                                            for i=1:n
                                                term1=(d/q)^(2*i);
                                                if abs(m*q)>500
                                                    term2=i*(mu-1)+m*q;
                                                else
                                                    term2=i*(mu-1)+m*q*(besselk(i+1,m*q)/besselk(i,m*q));
                                                end
                                                sum=sum+term1/term2;
                                            end

                                            function Z=Zearth(cs,mode,rho,w,h1,h2,x1,x2)


                                                p=sqrt(rho/(1i*w*cs.MU0));
                                                switch mode
                                                case 0

                                                    Z=1i*w*(cs.MU0/(2*pi))*log((2*(h1+p))/h2);
                                                case 1
                                                    xij=x1-x2;
                                                    dij=sqrt((xij)^2+(h1-h2)^2);
                                                    num=sqrt((h1+h2+2*p)^2+(xij)^2);
                                                    Z=1i*w*(cs.MU0/(2*pi))*log(num/dij);
                                                end