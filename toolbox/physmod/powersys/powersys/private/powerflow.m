function[sps,x0]=powerflow(sps,UseInitialConditions,LoadFlowFrequency,numfig,DisplayWarning)
















































































    set_param(sps.circuit,'SimulationCommand','update');

    if exist('DisplayWarning','var')==0
        DisplayWarning=1;
    end


    NbMachines=length(sps.LoadFlowParameters);

    j=sqrt(-1);

    LoadFlowSolver='psbflowsolv';
    system=sps.circuit;

    LoadFlowSolution=sps.machines;

    nb_input=size(sps.source,1);
    nb_output=size(sps.yout,1);

    FrequencyIndice=find(sps.freq==LoadFlowFrequency);
    if isempty(FrequencyIndice)
        set(numfig,'Pointer','arrow');
        Erreur.identifier='SpecializedPowerSystems:Powerflow:InvalidFrequency';
        Erreur.message=sprintf('Specified frequency %g Hz not found in available frequencies',LoadFlowFrequency);
        psberror(Erreur);
    end

    ind_C=[];
    ind_CN=[];
    Phaseref=0;
    No_Swing_Bus=0;


    ind_A=[];
    ind_AB=[];
    bus_type=zeros(1,NbMachines);
    Vnom=zeros(1,NbMachines);
    Pref=zeros(1,NbMachines);
    Qref=zeros(1,NbMachines);
    Uref=zeros(1,NbMachines);
    Pmec=zeros(1,NbMachines);



    for i=1:NbMachines

        ind_AB(i)=LoadFlowSolution(i).output;%#ok
        ind_A(i)=LoadFlowSolution(i).input;%#ok
        Vnom(i)=LoadFlowSolution(i).nominal{3};

        switch sps.LoadFlowParameters(i).type

        case 'Asynchronous Machine'

            bus_type(i)=3;

            Pref(i)=0;
            Qref(i)=0;
            Uref(i)=0;
            Pmec(i)=sps.LoadFlowParameters(i).set.MechanicalPower;

        case 'Three Phase Dynamic Load'

            bus_type(i)=4;

            Pref(i)=sps.LoadFlowParameters(i).set.ActivePower;
            Qref(i)=sps.LoadFlowParameters(i).set.ReactivePower;
            Uref(i)=0;
            Pmec(i)=0;

        otherwise

            switch sps.LoadFlowParameters(i).set.BusType

            case 'P & V generator'

                bus_type(i)=1;

                Pref(i)=sps.LoadFlowParameters(i).set.ActivePower;
                Qref(i)=0;
                Uref(i)=sps.LoadFlowParameters(i).set.TerminalVoltage;
                Pmec(i)=0;

            case 'P & Q generator'

                bus_type(i)=4;

                Pref(i)=sps.LoadFlowParameters(i).set.ActivePower;
                Qref(i)=sps.LoadFlowParameters(i).set.ReactivePower;
                Uref(i)=0;
                Pmec(i)=0;

            case 'Swing bus'

                bus_type(i)=2;

                Phaseref=sps.LoadFlowParameters(i).set.PhaseUan;
                No_Swing_Bus=i;
                Pref(i)=sps.LoadFlowParameters(i).set.ActivePower;
                Qref(i)=0;
                Uref(i)=sps.LoadFlowParameters(i).set.TerminalVoltage;
                Pmec(i)=0;

            end
        end
    end


    ind_BC=ind_AB+1;
    ind_Yothers=1:nb_output;
    ind_Yothers([ind_AB,ind_BC])=[];
    ind_B=ind_A+1;



    ind_mac4w=[];

    for i=1:NbMachines
        switch sps.LoadFlowParameters(i).type
        case 'Simplified Synchronous Machine'
            block=[system,'/',sps.LoadFlowParameters(i).name];
            values=get_param(block,'ConnectionType');
            if strncmp('4-wire Y',values,8)
                ind_C=[ind_C,ind_B(i)+1];%#ok
                ind_CN=[ind_CN,ind_BC(i)+1];%#ok
                ind_mac4w=[ind_mac4w,i];%#ok
            end
        end
    end

    ind_Uothers=1:nb_input;
    ind_Uothers([ind_A,ind_B,ind_C])=[];
    nb_mac4w=length(ind_C);









    H=sps.Hlin(:,:,FrequencyIndice);
    H1=H;
    H(ind_CN-2,:)=H1(ind_CN-2,:)-H1(ind_CN-1,:);
    H(ind_CN-1,:)=H1(ind_CN-1,:)-H1(ind_CN,:);







    H=H([ind_AB,ind_BC,ind_Yothers],[ind_A,ind_B,ind_C,ind_Uothers]);




    for i=1:NbMachines
        H(i,:)=H(i,:)+H(i+NbMachines,:);
    end






    U=sps.uss(:,FrequencyIndice);




    nb_switches=size(sps.switches,1);





    U(sps.source(:,7)==19)=0;

    if~isempty(sps.switches)
        U(sps.switches(:,6))=zeros(nb_switches,1);
    end
    U=U([ind_A,ind_B,ind_C,ind_Uothers]);


    index_input=1:nb_input;
    index_input=index_input([ind_A,ind_B,ind_Uothers]);
    index_output=1:nb_output;
    index_output=index_output([ind_AB,ind_BC,ind_Yothers]);%#ok


    if nb_input==(2*NbMachines+nb_mac4w),

        nb_input=nb_input+1;
        H(:,nb_input)=zeros(nb_output,1);%#ok
        U(nb_input)=0;%#ok
    end





    R1=zeros(1,NbMachines);
    X1=zeros(1,NbMachines);
    r2=zeros(1,NbMachines);
    x2=zeros(1,NbMachines);
    Ke=diag(ones(1,NbMachines));
    Kir=ones(1,NbMachines);
    Kii=ones(1,NbMachines);
    smaxT=zeros(1,NbMachines);
    P_maxT=zeros(1,NbMachines);


    MASpointeur=1;

    for i=1:NbMachines
        switch sps.LoadFlowParameters(i).type

        case 'Asynchronous Machine'

            block=[system,'/',sps.LoadFlowParameters(i).name];

            [NominalParameters,Stator,Rotor,Lm,Mechanical]=getSPSmaskvalues(block,{'NominalParameters','Stator','Rotor','Lm','Mechanical'});

            MASpointeur=MASpointeur+1;

            MachineFrequency=NominalParameters(3);
            switch getSPSmaskvalues(block,{'Units'})
            case 'SI'
                Zbase=1;
                wbase=2*pi*MachineFrequency;
            case 'pu'
                Zbase=Vnom(i)^2/NominalParameters(1);
                wbase=1;
            end


            r1=Stator(1)*Zbase;
            x1=(Stator(2)*wbase*Zbase)*(LoadFlowFrequency/MachineFrequency);
            r2(i)=Rotor(1)*Zbase;
            x2(i)=(Rotor(2)*wbase*Zbase)*(LoadFlowFrequency/MachineFrequency);
            xm=(Lm(1)*wbase*Zbase)*(LoadFlowFrequency/MachineFrequency);

            pairsofpoles=getSPSmaskvalues(block,{'PolePairs'});



            Z1=j*xm*(r1+j*x1)/(r1+j*(x1+xm));
            R1(i)=real(Z1);
            X1(i)=imag(Z1);
            Ke(i,i)=j*xm/(r1+j*(x1+xm));
            Kir(i)=1+x2(i)/xm;
            Kii(i)=-r2(i)/xm;




            smaxT(i)=r2(i)/sqrt(R1(i)+sqrt(R1(i)^2+(X1(i)+x2(i))^2));


            V1a=abs(Vnom(i)/sqrt(3)*j*xm/(r1+j*(x1+xm)));
            Ws=(2*pi*LoadFlowFrequency/pairsofpoles);
            Tmax=1/Ws*3/2*V1a^2/(R1(i)+sqrt(R1(i)^2+(X1(i)+x2(i))^2));


            P_maxT(i)=Tmax*Ws*(1-smaxT(i));

        otherwise

            R1(i)=0;
            X1(i)=0;

            r2(i)=1;
            x2(i)=1;
            Ke(i,i)=0;
            Kir(i)=0;
            Kii(i)=0;

        end
    end



    if UseInitialConditions



        t_start_current_mot=0;%#ok Inject motor current at t=0
        real_current_guess=[];
        imag_current_guess=[];
        real_Van_init=[];
        imag_Van_init=[];
        slip_guess=ones(1,NbMachines);

        for i=1:NbMachines

            no_input=LoadFlowSolution(i).input;
            no_output=LoadFlowSolution(i).output;

            real_current_guess(i)=real(sps.uss(no_input,FrequencyIndice));%#ok
            imag_current_guess(i)=imag(sps.uss(no_input,FrequencyIndice));%#ok
            Van=(2*sps.yss(no_output,FrequencyIndice)+sps.yss(no_output+1,FrequencyIndice))/3;
            real_Van_init(i)=real(Van);%#ok
            imag_Van_init(i)=imag(Van);%#ok

            switch sps.LoadFlowParameters(i).type
            case 'Asynchronous Machine'
                slip_guess(i)=LoadFlowSolution(i).slip;
            end
        end

    else



        t_start_current_mot=0.5;%#ok Inject motor current at t=0.5s
        real_current_guess=zeros(1,NbMachines);
        imag_current_guess=zeros(1,NbMachines);%#ok
        slip_guess=ones(1,NbMachines);
        real_Van_init=zeros(1,NbMachines);
        imag_Van_init=zeros(1,NbMachines);%#ok

        for i=1:NbMachines

            switch sps.LoadFlowParameters(i).type
            case 'Asynchronous Machine'

                slip_guess(i)=smaxT(i)*Pmec(i)/P_maxT(i);
                if slip_guess(i)==0;
                    slip_guess(i)=eps;
                end
                real_Van_init(i)=Vnom(i)/sqrt(3)*sqrt(2);
            case 'Three Phase Dynamic Load'

                real_current_guess(i)=0;
            otherwise
                switch sps.LoadFlowParameters(i).set.BusType
                case 'P & Q generator'

                    real_current_guess(i)=0;
                otherwise
                    real_current_guess(i)=Pref(i)/Uref(i)/sqrt(3)*sqrt(2);
                end
            end
        end
    end



    load_system('psbflowsolv');


    if nb_mac4w,
        n4=nb_mac4w;
    else
        n4=1;
    end

    set_param([LoadFlowSolver,'/LoadFlow/Real_Imac'],'Inputs',mat2str([NbMachines,NbMachines,n4]));
    set_param([LoadFlowSolver,'/LoadFlow/Imag_Imac'],'Inputs',mat2str([NbMachines,NbMachines,n4]));

    str=sprintf('real(U(%d:%d))',2*NbMachines+nb_mac4w+1,nb_input);
    set_param([LoadFlowSolver,'/LoadFlow/Real_Uothers'],'Value',str);
    str=sprintf('imag(U(%d:%d))',2*NbMachines+nb_mac4w+1,nb_input);
    set_param([LoadFlowSolver,'/LoadFlow/Imag_Uothers'],'Value',str);

    no_sig=[2*NbMachines+nb_mac4w,nb_input-2*NbMachines-nb_mac4w];
    set_param([LoadFlowSolver,'/LoadFlow/Real_U'],'Inputs',mat2str(no_sig));
    set_param([LoadFlowSolver,'/LoadFlow/Imag_U'],'Inputs',mat2str(no_sig));

    set_param([LoadFlowSolver,'/LoadFlow/Real_Ia_Ib'],'Inputs',mat2str([NbMachines,NbMachines]));
    set_param([LoadFlowSolver,'/LoadFlow/Imag_Ia_Ib'],'Inputs',mat2str([NbMachines,NbMachines]));


    if nb_mac4w,n4=ind_mac4w;else n4=1;end
    str=sprintf('[%s]',int2str(n4));
    set_param([LoadFlowSolver,'/LoadFlow/Real_Ic'],'Elements',str,'InputPortWidth',int2str(NbMachines));
    set_param([LoadFlowSolver,'/LoadFlow/Imag_Ic'],'Elements',str,'InputPortWidth',int2str(NbMachines));

    if nb_mac4w,n4=nb_mac4w;else n4=1;end
    str=sprintf('[1:%s]',int2str(2*NbMachines+nb_mac4w));
    set_param([LoadFlowSolver,'/LoadFlow/Real_Iselect'],'Elements',str,'InputPortWidth',int2str(2*NbMachines+n4));
    set_param([LoadFlowSolver,'/LoadFlow/Imag_Iselect'],'Elements',str,'InputPortWidth',int2str(2*NbMachines+n4));


    str=sprintf('%d:%d',1,2*NbMachines);
    set_param([LoadFlowSolver,'/LoadFlow/Real_Vmac_ac_bc'],'Elements',str,'InputPortWidth',int2str(nb_output));
    set_param([LoadFlowSolver,'/LoadFlow/Imag_Vmac_ac_bc'],'Elements',str,'InputPortWidth',int2str(nb_output));

    str=sprintf('%d:%d',1,NbMachines);
    set_param([LoadFlowSolver,'/LoadFlow/Real_Vmac_ac'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));
    set_param([LoadFlowSolver,'/LoadFlow/Imag_Vmac_ac'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));


    str=sprintf('%d:%d',1,NbMachines);
    set_param([LoadFlowSolver,'/LoadFlow/PQ_values/Real_Sac'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));
    set_param([LoadFlowSolver,'/LoadFlow/PQ_values/Imag_Sac'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));

    str=sprintf('%d:%d',NbMachines+1,2*NbMachines);
    set_param([LoadFlowSolver,'/LoadFlow/PQ_values/Real_Sbc'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));
    set_param([LoadFlowSolver,'/LoadFlow/PQ_values/Imag_Sbc'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));


    set_param([LoadFlowSolver,'/LoadFlow/K_Pgen'],'MaskValueString',mat2str(diag(bus_type==1|bus_type==4)+0));
    set_param([LoadFlowSolver,'/LoadFlow/K_Ugen'],'MaskValueString',mat2str(diag(bus_type==1)+0));
    set_param([LoadFlowSolver,'/LoadFlow/K_Uswing'],'MaskValueString',mat2str(diag(bus_type==2)+0));
    set_param([LoadFlowSolver,'/LoadFlow/K_Qgen'],'MaskValueString',mat2str(diag(bus_type==4)+0));


    set_param([LoadFlowSolver,'/LoadFlow/K_mac1'],'MaskValueString',mat2str(diag(bus_type~=3)+0));
    set_param([LoadFlowSolver,'/LoadFlow/K_mac2'],'MaskValueString',mat2str(diag(bus_type~=3)+0));
    set_param([LoadFlowSolver,'/LoadFlow/K_mot1'],'MaskValueString',mat2str(diag(bus_type==3)+0));
    set_param([LoadFlowSolver,'/LoadFlow/K_mot2'],'MaskValueString',mat2str(diag(bus_type==3)+0));


    str=sprintf('%d:%d',1,NbMachines);
    set_param([LoadFlowSolver,'/LoadFlow/Async_Machines/VPP>VAN/Vac_r'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));
    set_param([LoadFlowSolver,'/LoadFlow/Async_Machines/VPP>VAN/Vac_i'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));
    str=sprintf('%d:%d',NbMachines+1,2*NbMachines);
    set_param([LoadFlowSolver,'/LoadFlow/Async_Machines/VPP>VAN/Vbc_r'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));
    set_param([LoadFlowSolver,'/LoadFlow/Async_Machines/VPP>VAN/Vbc_i'],'Elements',str,'InputPortWidth',int2str(2*NbMachines));



    tmax=1.0;
    options=simset('Solver','FixedStepDiscrete','FixedStep',0.50,'SrcWorkspace','current');
    try
        LW=lastwarn;
        [tout,xout,yout]=sim(LoadFlowSolver,[0,tmax],options);



        [msg,id]=lastwarn;
        if isequal('MATLAB:divideByZero',id)
            lastwarn(LW);
        end
        sps.machines(1).status=1;
    catch ME %#ok
        set(numfig,'Pointer','arrow');
        sps.machines(1).status=0;
        return
    end














    nt=length(tout);
    Ia_real=yout(nt,1:NbMachines);
    Ib_real=yout(nt,NbMachines+1:2*NbMachines);
    Ia_imag=yout(nt,2*NbMachines+1:3*NbMachines);
    Ib_imag=yout(nt,3*NbMachines+1:4*NbMachines);
    Vac_real=yout(nt,4*NbMachines+1:5*NbMachines);
    Vbc_real=yout(nt,5*NbMachines+1:6*NbMachines);
    Vac_imag=yout(nt,6*NbMachines+1:7*NbMachines);
    Vbc_imag=yout(nt,7*NbMachines+1:8*NbMachines);
    Pmac=yout(nt,8*NbMachines+1:9*NbMachines);
    Qmac=yout(nt,9*NbMachines+1:10*NbMachines);
    Pmec_mac=yout(nt,10*NbMachines+1:11*NbMachines);
    slip_mac=yout(nt,11*NbMachines+1:12*NbMachines);
    Pmec_=[tout,yout(:,10*NbMachines+1:11*NbMachines)];%#ok
    slip_=[tout,yout(:,11*NbMachines+1:12*NbMachines)];%#ok
    Imac_a=Ia_real+j*Ia_imag;
    Imac_b=Ib_real+j*Ib_imag;
    Vmac_ac=Vac_real+j*Vac_imag;
    Vmac_bc=Vbc_real+j*Vbc_imag;


    if No_Swing_Bus

        Van=(2*Vmac_ac(No_Swing_Bus)-Vmac_bc(No_Swing_Bus))/3;
        Dphi=-angle(Van)+Phaseref*pi/180;
        Imac_a=Imac_a*exp(j*Dphi);
        Imac_b=Imac_b*exp(j*Dphi);
        Vmac_ac=Vmac_ac*exp(j*Dphi);
        Vmac_bc=Vmac_bc*exp(j*Dphi);

    end

    for i=1:NbMachines
        switch sps.LoadFlowParameters(i).type
        case 'Asynchronous Machine'
        otherwise
            slip_mac(i)=0;
        end
    end



    for i=1:NbMachines







        Van=(2*Vmac_ac(i)-Vmac_bc(i))/3;


        switch sps.LoadFlowParameters(i).type

        case 'Simplified Synchronous Machine'

            block=[system,'/',sps.LoadFlowParameters(i).name];


            [NominalParameters,Mechanical,InternalRL,InitialConditions]=getSPSmaskvalues(block,{'NominalParameters','Mechanical','InternalRL','InitialConditions'});
            SSM=getSPSmaskvalues(block,{'SSM'});

            Pnom=NominalParameters(1);
            Vn=NominalParameters(2);
            MachineFrequency=NominalParameters(3);
            pairsofpoles=getSPSmaskvalues(block,{'PolePairs'});
            Rint=SSM.R;
            Xint=SSM.L;
            dw0=InitialConditions(1);
            Vbase=Vn/sqrt(3)*sqrt(2);
            Zbase=Vn^2/Pnom;
            Ibase=Vbase/Zbase;


            Z_int=Rint*Zbase+j*Xint*Zbase;


            Ean=Van+Z_int*Imac_a(i);


            Theta=angle(Ean)*180/pi;
            Pmec=3/2*real(Ean*Imac_a(i)');


            type=get_param(block,'Units');
            if strcmp(type,'1')
                Ibase=1.0;
            end

            str_init=sprintf('[%g %g %g %g %g %g %g %g]',...
            dw0,...
            Theta,...
            abs(Imac_a(i))/Ibase,...
            abs(Imac_b(i))/Ibase,...
            abs(Imac_a(i)+Imac_b(i))/Ibase,...
            angle(Imac_a(i))*180/pi,...
            angle(Imac_b(i))*180/pi,...
            angle(-Imac_a(i)-Imac_b(i))*180/pi);

            set_param(block,'InitialConditions',str_init);


            if~isempty(LoadFlowSolution(i).SourceBlock1{1})
                if strcmp(LoadFlowSolution(i).SourceBlock1{2},'ini1');

                    set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                elseif strcmp(LoadFlowSolution(i).SourceBlock1{2},'ini2');

                    set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('[%g %g]',Pmec/Pnom,Theta));
                elseif strcmp(LoadFlowSolution(i).SourceBlock1{2},'Value');
                    if strcmp(type,'1')

                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec));
                    else

                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                    end
                elseif strcmp(LoadFlowSolution(i).SourceBlock1{2},'Before');
                    if strcmp(type,'1')

                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec));
                    else

                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                    end
                else

                    set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                end
            elseif DisplayWarning
                messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.1 (Pm) of the: ';%#ok
                messageLF{2}=' ';%#ok
                messageLF{3}=['''',strrep(sps.LoadFlowParameters(i).name,char(10),' '),''' block.'];%#ok
                messageLF{4}=' ';%#ok
                messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                messageLF{6}=' ';%#ok
                messageLF{7}=[sprintf('%g',Pmec),' Watts, or ',sprintf('%g',Pmec/Pnom),' pu.'];%#ok
                warndlg(messageLF,'Load Flow message');
                warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
            end


            if~isempty(LoadFlowSolution(i).SourceBlock1{3})

                set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{3},LoadFlowSolution(i).SourceBlock1{4},sprintf('%g',Pmac(i)/Pnom));
            elseif strcmp('NotAbleToSet',LoadFlowSolution(i).SourceBlock1{4})&&DisplayWarning
                messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.2 (Pref) of the: ';%#ok
                messageLF{2}=' ';%#ok
                messageLF{3}=['''',strrep(getfullname(LoadFlowSolution(i).SourceBlock1{1}),char(10),' '),''' block.'];%#ok
                messageLF{4}=' ';%#ok
                messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                messageLF{6}=' ';%#ok
                messageLF{7}=[sprintf('%g',Pmac(i)/Pnom),' pu.'];%#ok
                warndlg(messageLF,'Load Flow message');
                warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
            end


            Vt0=0;
            if~isempty(LoadFlowSolution(i).SourceBlock2{1})

                if strcmp(LoadFlowSolution(i).SourceBlock2{2},'v0');

                    Vt0=sps.LoadFlowParameters(i).set.TerminalVoltage/LoadFlowSolution(i).nominal{3};

                    Previous_setting=eval(get_param(LoadFlowSolution(i).SourceBlock2{1},LoadFlowSolution(i).SourceBlock2{2}));
                    New_setting=sprintf('[%g,%g]',Previous_setting(1),(abs(Ean)*sqrt(3)/sqrt(2))/Vbase);
                    set_param(LoadFlowSolution(i).SourceBlock2{1},LoadFlowSolution(i).SourceBlock2{2},New_setting);
                else
                    if strcmp(type,'1')
                        New_setting=sprintf('%g',abs(Ean)*sqrt(3)/sqrt(2));
                    else
                        New_setting=sprintf('%g',abs(Ean)/Vbase);
                    end
                    set_loadflow_parameter(LoadFlowSolution(i).SourceBlock2{1},LoadFlowSolution(i).SourceBlock2{2},New_setting);
                end

            elseif DisplayWarning

                messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.2 (E) of the: ';%#ok
                messageLF{2}=' ';%#ok
                messageLF{3}=['''',strrep(sps.LoadFlowParameters(i).name,char(10),' '),''' block.'];%#ok
                messageLF{4}=' ';%#ok
                messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                messageLF{6}=' ';%#ok
                messageLF{7}=[sprintf('%g',abs(Ean)),' Volts, or ',sprintf('%g',abs(Ean)/Vbase),' pu.'];%#ok
                warndlg(messageLF,'Load Flow message');
                warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});

            end


            if~isempty(LoadFlowSolution(i).SourceBlock2{3})

                set_loadflow_parameter(LoadFlowSolution(i).SourceBlock2{3},LoadFlowSolution(i).SourceBlock2{4},sprintf('%g',Vt0));
            elseif strcmp('NotAbleToSet',LoadFlowSolution(i).SourceBlock2{4})&&DisplayWarning
                messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.1 (vref) of the: ';%#ok
                messageLF{2}=' ';%#ok
                messageLF{3}=['''',strrep(getfullname(LoadFlowSolution(i).SourceBlock2{1}),char(10),' '),''' block.'];%#ok
                messageLF{4}=' ';%#ok
                messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                messageLF{6}=' ';%#ok
                messageLF{7}=[sprintf('%g',Vt0),' pu.'];%#ok
                warndlg(messageLF,'Load Flow message');
                warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
            end

            Ws=2*pi*LoadFlowFrequency/pairsofpoles;
            torque=Pmec/(Ws*(1-slip_mac(i)));

        end



        switch sps.LoadFlowParameters(i).type
        case 'Synchronous Machine'

            block=[system,'/',sps.LoadFlowParameters(i).name];
            Units=get_param(block,'Units');

            MechanicalLoad=get_param(block,'MechanicalLoad');


            NominalParameters=getSPSmaskvalues(block,{'NominalParameters'});
            Pnom=NominalParameters(1);
            Vn=NominalParameters(2);
            MachineFrequency=NominalParameters(3);
            Vbase=Vn/sqrt(3)*sqrt(2);
            Zbase=Vn^2/Pnom;
            Ibase=Vbase/Zbase;


            SM=getSPSmaskvalues(block,{'SM'});


            Rs=SM.Rs*Zbase;
            Xd=(SM.Ll+SM.Lmd)*Zbase;
            Xq=(SM.Ll+SM.Lmq)*Zbase;


            pairsofpoles=SM.p;



            Ef1=Van+Imac_a(i)*Rs+j*Imac_a(i)*Xq;


            Id=abs(abs(Imac_a(i)))*sin(angle(Ef1)-angle(Imac_a(i)))*exp(j*(angle(Ef1)-pi/2));
            Iq=abs(abs(Imac_a(i)))*cos(angle(Ef1)-angle(Imac_a(i)))*exp(j*(angle(Ef1)));


            Ean=Van+Imac_a(i)*Rs+j*Id*Xd+j*Iq*Xq;


            Theta=angle(Ean)*180/pi-90;


            Pmec=3/2*(real(Van*Imac_a(i)')+Rs*abs(Imac_a(i))^2);


            wsync=2*pi*MachineFrequency/SM.p;
            F=SM.F*Pnom/(wsync^2);
            Pfriction=F*wsync^2;

            switch MechanicalLoad
            case 'Mechanical power Pm'
                Pmec=Pmec+Pfriction;
            end


            switch Units

            case 'SI fundamental parameters'

                Vfd=SM.vfn;

                str_init=sprintf('[%g %g %g %g %g %g %g %g %g]',...
                SM.dwo,...
                Theta,...
                abs(Imac_a(i)),...
                abs(Imac_b(i)),...
                abs(Imac_a(i)+Imac_b(i)),...
                angle(Imac_a(i))*180/pi,...
                angle(Imac_b(i))*180/pi,...
                angle(-Imac_a(i)-Imac_b(i))*180/pi,...
                (abs(Ean)/Vbase)*Vfd);

            otherwise

                Vfd=1;

                str_init=sprintf('[%g %g %g %g %g %g %g %g %g]',...
                SM.dwo,...
                Theta,...
                abs(Imac_a(i))/Ibase,...
                abs(Imac_b(i))/Ibase,...
                abs(Imac_a(i)+Imac_b(i))/Ibase,...
                angle(Imac_a(i))*180/pi,...
                angle(Imac_b(i))*180/pi,...
                angle(-Imac_a(i)-Imac_b(i))*180/pi,...
                abs(Ean)/Vbase);

            end

            set_param(block,'InitialConditions',str_init);

            switch MechanicalLoad

            case 'Mechanical power Pm'

                if~isempty(LoadFlowSolution(i).SourceBlock1{1})
                    if strcmp(LoadFlowSolution(i).SourceBlock1{2},'ini1');

                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                    elseif strcmp(LoadFlowSolution(i).SourceBlock1{2},'ini2');

                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('[%g,%g]',Pmec/Pnom,Theta));
                    elseif strcmp(LoadFlowSolution(i).SourceBlock1{2},'Value');
                        switch Units
                        case 'SI fundamental parameters'
                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec));
                        otherwise

                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                        end
                    elseif strcmp(LoadFlowSolution(i).SourceBlock1{2},'Before');
                        switch Units
                        case 'SI fundamental parameters'
                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec));
                        otherwise
                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                        end
                    else

                        switch get_param(LoadFlowSolution(i).SourceBlock1{1},'MaskType')
                        case 'Diesel Engine & Governor'
                            DEG=LoadFlowSolution(i).SourceBlock1{1};
                            Tlim=getSPSmaskvalues(DEG,{'Tlim'});
                            Tmin=Tlim(1);
                            Tmax=Tlim(2);
                            po=Pmec/Pnom;
                            poact=po;
                            pomax=Tmax/(Tmax-Tmin);
                            pomin=Tmin/(Tmax-Tmin);
                            warn1=0;
                            if po>=pomax
                                po=pomax*0.999;
                                warn1=1;
                            end
                            if po<=pomin
                                po=pomin*1.001;
                                warn1=1;
                            end
                            if warn1
                                DEGname=strrep(getfullname(DEG),char(10),' ');
                                messageLF{1}=['The Machine Initialization tool limited the "Initial value of mechanical power Pm0(pu)" parameter of "',DEGname,'" block to a value of ',num2str(po),' pu'];
                                messageLF{2}=' ';
                                messageLF{3}=['The actual initial Pm0 value computed by the tool is equal to: ',num2str(poact),' pu and is outside the specified torque limits given by:'];
                                messageLF{4}='   Tmin/(Tmax-Tmin) < p0 < Tmax/(Tmax-Tmin)';
                                messageLF{5}=['   ',pomin,' < Pm0 < ',pomax];
                                warndlg(messageLF,'Machine Initialization tool message');
                                warning('SpecializedPowerSystems:MachineInitialization:OutOfLimits',messageLF{:});
                            end

                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',po));
                        otherwise

                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Pmec/Pnom));
                        end
                    end
                elseif DisplayWarning

                    messageLF{1}='The Machine Initialization tool cannot set automatically the initial condition of the signal connected to the input no.1 (Pm) of the: ';%#ok
                    messageLF{2}=' ';%#ok
                    messageLF{3}=['''',strrep(sps.LoadFlowParameters(i).name,char(10),' '),''' block.'];%#ok
                    messageLF{4}=' ';%#ok
                    messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                    messageLF{6}=' ';%#ok
                    messageLF{7}=[sprintf('%g',Pmec),' Watts, or ',sprintf('%g',Pmec/Pnom),' pu.'];%#ok
                    warndlg(messageLF,'Load Flow message');
                    warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
                end

            case 'Speed w'

                wsync=2*pi*MachineFrequency/SM.p;
                Speedpu=1-SM.dwo;
                SpeedSI=Speedpu*wsync;

                if~isempty(LoadFlowSolution(i).SourceBlock1{1})
                    if strcmp(LoadFlowSolution(i).SourceBlock1{2},'Value');
                        switch Units
                        case 'SI fundamental parameters'
                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',SpeedSI));
                        otherwise
                            set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Speedpu));
                        end
                    else

                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Speedpu));
                    end
                elseif DisplayWarning

                    messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.1 (w) of the: ';%#ok
                    messageLF{2}=' ';%#ok
                    messageLF{3}=['''',strrep(sps.LoadFlowParameters(i).name,char(10),' '),''' block.'];%#ok
                    messageLF{4}=' ';%#ok
                    messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                    messageLF{6}=' ';%#ok
                    messageLF{7}=[sprintf('%g',SpeedSI),' rad/s, or ',sprintf('%g',Speedpu),' pu.'];%#ok
                    warndlg(messageLF,'Load Flow message');
                    warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
                end
            end


            if~isempty(LoadFlowSolution(i).SourceBlock1{3})

                set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{3},LoadFlowSolution(i).SourceBlock1{4},sprintf('%g',Pmac(i)/Pnom));
            elseif strcmp('NotAbleToSet',LoadFlowSolution(i).SourceBlock1{4})&&DisplayWarning
                messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.2 (Pref) of the: ';%#ok
                messageLF{2}=' ';%#ok
                messageLF{3}=['''',strrep(getfullname(LoadFlowSolution(i).SourceBlock1{1}),char(10),' '),''' block.'];%#ok
                messageLF{4}=' ';%#ok
                messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                messageLF{6}=' ';%#ok
                messageLF{7}=[sprintf('%g',Pmac(i)/Pnom),' pu.'];%#ok
                warndlg(messageLF,'Load Flow message');
                warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
            end


            Vt0=1;
            if~isempty(LoadFlowSolution(i).SourceBlock2{1})

                if strcmp(LoadFlowSolution(i).SourceBlock2{2},'v0');

                    Vt0=sps.LoadFlowParameters(i).set.TerminalVoltage/LoadFlowSolution(i).nominal{3};

                    New_setting=sprintf('[%g,%g]',Vt0,abs(Ean)/Vbase);
                    set_loadflow_parameter(LoadFlowSolution(i).SourceBlock2{1},LoadFlowSolution(i).SourceBlock2{2},New_setting);
                else
                    switch Units
                    case 'SI fundamental parameters'
                        New_setting=sprintf('%g',(abs(Ean)/Vbase)*Vfd);
                    otherwise
                        New_setting=sprintf('%g',abs(Ean)/Vbase);
                    end
                    set_loadflow_parameter(LoadFlowSolution(i).SourceBlock2{1},LoadFlowSolution(i).SourceBlock2{2},New_setting);
                end

            elseif DisplayWarning


                messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.2 (Vf) of the: ';%#ok
                messageLF{2}=' ';%#ok
                messageLF{3}=['''',strrep(sps.LoadFlowParameters(i).name,char(10),' '),''' block.'];%#ok
                messageLF{4}=' ';%#ok
                messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                messageLF{6}=' ';%#ok
                switch Units
                case 'SI fundamental parameters'
                    messageLF{7}=[sprintf('%g',(abs(Ean)/Vbase)*Vfd),' Volts.'];%#ok
                otherwise
                    messageLF{7}=[sprintf('%g',abs(Ean)/Vbase),' p.u.'];%#ok
                end
                warndlg(messageLF,'Load Flow message');
                warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
            end


            if~isempty(LoadFlowSolution(i).SourceBlock2{3})

                set_loadflow_parameter(LoadFlowSolution(i).SourceBlock2{3},LoadFlowSolution(i).SourceBlock2{4},sprintf('%g',Vt0));
            elseif strcmp('NotAbleToSet',LoadFlowSolution(i).SourceBlock2{4})&&DisplayWarning
                messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the input no.1 (vref) of the: ';%#ok
                messageLF{2}=' ';%#ok
                messageLF{3}=['''',strrep(getfullname(LoadFlowSolution(i).SourceBlock2{1}),char(10),' '),''' block.'];%#ok
                messageLF{4}=' ';%#ok
                messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                messageLF{6}=' ';%#ok
                messageLF{7}=[sprintf('%g',Vt0),' pu.'];%#ok
                warndlg(messageLF,'Load Flow message');
                warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
            end

            Ws=2*pi*LoadFlowFrequency/pairsofpoles;
            torque=Pmec/(Ws*(1-slip_mac(i)));


        end



        switch sps.LoadFlowParameters(i).type
        case 'Asynchronous Machine'

            block=[system,'/',sps.LoadFlowParameters(i).name];


            [NominalParameters,Mechanical,InitialConditions]=getSPSmaskvalues(block,{'NominalParameters','Mechanical','InitialConditions'});

            Pnom=NominalParameters(1);
            Vn=NominalParameters(2);
            MachineFrequency=NominalParameters(3);


            SM=getSPSmaskvalues(block,{'SM'});

            pairsofpoles=getSPSmaskvalues(block,{'PolePairs'});

            Theta=InitialConditions(2);
            Ean=0;
            Pmec=Pmec_mac(i);
            Vbase=Vn/sqrt(3)*sqrt(2);


            Units=getSPSmaskvalues(block,{'Units'});
            switch Units
            case 'SI'
                Ibase=1.0;
            case 'pu'
                Ibase=Vbase/(Vn^2/Pnom);
            end

            str_init=sprintf('[%g %g %g %g %g %g %g %g]',...
            slip_mac(i),...
            Theta,...
            abs(Imac_a(i))/Ibase,...
            abs(Imac_b(i))/Ibase,...
            abs(Imac_a(i)+Imac_b(i))/Ibase,...
            angle(Imac_a(i))*180/pi,...
            angle(Imac_b(i))*180/pi,...
            angle(-Imac_a(i)-Imac_b(i))*180/pi);

            set_param(block,'InitialConditions',str_init);

            switch get_param(block,'MechanicalLoad');

            case 'Torque Tm'


                Ws=2*pi*LoadFlowFrequency/pairsofpoles;
                torque=Pmec/(Ws*(1-slip_mac(i)));
                Ws_nom=2*pi*MachineFrequency/pairsofpoles;
                Tnom=Pnom/Ws_nom;








                F=SM.F*Pnom/(Ws^2);
                torque=torque-F*Ws*(1-slip_mac(i));
                Pmec=torque*Ws*(1-slip_mac(i));

                if~isempty(LoadFlowSolution(i).SourceBlock1{1})

                    switch Units
                    case 'SI'
                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',torque));
                    case 'pu'
                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',torque/Tnom));
                    end

                elseif DisplayWarning

                    messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the Tm input of the: ';%#ok
                    messageLF{2}=' ';%#ok
                    messageLF{3}=['''',strrep(sps.LoadFlowParameters(i).name,char(10),' '),''' block.'];%#ok
                    messageLF{4}=' ';%#ok
                    messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                    messageLF{6}=' ';%#ok
                    messageLF{7}=[sprintf('%g',torque),' N.m, or ',sprintf('%g',torque/Tnom),' pu.'];%#ok
                    warndlg(messageLF,'Load Flow message');
                    warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
                end

            case 'Speed w'


                Ws_nom=2*pi*MachineFrequency/pairsofpoles;
                Speedpu=1;
                SpeedSI=Speedpu*Ws_nom;

                if~isempty(LoadFlowSolution(i).SourceBlock1{1})

                    switch Units
                    case 'SI'
                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',SpeedSI));
                    case 'pu'
                        set_loadflow_parameter(LoadFlowSolution(i).SourceBlock1{1},LoadFlowSolution(i).SourceBlock1{2},sprintf('%g',Speedpu));
                    end

                elseif DisplayWarning

                    messageLF{1}='The Machine Load Flow tool cannot set automatically the initial condition of the signal connected to the w input of the: ';%#ok
                    messageLF{2}=' ';%#ok
                    messageLF{3}=['''',strrep(sps.LoadFlowParameters(i).name,char(10),' '),''' block.'];%#ok
                    messageLF{4}=' ';%#ok
                    messageLF{5}='If applicable, set the initial condition for this signal to: ';%#ok
                    messageLF{6}=' ';%#ok
                    messageLF{7}=[sprintf('%g',SpeedSI),' rad/s, or ',sprintf('%g',Speedpu),' pu.'];%#ok
                    warndlg(messageLF,'Load Flow message');
                    warning('SpecializedPowerSystems:LoadFlowWarning',messageLF{:});
                end

            end

            Ws=2*pi*LoadFlowFrequency/pairsofpoles;
            torque=Pmec/(Ws*(1-slip_mac(i)));
        end



        switch sps.LoadFlowParameters(i).type
        case 'Three Phase Dynamic Load'

            block=[system,'/',sps.LoadFlowParameters(i).name];
            j=sqrt(-1);
            a=exp(j*2*pi/3);
            Vab=(Vmac_ac(i)-Vmac_bc(i))/(Vnom(i)*sqrt(2));
            Vbc=Vmac_bc(i)/(Vnom(i)*sqrt(2));
            V0=sqrt(3)/3*(Vab-a^2*Vbc);
            PQ0=sprintf('[%g %g]',Pmac(i),Qmac(i));
            V0=sprintf('[%g %g]',abs(V0),angle(V0)*180/pi);

            set_param(block,'ActiveReactivePowers',PQ0);
            set_param(block,'PositiveSequence',V0);


            NominalVoltage=getSPSmaskvalues(block,{'NominalVoltage'});
            MachineFrequency=NominalVoltage(2);

            Pnom=NaN;
            torque=NaN;
            pairsofpoles=NaN;
            Ean=Vnom(i);
            Vbase=Vnom(i);

        end



        LoadFlowSolution(i).nominal={LoadFlowSolution(i).nominal{1},Pnom,Vnom(i),pairsofpoles,MachineFrequency};
        LoadFlowSolution(i).P=Pmac(i);
        LoadFlowSolution(i).Q=Qmac(i);
        LoadFlowSolution(i).Vt=abs(Vmac_ac(i)-Vmac_bc(i))/sqrt(2);
        switch sps.LoadFlowParameters(i).type
        case 'Synchronous Machine'
            if LoadFlowSolution(i).nominal{1}==1
                LoadFlowSolution(i).Ef=abs(Ean)/Vbase*Vfd;
            else
                LoadFlowSolution(i).Ef=abs(Ean)/Vbase;
            end
        end
        LoadFlowSolution(i).Pmec=Pmec;
        LoadFlowSolution(i).slip=slip_mac(i);
        LoadFlowSolution(i).torque=torque;

    end






    for i=1:NbMachines


        sps.source(index_input(i),4)=abs(Imac_a(i));
        sps.source(index_input(i),5)=angle(Imac_a(i))*180/pi;
        sps.source(index_input(i),6)=LoadFlowFrequency;


        sps.source(index_input(i+NbMachines),4)=abs(Imac_b(i));
        sps.source(index_input(i+NbMachines),5)=angle(Imac_b(i))*180/pi;
        sps.source(index_input(i+NbMachines),6)=LoadFlowFrequency;


        indice_phaseC=find(i==ind_mac4w);
        if indice_phaseC
            sps.source(ind_C(indice_phaseC),4)=abs(Imac_a(i));
            sps.source(ind_C(indice_phaseC),5)=angle(Imac_a(i))*180/pi+120;
            sps.source(ind_C(indice_phaseC),6)=LoadFlowFrequency;
        end

    end

    sps=etass(sps);



    if sps.PowerguiInfo.Discrete
        if isempty(sps.x0)
            sps.x0discrete=sps.x0;
        else
            u0=sum(imag(sps.uss),2);
            I=eye(size(sps.A));
            sps.x0discrete=(I-sps.Aswitch*sps.PowerguiInfo.Ts/2)*(sps.x0/sps.PowerguiInfo.Ts)-sps.Bswitch/2*u0;
        end
    else
        sps.x0discrete=[];
    end

    sps.x0permdiscrete=sps.x0discrete;
    sps.x0perm=sps.x0;
    x0=sps.x0;



    for i=1:length(sps.DistributedParameterLine)
        [x1,x2,x3,x4,x5]=initdistline(sps,i);
        moderef=sps.modelnames{19}(i);

        TestNoNaN=~any(isnan([x1(:);x2(:);x3(:);x4(:);x5(:)]));
        if TestNoNaN

            set_param(moderef,'x1',mat2str(x1,4),'x2',mat2str(x2,4),'x3',mat2str(x3,4),'x4',mat2str(x4,4),'x5',mat2str(x5,4));
        end
    end


    sps.machines=LoadFlowSolution;

    close_system(LoadFlowSolver,0);



    function set_loadflow_parameter(Bloc,Parametre,Valeur)



        CurrentExpression=get_param(Bloc,Parametre);
        Crochets=[findstr(CurrentExpression,'['),findstr(CurrentExpression,']')];
        CE=CurrentExpression;
        CE(Crochets)=[];

        if all(abs(CE)>42)&&all(abs(CE)<58)

            set_param(Bloc,Parametre,Valeur);

        else

            BlockName=strrep([get_param(Bloc,'Parent'),'/',get_param(Bloc,'Name')],char(10),' ');
            dialogue{1}=['In order to start the simulation in steady state, the ''',Parametre,''' parameter of the ''',BlockName,''' block should equals ',Valeur,'.'];
            dialogue{2}=' ';
            dialogue{3}=['Would you like Load Flow tool to replace the current expression ''',CurrentExpression,''' by the calculated value ?'];

            switch questdlg(dialogue,'Load Flow Tool','Yes','No','Yes')
            case 'Yes'
                set_param(Bloc,Parametre,Valeur);
            end

        end
