function PVArrayLoadModule(Block)





    persistent SolarModuleSpec

    ModuleName=get_param(Block,'ModuleName');
    hBlock=get_param(Block,'Object');

    switch ModuleName

    case 'User-defined'

        Ncell=str2num(get_param(Block,'Ncell'));%#ok<*ST2NM>
        Voc=str2num(get_param(Block,'Voc'));
        Isc=str2num(get_param(Block,'Isc'));
        Vm=str2num(get_param(Block,'Vm'));
        Im=str2num(get_param(Block,'Im'));
        beta_Voc_pc=str2num(get_param(Block,'beta_Voc_pc'));
        alpha_Isc_pc=str2num(get_param(Block,'alpha_Isc_pc'));


        if Voc<=0||Isc<=0||Vm<=0||Im<=0
            error(message('physmod:powersys:common:GreaterThan',Block,'Voc, Isc, Vmp and Imp','0'));
        end
        if Vm>=Voc
            error(message('physmod:powersys:common:LesserThan',Block,'Vmp','Voc'));
        end
        if Im>=Isc
            error(message('physmod:powersys:common:LesserThan',Block,'Imp','Isc'));
        end










        if alpha_Isc_pc<-0.2||alpha_Isc_pc>1.0
            error(message('physmod:powersys:common:OutOfRange',Block,'Temperature coefficient of Isc (%/deg.C)','-0.2','1'));
        end

        if beta_Voc_pc<-1.0||beta_Voc_pc>-0.1
            error(message('physmod:powersys:common:OutOfRange',Block,'Temperature coefficient of Voc (%/deg.C)','-1.0','-0.1'));
        end

        switch get_param(bdroot(Block),'SimulationStatus')
        case 'initializing'

        otherwise


            set_param(Block,'Pm',num2str(Vm*Im));


            alpha_Isc=alpha_Isc_pc/100*Isc;
            beta_Voc=beta_Voc_pc/100*Voc;

            set_param(Block,'alpha_Isc',num2str(alpha_Isc));

            set_param(Block,'beta_Voc',num2str(beta_Voc));


            [IL_ref,I0_ref,nI_ref,Rs_ref,Rsh_ref]=PVparamSTC(Voc,Isc,Vm,Im,Ncell,alpha_Isc,beta_Voc,Block);


            set_param(Block,'IL',num2str(IL_ref));

            set_param(Block,'I0',num2str(I0_ref));

            set_param(Block,'nI',num2str(nI_ref));

            set_param(Block,'Rsh',num2str(Rsh_ref));

            set_param(Block,'Rs',num2str(Rs_ref));
        end


    otherwise

        if isempty(SolarModuleSpec)
            load PVArraySolarModuleSpec.mat;
        end


        ModuleNumber=strmatch(ModuleName,char(SolarModuleSpec.Desc));

        if length(ModuleNumber)>1

            k=1;
            while length(SolarModuleSpec(ModuleNumber(k)).Desc)~=length(ModuleName)
                k=k+1;
            end
            ModuleNumber=ModuleNumber(k);
        end


        switch get_param(bdroot(Block),'SimulationStatus')
        case 'initializing'

        otherwise

            set_param(Block,'Ncell',num2str(SolarModuleSpec(ModuleNumber).nCells));

            set_param(Block,'Voc',num2str(SolarModuleSpec(ModuleNumber).Voc));

            set_param(Block,'Isc',num2str(SolarModuleSpec(ModuleNumber).Isc));

            set_param(Block,'Vm',num2str(SolarModuleSpec(ModuleNumber).Vmp));

            set_param(Block,'Im',num2str(SolarModuleSpec(ModuleNumber).Imp));

            set_param(Block,'beta_Voc',num2str(SolarModuleSpec(ModuleNumber).beta_Voc));

            set_param(Block,'alpha_Isc',num2str(SolarModuleSpec(ModuleNumber).alpha_Isc));

            set_param(Block,'beta_Voc_pc',num2str(SolarModuleSpec(ModuleNumber).beta_Voc/SolarModuleSpec(ModuleNumber).Voc*100));

            set_param(Block,'alpha_Isc_pc',num2str(SolarModuleSpec(ModuleNumber).alpha_Isc/SolarModuleSpec(ModuleNumber).Isc*100));

            set_param(Block,'Pm',num2str(SolarModuleSpec(ModuleNumber).Vmp*SolarModuleSpec(ModuleNumber).Imp));


            set_param(Block,'IL',num2str(SolarModuleSpec(ModuleNumber).IL));

            set_param(Block,'I0',num2str(SolarModuleSpec(ModuleNumber).I0));

            set_param(Block,'nI',num2str(SolarModuleSpec(ModuleNumber).nI));

            set_param(Block,'Rsh',num2str(SolarModuleSpec(ModuleNumber).Rsh));

            set_param(Block,'Rs',num2str(SolarModuleSpec(ModuleNumber).Rs));
        end
    end

    function[IL,I0,nI,Rs,Rsh,SolutionType,Tcell_K]=PVparamSTC(Voc,Isc,Vm,Im,Ns,alpha_isc,beta_voc,Block)





































        Sref=1000;
        Tref_C=25;
        Tref_K=Tref_C+273.15;
        Tcell_K=Tref_K+15;



        OptimWeight=[10,1,10,10,10,1];


        Rshmin=-(0-Vm)/(Isc-Im);
        Rsmax=-(Vm-Voc)/(Im-0);
        Rsh0=Rshmin*8;
        Rs0=Rsmax/2;
        Isat0=1e-9;
        Iph0=Isc;
        nI0=1;
        Rshmin=-(0-Vm)/(Isc-Im);
        Rsmax=-(Vm-Voc)/(Im-0);
        xInit=[Rsh0,Rs0,Isat0,Iph0,nI0];




        varOrder=[5,4,1,3,2];
        xTol=[1e-3,1e-3,1e-15,1e-4,1e-4];
        xmin_vec=[Rshmin*2,0,1e-15,Isc,0.1];
        xmax_vec=[1e5,Rsmax,1e-5,1.01*Isc,3];
        xvec=xInit;

        nitermax_fminbnd=10;
        xmat=zeros(nitermax_fminbnd,5);

        for niter=1:nitermax_fminbnd
            for ivar=1:5
                novar=find(varOrder==ivar);
                xmin=xmin_vec(novar);
                xmax=xmax_vec(novar);

                options=optimset('TolX',xTol(novar),'MaxFunEvals',100,'MaxIter',100,'Display','off');

                [x,~]=fminbnd(@(x)PVArrayOptimize(x,Voc,Isc,Vm,Im,alpha_isc,beta_voc,Tref_K,Ns,xvec,novar,OptimWeight,Tcell_K),xmin,xmax,options);

                xvec(novar)=x;
            end
            xmat(niter,:)=xvec;
        end

        SolutionType=1;

        Rsh_ref=xvec(1);
        Rs_ref=xvec(2);
        I0_ref=xvec(3);
        IL_ref=xvec(4);
        nI_ref=xvec(5);

        Error4ParamSTC=inf;
        Tcell_K_vec=[35,40,45]+273.15;
        kTcell=0;





        Solutions=zeros(length(Tcell_K),10);

        while any(Error4ParamSTC>0.02)&&kTcell<length(Tcell_K_vec)

            kTcell=kTcell+1;
            Tcell_K=Tcell_K_vec(kTcell);



            xInit=[Rsh_ref,Rs_ref,I0_ref,IL_ref,nI_ref];
            options=optimset('TolFun',1e-4','MaxFunEvals',2000,'MaxIter',1000,'Display','off');

            [x,fval]=fminsearch(@(x)PVArrayOptimize(x,Voc,Isc,Vm,Im,alpha_isc,beta_voc,Tref_K,Ns,xvec,0,OptimWeight,Tcell_K),xInit,options);

            if all(x>0)
                Rsh_ref=x(1);
                Rs_ref=x(2);
                I0_ref=x(3);
                IL_ref=x(4);
                nI_ref=x(5);
                SolutionType=2;
            else



                xInit=[Rsh0,Rs0,Isat0,Iph0,nI0];

                [x,fval2]=fminsearch(@(x)PVArrayOptimize(x,Voc,Isc,Vm,Im,alpha_isc,beta_voc,Tref_K,Ns,xvec,0,OptimWeight,Tcell_K),xInit,options);

                if all(x>0)
                    fval=fval2;
                    Rsh_ref=x(1);
                    Rs_ref=x(2);
                    I0_ref=x(3);
                    IL_ref=x(4);
                    nI_ref=x(5);
                    SolutionType=3;
                end
            end



            [V_PV_ref,I_PV_ref]=PVArrayParam(Sref,Tref_C,IL_ref,I0_ref,nI_ref,Rs_ref,Rsh_ref,Voc,Vm,Im,alpha_isc,beta_voc,Ns);

            if isempty(V_PV_ref)
                error(message('physmod:powersys:common:GenericError',Block,...
                'Impossible to find a solution for the specified parameters'));
            end

            P_PV_ref=V_PV_ref.*I_PV_ref;
            Isc_Obtained=I_PV_ref(1);
            Voc_Obtained=V_PV_ref(end);

            n=find(P_PV_ref==max(P_PV_ref));

            Vm_Obtained=V_PV_ref(n);
            Im_Obtained=I_PV_ref(n);
            Error4ParamSTC=abs(([Isc,Voc,Vm,Im]-[Isc_Obtained,Voc_Obtained,Vm_Obtained,Im_Obtained])./[Isc,Voc,Vm,Im]);




            if any(Error4ParamSTC>0.01)

                OptimWeight2=OptimWeight;

                if Error4ParamSTC(1)>0.01&&all(Error4ParamSTC(2:4)<0.01)

                    OptimWeight2(1)=OptimWeight2(1)*2;
                end

                if Error4ParamSTC(2)>0.01

                    OptimWeight2(2)=OptimWeight2(2)*2;
                end

                if Error4ParamSTC(3)>0.01||Error4ParamSTC(4)>0.01
                    OptimWeight2(3)=OptimWeight2(3)*10;
                    OptimWeight2(4)=OptimWeight2(4)*10;
                end

                xInit=[Rsh_ref,Rs_ref,I0_ref,IL_ref,nI_ref];

                [x,fval2]=fminsearch(@(x)PVArrayOptimize(x,Voc,Isc,Vm,Im,alpha_isc,beta_voc,Tref_K,Ns,xvec,0,OptimWeight2,Tcell_K),xInit,options);

                if fval2<fval&&all(x>0)

                    fval=fval2;
                    Rsh_ref=x(1);
                    Rs_ref=x(2);
                    I0_ref=x(3);
                    IL_ref=x(4);
                    nI_ref=x(5);
                    SolutionType=4;



                    [V_PV_ref,I_PV_ref]=PVArrayParam(Sref,Tref_C,IL_ref,I0_ref,nI_ref,Rs_ref,Rsh_ref,Voc,Vm,Im,alpha_isc,beta_voc,Ns);

                    P_PV_ref=V_PV_ref.*I_PV_ref;
                    Isc_Obtained=I_PV_ref(1);
                    Voc_Obtained=V_PV_ref(end);

                    n=find(P_PV_ref==max(P_PV_ref));

                    Vm_Obtained=V_PV_ref(n);
                    Im_Obtained=I_PV_ref(n);
                    Error4ParamSTC=abs(([Isc,Voc,Vm,Im]-[Isc_Obtained,Voc_Obtained,Vm_Obtained,Im_Obtained])./[Isc,Voc,Vm,Im]);

                end
            end


            Solutions(kTcell,:)=[Rsh_ref,Rs_ref,I0_ref,IL_ref,nI_ref,Error4ParamSTC,SolutionType];

        end



        MaxErrors=max(Solutions(:,6:9),[],2);
        [~,kTcell_MinError]=min(MaxErrors);

        Rsh=Solutions(kTcell_MinError,1);
        Rs=Solutions(kTcell_MinError,2);
        I0=Solutions(kTcell_MinError,3);
        IL=Solutions(kTcell_MinError,4);
        nI=Solutions(kTcell_MinError,5);

        SolutionType=Solutions(kTcell_MinError,10);
        Tcell_K=Tcell_K_vec(kTcell_MinError);