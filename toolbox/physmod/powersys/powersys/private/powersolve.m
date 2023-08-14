function SPS=powersolve(sys,options,PowerguiInfo,BLOCKLIST,X0Sw)












































































































































    if~exist('X0Sw','var')
        X0Sw=[];
    end


    Rules=SPSrl('get',sys,options);

    if Rules.CalledByPowergui||Rules.CreateNetList


        PowerguiInfo.EchoMessage=0;
    end

    if Rules.CreateNetList

        FID=fopen([sys,'.net'],'wt');
    else
        FID=0;
    end

    [~,~,~,SPSnetwork]=powersysdomain_netlist('get');

    if PowerguiInfo.EchoMessage
        if SPSnetwork==0
            disp([newline,'Specialized Power Systems processing ',sys,' ...']);
        else
            disp([newline,'Specialized Power Systems processing circuit #',num2str(SPSnetwork),' of ',sys,' ...']);
        end
    end

    if SPSnetwork==0

        SPSnetwork=1;
    end


    D.PowerguiInfo=PowerguiInfo;
    SPSrl('eval',Rules.PreBlockAnalysisFcn,'PreBlockAnalysisFcn',D);





    SPS=psbsort(BLOCKLIST,sys,options);

    if~isempty(options)
        switch options
        case 'getSwitchStatus'
            return
        case 'setSwitchStatus'
            if isstruct(X0Sw)
                if isfield(X0Sw,'SwitchStatus')
                    if isnumeric(X0Sw.SwitchStatus)||islogical(X0Sw.SwitchStatus)
                        if length(X0Sw.SwitchStatus)==length(SPS.SwitchGateInitialValue)
                            SPS.SwitchGateInitialValue=X0Sw.SwitchStatus';
                        else

                            Erreur.message='The length of the specified switch status vector do not match the number of switches in the model.';
                            Erreur.identifier='SpecializedPowerSystems:PowerAnalyze:SwitchStatusDimensionError';
                            psberror(Erreur);
                        end
                    else

                        Erreur.message='The switch status variable must be a structure with specific fields. See power_analyze help for more details on how to use the ''setSwitchStatus'' option.';
                        Erreur.identifier='SpecializedPowerSystems:PowerAnalyze:SwitchStatusDimensionError';
                        psberror(Erreur);
                    end
                else

                    Erreur.message='The switch status variable must be a structure with specific fields. See power_analyze help for more details on how to use the ''setSwitchStatus'' option.';
                    Erreur.identifier='SpecializedPowerSystems:PowerAnalyze:SwitchStatusDimensionError';
                    psberror(Erreur);
                end
            else

                Erreur.message='The switch status variable must be a structure with specific fields. See power_analyze help for more details on how to use the ''setSwitchStatus'' option.';
                Erreur.identifier='SpecializedPowerSystems:PowerAnalyze:SwitchStatusDimensionError';
                psberror(Erreur);
            end
        end
    end


    if~isempty(SPS.PowerguiInfo.BlockName)
        SPS.PowerguiInfo.EquivalentModel=[SPS.PowerguiInfo.BlockName,'/EquivalentModel',num2str(SPSnetwork)];
    end

    if isfield(SPS,'RmXfoWarning')








        rlc=SPS.rlc;
        Ntr=rlc(SPS.RmXfoWarning.rlcN,1:2);


        for side=1:2





            N=Ntr(side);

            if side==1

                rlc(SPS.RmXfoWarning.rlcN,:)=[];
                rlc(SPS.RmXfoWarning.rlcN,:)=[];
                rlc(SPS.RmXfoWarning.rlcN,:)=[];
            end

            while~isempty(N)


                Branches=rlc(:,1)==N;
                otherside=2;
                if all(Branches==0)
                    Branches=rlc(:,2)==N;
                    otherside=1;
                end


                if sum(Branches)==1


                    if rlc(Branches,5)>0


                        message=['Modeling constraints in Simscape Electrical Specialized Power Systems require that you specify a finite positive magnetization resistance (Rm) value for the ''',SPS.RmXfoWarning.name,''' transformer block.',...
                        newline,'When the primary winding of a transformer block is connected in series with an inductance, its magnetization resistance must have a finite value. In most situations, setting Rm to 1e6 can be used to represent an infinite magnetization resistance.'];
                        Erreur.message=message;
                        Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
                        psberror(Erreur);
                    else

                        N=rlc(Branches,otherside);


                        rlc(Branches,:)=[];
                    end

                else

                    N=[];
                end

            end

        end

    end


    SPS.PowerguiInfo.EchoMessage=PowerguiInfo.EchoMessage;

    SPS=SPSrl('eval',Rules.PostBlockAnalysisFcn,'PostBlockAnalysisFcn',SPS);


    if Rules.StopAfterBlockAnalysisFcn
        return
    end








    keeprlc=SPS.rlc;
    SPS=nscinet(SPS);



    if SPS.PowerguiInfo.DisplayEquations&&SPS.ForceLonToZero.status==1
        message{1}='The following power electronic switches have internal inductance (Lon) greater than zero.';
        message{2}=' ';
        message2{1}=' ';
        message2{2}='You have specified to discretize the circuit. Internal inductance will be set to zero.';
        message2{3}='To ignore Simscape Electrical Specialized Power Systems warnings, select "Disable Specialized Power Systems warnings" in the Powergui Preferences tab.';
        message=[message';SPS.ForceLonToZero.blocks';message2'];
        warndlg(message,sys);
        warning('SpecializedPowerSystems:Compilation:LonForcedTozero',message{:});
    end



    ThereAreNonlinearModels=(SPS.NumberOfSfunctionSwitches+SPS.NbMachines+length(SPS.DistributedParameterLine))>0;

    if(SPS.PowerguiInfo.Continuous&&ThereAreNonlinearModels)||(length(SPS.SPIDresistors)>0)%#ok mlint



        UpdatePowerGuiFlag(true,sys);


        CurrentSolver=get_param(sys,'Solver');

        switch CurrentSolver
        case{'ode23tb'}

        case{'VariableStepAuto'}

        otherwise

            Sentense_1='You have required continuous-time simulation of a system containing switches or nonlinear elements. ';
            Sentense_2='The ode23tb variable-step stiff solver with relative tolerance set to 1e-4 generally gives best accuracy and simulation performance. ';
            Sentense_3='For some highly nonlinear models it may be necessary to set the "Solver reset method" parameter to "Robust". ';
            Sentense_4='See "Improving Simulation Performance" chapter in Specialized Power Systems documentation for additional information on how to select an appropriate integration method.';
            Sentense_5='To ignore Simscape Electrical Specialized Power Systems warnings, select "Disable Specialized Power Systems warnings" in the Powergui Preferences tab.';

            if SPS.PowerguiInfo.FunctionMessages==0
                if SPS.PowerguiInfo.DisplayEquations

                    WarningMessage{1}=Sentense_1;
                    WarningMessage{2}=' ';
                    WarningMessage{3}=[Sentense_2,Sentense_3];
                    WarningMessage{4}=' ';
                    WarningMessage{5}=Sentense_4;
                    WarningMessage{6}=' ';
                    WarningMessage{7}=Sentense_5;
                    warndlg(WarningMessage,sys,'replace');
                    warning('SpecializedPowerSystems:powersolve:RecommendedSolver',WarningMessage{:});

                else




                    if SPS.PowerguiInfo.SPID==0
                        warning off backtrace;
                        WarningMessage=[Sentense_1,'\n',Sentense_2,'\n',Sentense_3,'\n',Sentense_4,'\n',Sentense_5];
                        warning('SpecializedPowerSystems:powersolve:RecommendedSolver',WarningMessage);
                        warning on backtrace;
                    end
                end
            end
        end
    else

        UpdatePowerGuiFlag(false,sys);
    end



    SPS=SPSrl('eval',Rules.PreStateSpaceFcn,'PreStateSpaceFcn',SPS);

    if isempty(SPS.rlc)&&isempty(SPS.source)
        NeedStateSpaceCalculations=0;
    elseif isempty(SPS.yout)&&isempty(SPS.source)
        NeedStateSpaceCalculations=0;
    else
        NeedStateSpaceCalculations=1;
    end

    SPS.unit='OMU';
    SPS.freq=60;

    if~isempty(SPS.rlcnames)
        SPS.rlcnames=strrep(SPS.rlcnames,newline,' ');
    end

    NumberOfOutputs=size(SPS.yout,1);
    NumberOfSources=size(SPS.source,1);


    [SPS.rlc,SPS.liste_neu]=etapar(SPS.rlc,SPS.switches,SPS.source,NumberOfOutputs,0,SPS.unit,1,FID,SPS.rlcnames,SPS.srcstr);


    if NeedStateSpaceCalculations

        CommandLine=0;
        Silent=~SPS.PowerguiInfo.EchoMessage;
        EquivalentCircuit=1;
        [SPS,statescell,~,~,~,~]=psb2sys(SPS,CommandLine,Silent,FID);


        if SPS.PowerguiInfo.SPID
            if SPS.Mg_nbNotRed.y==0
                if(SPS.Mg_nbNotRed.u==0)||(isempty(SPS.C)&&isempty(SPS.D))
                    if(SPS.Mg_nbNotRed.s==0)

                        EquivalentCircuit=0;
                        NeedStateSpaceCalculations=0;
                    end
                end
            end
        else
            if isempty(SPS.C)&&isempty(SPS.D)

                EquivalentCircuit=0;
                NeedStateSpaceCalculations=0;
            end
        end

    else

        SPS.A=[];
        SPS.B=[];
        SPS.C=[];
        SPS.D=[];
        SPS.MgNotRed=[];
        SPS.MgColNamesNotRed=[];
        SPS.Mg_nbNotRed=[];
        SPS.Mg=[];
        SPS.MgColNames=[];
        SPS.Mg_nb=[];
        SPS.MatStateDependency=[];
        statescell=[];
        EquivalentCircuit=0;

    end

    TotalNumberOfStates=size(char(statescell),1);
    NumberOfStates=size(SPS.A,1);
    NumberOfDependentStates=TotalNumberOfStates-NumberOfStates;

    SPS.TotalStates=statescell;
    SPS.IndependentStates=statescell(1:NumberOfStates);
    SPS.DependentStates=statescell(NumberOfStates+1:TotalNumberOfStates);
    if isempty(SPS.DependentStates)
        SPS.DependentStates=[];
    end

    if SPS.PowerguiInfo.SPID
        SPS.IndependentStates=SPS.IndependentStates';
        SPS.DependentStates=SPS.DependentStates';
    end


    SPS.states=statescell;
    for i=NumberOfStates+1:TotalNumberOfStates

        SPS.states{i}=[SPS.states{i},'*'];
    end


    if~isempty(SPS.switches)

        SPS.rlswitch=[SPS.switches(:,4),SPS.switches(:,5)];
        SPS.rlswitch(:,2)=SPS.rlswitch(:,2)./1000;
    else
        SPS.rlswitch=[];
    end
    NumberOfSwitches=size(SPS.switches,1);

    if isempty(SPS.B)
        SPS.B=zeros(NumberOfStates,NumberOfSources);
    end
    if isempty(SPS.C)
        SPS.C=zeros(NumberOfOutputs,NumberOfStates);
    end
    if isempty(SPS.D)



        SPS.D=zeros(NumberOfOutputs,1);
        SPS.B=zeros(NumberOfStates,1);
    end

    if SPS.PowerguiInfo.EchoMessage
        if EquivalentCircuit
            if NumberOfSwitches
                fprintf(' (%i states ; %i inputs ; %i outputs ; %i switches)',NumberOfStates,NumberOfSources,NumberOfOutputs,NumberOfSwitches);
            else
                fprintf(' (%i states ; %i inputs ; %i outputs)',NumberOfStates,NumberOfSources,NumberOfOutputs);
            end
        end
    end











    if~isempty(SPS.Rswitch)&&SPS.PowerguiInfo.SPID==0
        Nswitches=length(SPS.Rswitch);
        SPS.YSwitchCurrent=zeros(1,Nswitches);
        for i=1:NumberOfOutputs
            if all(SPS.C(i,:)==0)
                if sum(abs(SPS.D(i,:)))==1
                    indicesDu=find(abs(SPS.D(i,1:Nswitches))==1);
                    if~isempty(indicesDu)
                        SPS.YSwitchCurrent(indicesDu)=i;
                    end
                end
            end
        end
    else
        SPS.YSwitchCurrent=[];
    end
    SPS=SPSrl('eval',Rules.PostStateSpaceFcn,'PostStateSpaceFcn',SPS);



    if Rules.CreateNetList

        disp(['Netlist information is saved in ',sys,'.net file']);
        fclose(FID);
        return
    end



    SPS.SwitchResistance=SPS.Rswitch';
    SPS=getInterpolationMatrices(SPS);



    SPS=SPSrl('eval',Rules.PreDiscretizeFcn,'PreDiscretizeFcn',SPS);

    if SPS.PowerguiInfo.Discrete&&EquivalentCircuit
        if SPS.PowerguiInfo.EchoMessage
            disp(['Computing discrete-time domain model of linear part of circuit (Ts=',num2str(SPS.PowerguiInfo.Ts),') ...']);
        end
        [SPS.Adiscrete,SPS.Bdiscrete,SPS.Cdiscrete,SPS.Ddiscrete]=psb_c2d(SPS.A,SPS.B,SPS.C,SPS.D,SPS.PowerguiInfo.Ts,SPS.PowerguiInfo.SolverType);
    else
        SPS.Adiscrete=[];
        SPS.Bdiscrete=[];
        SPS.Cdiscrete=[];
        SPS.Ddiscrete=[];
    end

    SPS=SPSrl('eval',Rules.PostDiscretizeFcn,'PostDiscretizeFcn',SPS);





    SPS=SPS_ReduceDistLinePhasor(SPS);


    if~isempty(SPS.DSS)
        if~isempty(SPS.DSS.block)
            if SPS.PowerguiInfo.DiscretePhasor

                for i=1:length(SPS.DSS.block)


                    SPS.DSS.block(i).inputs=[SPS.DSS.block(i).inputs,SPS.DSS.block(i).inputs+length(SPS.InputsNotDistLine)];
                    SPS.DSS.block(i).outputs=[SPS.DSS.block(i).outputs,SPS.DSS.block(i).outputs+length(SPS.OutputsNotDistLine)];
                end

                for i=1:length(SPS.DSS.block)
                    SPS.DSS.block(i).size=[0,length(SPS.DSS.block(i).inputs),length(SPS.DSS.block(i).outputs)];
                    SPS.DSS.model.NonLinearDim(i,1:3)=SPS.DSS.block(i).size;

                    SPS.DSS.model.inMux(i)=SPS.DSS.model.NonLinearDim(i,2)*SPS.DSS.model.NonLinearDim(i,3);
                    SPS.DSS.block(i).method=2;
                end

                SPS=DSS_SortNonLinearIO_phasor(SPS);

            else

                SPS=DSS_SortNonLinearIO(SPS);


                SPS.DSS.model.NonLinearxInit=[];
                SPS.DSS.model.NonLinear_VI=[];
                for i=1:length(SPS.DSS.block)
                    SPS.DSS.model.NonLinearDim(i,1:3)=SPS.DSS.block(i).size;
                    SPS.DSS.model.NonLinearxInit=[SPS.DSS.model.NonLinearxInit,SPS.DSS.block(i).xInit];
                    SPS.DSS.model.NonLinearIterative(i,1)=[SPS.DSS.block(i).iterate];
                    if~isempty(SPS.DSS.block(i).VI)
                        SPS.DSS.model.NonLinear_VI=[SPS.DSS.model.NonLinear_VI;SPS.DSS.block(i).VI];
                        SPS.DSS.model.NonLinear_SizeVI(i,1)=size(SPS.DSS.block(i).VI,1);
                    else
                        SPS.DSS.model.NonLinear_SizeVI(i,1)=0;
                    end
                    SPS.DSS.model.NonLinear_Method=[SPS.DSS.block(:).method]';
                    SPS.DSS.model.NonLinear_InitialOutputs(i,1:size(SPS.DSS.block(i).yinit,2))=SPS.DSS.block(i).yinit;
                end
            end

        else
            if SPS.PowerguiInfo.DiscretePhasor


                SPS.DSS.model.NonLinearDim=[];
                SPS.DSS.model.NonLinear_Inputs=[];
                SPS.DSS.model.NonLinear_Outputs=[];
                SPS.DSS.model.Index_RowNumber_H=1:2*NumberOfOutputs;
                SPS.DSS.model.Index_ColNumber_H=1:2*NumberOfSources;

                SPS.DSS.model.reordersrc.indices=1:2*NumberOfSources;
                SPS.DSS.model.reordersrc.width=2*NumberOfSources;
                SPS.DSS.model.reorderout.indices=1:2*NumberOfOutputs;
                SPS.DSS.model.reorderout.width=2*NumberOfOutputs;

            end
        end
    end



    if Rules.CreateSSobject
        return
    end



    SPS=SPSrl('eval',Rules.PreSteadyStateFcn,'PreSteadyStateFcn',SPS);


    if EquivalentCircuit
        if SPS.PowerguiInfo.EchoMessage
            disp('Computing steady-state values of currents and voltages ...');
        end
        SPS=etass(SPS,X0Sw);
    else
        SPS.Aswitch=[];
        SPS.Bswitch=[];
        SPS.Cswitch=[];
        SPS.Dswitch=[];
        SPS.x0switch=[];
        SPS.Hlin=[];

        SPS.OscillatoryModes=[];

        SPS.uss=[];
        SPS.u0=[];
        SPS.xss=[];
        SPS.yss=[];
        SPS.freq=[];
        SPS.Hlin=[];
        SPS.x0=zeros(size(SPS.A,1),1);
        SPS.xss=SPS.x0;
    end
    SPS.xssDependentStates=[];



    if Rules.StopAfterLoadFlowDatas


        Bars=3*length(SPS.LoadFlow.bus);
        SPS.LoadFlow.H=SPS.Hlin(end-Bars+1:end,end-Bars+1:end);
        return
    end



    if Rules.StopAfterUnbalancedLoadFlowDatas



        Bars=length(SPS.UnbalancedLoadFlow.bus);
        SPS.UnbalancedLoadFlow.H=SPS.Hlin(end-Bars+1:end,end-Bars+1:end);
        return
    end





    SPS.x0_blocks=SPS.x0;
    SPS.x0_SteadyState=SPS.x0;
    SPS.x0perm=SPS.x0;
    SPS.x0discrete=SPS.x0;
    SPS.x0AllStates=SPS.x0;
    SPS.x0DependentStates=[];





    if NeedStateSpaceCalculations


        for i=1:length(SPS.BlockInitialState.value)
            StateValue=SPS.BlockInitialState.value{i};
            if~isnan(StateValue)

                StateName=SPS.BlockInitialState.state{i};

                DependentState=1;

                for j=1:TotalNumberOfStates
                    State=SPS.states{j};
                    if strcmp(StateName,State)

                        SPS.x0(j)=StateValue;
                        DependentState=0;
                        break
                    end
                end


                if DependentState
                    DependentStateName=strrep(SPS.BlockInitialState.state{i},newline,'');
                    switch SPS.BlockInitialState.type{i}
                    case 'Initial voltage'
                        M1='The capacitor initial voltage';
                        M2='capacitor voltage';
                    case 'Initial current'
                        M1='The inductor initial current';
                        M2='inductor current';
                    end
                    Sentense_1=[M1,' you have specified in the following block will be ignored by Specialized Power Systems: '];
                    Sentense_2=DependentStateName;
                    Sentense_3=['The ',M2,' of this block is not selected by Specialized Power Systems as an independent state variable.'];
                    Sentense_4=['Use the Initial States Setting tool of Powergui block to see which ',M2,'s you can initialize.'];
                    warndlg({Sentense_1,' ',...
                    Sentense_2,' ',...
                    Sentense_3,Sentense_4},...
                    'Initial state conflict');
                    warning('SpecializedPowerSystems:DependentState:IgnoreInitialState',char(Sentense_1',10,Sentense_2'))
                end
            end
        end








        PowerguiUserData=get_param(SPS.PowerguiInfo.BlockName,'userdata');
        if isfield(PowerguiUserData,'BlockInitialState')
            for i=1:length(PowerguiUserData.BlockInitialState.value)


                StateName=PowerguiUserData.BlockInitialState.state{i};
                StateValue=PowerguiUserData.BlockInitialState.value{i};

                for j=1:TotalNumberOfStates
                    State=SPS.states{j};
                    if strcmp(StateName,State)

                        SPS.x0(j)=StateValue;
                        break
                    end
                end
            end
        end



        SPS.x0_blocks=SPS.x0;



        if~isempty(SPS.PowerguiInfo.BlockName)
            x0status=get_param(SPS.PowerguiInfo.BlockName,'x0status');
            if strcmp('zero',x0status)

                disp('The electrical initial states of your model are forced to zero by the powergui block.');
                SPS.x0=SPS.x0.*0;
            end
            if strcmp('steady',x0status)

                disp('The electrical initial states of your model are forced to steady state by the powergui block.');
                SPS.x0=SPS.x0_SteadyState;
            end
        end


        if SPS.PowerguiInfo.Discrete&&NeedStateSpaceCalculations
            if~isempty(SPS.x0)


                u0=SPS.u0;


                I=eye(size(SPS.A));
                u0(SPS.switches(:,3)==1)=0;
                if isempty(u0)
                    u0=0;
                end
                switch SPS.PowerguiInfo.SolverType
                case 'Backward Euler'

                    SPS.x0discrete=(I-SPS.Aswitch*SPS.PowerguiInfo.Ts)*(SPS.x0/SPS.PowerguiInfo.Ts)-SPS.Bswitch*u0;
                case{'Tustin','Tustin/Backward Euler (TBE)'}

                    SPS.x0discrete=(I-SPS.Aswitch*SPS.PowerguiInfo.Ts/2)*(SPS.x0/SPS.PowerguiInfo.Ts)-SPS.Bswitch/2*u0;
                end

            end
        end



        if isempty(SPS.u0)
            SPS.y0=SPS.Cswitch*SPS.x0;
        else
            SPS.y0=SPS.Cswitch*SPS.x0+SPS.Dswitch*SPS.u0;
        end

    end



    if SPS.PowerguiInfo.SPID

        if NeedStateSpaceCalculations













            nb=SPS.Mg_nbNotRed;
            StateNamesMgNotRed=SPS.MgColNamesNotRed(nb.x+nb.y+2*nb.s+1:end-nb.u);

            if NumberOfDependentStates
                MatDep=rref([SPS.MatStateDependency(:,NumberOfStates+1:end),SPS.MatStateDependency(:,1:NumberOfStates)]);



                SPS.x0DependentStates=-MatDep(:,NumberOfDependentStates+1:end)*SPS.x0;
                x0=[SPS.x0;-MatDep(:,NumberOfDependentStates+1:end)*SPS.x0];

                SPS.x0AllStates=x0;

                SPS.xssDependentStates=-MatDep(:,NumberOfDependentStates+1:end)*SPS.xss;
            else
                x0=SPS.x0;
            end

            SPS.x0spid=zeros(nb.x,1);


            if~isempty(x0)
                for i=1:nb.x
                    SPS.x0spid(i)=x0(strcmp(StateNamesMgNotRed(i),SPS.TotalStates)==1);
                end
            end

        else
            SPS.x0spid=SPS.x0;
        end

    end

    SPS=SPSrl('eval',Rules.PostSteadyStateFcn,'PostSteadyStateFcn',SPS);



    if Rules.CalledByPowerAnalyze
        return
    end



    for i=1:length(SPS.DCMachines)

        Parent=get_param(SPS.DCMachines{i},'Parent');
        if~isequal(Parent,sys)
            LinkStatus=get_param(Parent,'linkstatus');
        else
            LinkStatus='none';
        end
        if~isequal(LinkStatus,'resolved')



            StateName=['Il_',strrep(SPS.DCMachines{i}(SPS.syslength:end),newline,char(32)),'/Rf Lf'];
            StateNumber=find(strcmp(SPS.states,StateName));
            if~isempty(StateNumber)
                set_param(SPS.DCMachines{i},'Ifinit',mat2str(SPS.x0(StateNumber)));
            end
        end
    end







    for i=1:length(SPS.SaturableTransfo)


        Parent=get_param(SPS.SaturableTransfo(i).Name,'Parent');
        if~isequal(Parent,sys)
            LinkStatus=get_param(Parent,'linkstatus');
        else
            LinkStatus='none';
        end
        if~isequal(LinkStatus,'resolved')
            switch SPS.SaturableTransfo(i).Type
            case 'Single-Phase'

                InitialFlux=CalculateInitialFlux(SPS.SaturableTransfo(i).Output,SPS.yss,SPS.freq);
                set_param(SPS.SaturableTransfo(i).Name,'InitialFlux',mat2str(InitialFlux));
            case 'Three-Phase'

                Yindice=SPS.SaturableTransfo(i).Output;
                BaseFlux=SPS.SaturableTransfo(i).BaseFlux;
                InitialFlux1=CalculateInitialFlux(Yindice,SPS.yss,SPS.freq);
                InitialFlux2=CalculateInitialFlux(Yindice+1,SPS.yss,SPS.freq);
                InitialFlux3=CalculateInitialFlux(Yindice+2,SPS.yss,SPS.freq);


                UNITS=get_param(SPS.SaturableTransfo(i).Name,'UNITS');
                if strcmp(UNITS,'SI')
                    set_param(SPS.SaturableTransfo(i).Name,'InitialFluxes',mat2str([InitialFlux1,InitialFlux2,InitialFlux3]));
                else
                    set_param(SPS.SaturableTransfo(i).Name,'InitialFluxes',mat2str([InitialFlux1,InitialFlux2,InitialFlux3]/BaseFlux));
                end
            end
        end
    end



    Lignes=SPS.modelnames(19);
    Lignes=Lignes{1};
    for i=1:length(SPS.DistributedParameterLine)
        if SPS.DistributedParameterLine{i}.WB==0
            [x1,x2,x3,x4,x5,nharmo]=initdistline(SPS,i);
            Bloc=Lignes(i);


            if any(isnan([x1(:);x2(:);x3(:);x4(:);x5(:)]))

                x1=ones(size(x1));
                x2=x1;
                x3=x1;
                x4=x1;
            end

            if SPS.PowerguiInfo.Continuous
                set_param(Bloc,'V1',mat2str(x1,4),'V2',mat2str(x2,4),'I1',mat2str(x3,4),'I2',mat2str(x4,4),'nharmo',mat2str(nharmo));
            end
            set_param(Bloc,'x1',mat2str(x1),'x2',mat2str(x2),'x3',mat2str(x3),'x4',mat2str(x4),'x5',mat2str(x5));



            if SPS.DistributedParameterLine{i}.Decoupling
                nPhases=length(SPS.DistributedParameterLine{i}.Vs);

                Vs=zeros(1,nPhases);
                Vr=zeros(1,nPhases);
                Ihs=zeros(1,nPhases);
                Ihr=zeros(1,nPhases);

                for iphase=1:nPhases
                    Vs(iphase)=SPS.yss(SPS.DistributedParameterLine{i}.Vs(iphase));
                    Vr(iphase)=SPS.yss(SPS.DistributedParameterLine{i}.Vr(iphase));
                    Ihs(iphase)=SPS.uss(SPS.DistributedParameterLine{i}.Is(iphase));
                    Ihr(iphase)=SPS.uss(SPS.DistributedParameterLine{i}.Ir(iphase));
                end

                set_param(SPS.DistributedParameterLine{i}.BlockName,'VsMag0',mat2str(abs(Vs)),'VsAngle0',mat2str(angle(Vs)*180/pi));
                set_param(SPS.DistributedParameterLine{i}.BlockName,'VrMag0',mat2str(abs(Vr)),'VrAngle0',mat2str(angle(Vr)*180/pi));
                set_param(SPS.DistributedParameterLine{i}.BlockName,'IsMag0',mat2str(abs(Ihs)),'IsAngle0',mat2str(angle(Ihs)*180/pi));
                set_param(SPS.DistributedParameterLine{i}.BlockName,'IrMag0',mat2str(abs(Ihr)),'IrAngle0',mat2str(angle(Ihr)*180/pi));
            end
        end
    end



    if~isempty(SPS.DSS.block)
        for i=1:length({SPS.DSS.block.Blockname})
            switch get_param(SPS.DSS.block(i).Blockname,'MaskType')
            case 'Variable Capacitor'
                set_param(SPS.DSS.block(i).Blockname,'iC0',num2str(SPS.y0(SPS.DSS.block(i).outputs)));
            case 'Variable Inductor'
                set_param(SPS.DSS.block(i).Blockname,'Vl0',num2str(SPS.y0(SPS.DSS.block(i).outputs)));
            end
        end
    end


    if isempty(SPS.PowerguiInfo.BlockName)
        return
    end



    SPS=SPSrl('eval',Rules.PreEquivalentCircuitFcn,'PreEquivalentCircuitFcn',SPS);

    SpecialCircuit=0;
    if Rules.CalledByPowergui

        SPS.makecircuit=1;
    else
        syslength=length(sys)+2;
        Measurement=strrep(SPS.PowerguiInfo.BlockName,newline,' ');
        if EquivalentCircuit
            if SPS.PowerguiInfo.EchoMessage
                disp(['Building the Simulink model inside "',Measurement(syslength:end),'" block ...']);
            end
            spsbuild(SPS,SPSnetwork);
        else
            SSINPUTS=~isempty(SPS.source);
            SSOUTPUTS=~isempty(SPS.yout);
            if SSINPUTS&&SSOUTPUTS





                if isempty(SPS.A)&&isempty(SPS.B)&&isempty(SPS.C)&&~isempty(SPS.D)
                    if SPS.PowerguiInfo.EchoMessage
                        disp(['Building the Simulink model inside "',Measurement(syslength:end),'" block ...']);
                    end
                    spsbuild(SPS,SPSnetwork,'SimpleMatrixGainBlock');
                    SpecialCircuit=1;
                end
            elseif SSINPUTS


                if SPS.PowerguiInfo.EchoMessage
                    OrphanBlock=strrep(getfullname(SPS.sourcenames(1)),newline,' ');
                    disp(['The circuit containing the block ''',OrphanBlock,''' has no measurement.'])
                    disp('---> This circuit will be ignored during compilation.');
                    disp('---> Simulation results associated to this circuit, if any, will be irrelevant.');
                end
                spsbuild(SPS,SPSnetwork,'DummyFroms');
                SpecialCircuit=1;
            elseif SSOUTPUTS


                spsbuild(SPS,SPSnetwork,'DummyGotos');
                SpecialCircuit=1;
            else
                if ishandle(options)

                    OrphanBlockMaskType=get_param(options,'MaskType');
                    if strcmp('InnerPowersysBlock',OrphanBlockMaskType)

                        OrphanBlock=get_param(options,'Parent');




                        switch get_param(OrphanBlock,'MaskType')
                        case{'Synchronous Machine','Permanent Magnet Synchronous Machine','Asynchronous Machine','Simplified Synchronous Machine','Single Phase Asynchronous Machine'}

                            message=['Due to modeling constraints in Simscape Electrical Specialized Power Systems, the terminals of ''',OrphanBlock,''' block cannot be left opened.',...
                            newline,'Connect this block to a Simscape Power Systems circuit or consider removing it from your model.'];
                            erreur.message=message;
                            erreur.identifier='SpecializedPowerSystems:blockconnectionerror';
                            psberror(erreur);
                        end

                        Blocks=get_param(OrphanBlock,'blocks');
                        GotoExist=0;
                        FromExist=0;
                        for i=1:length(Blocks)
                            BL=strrep(Blocks{i},'/','//');
                            BlockToTest=[OrphanBlock,'/',BL];
                            ThisIsaGoto=strcmp('Goto',get_param(BlockToTest,'BlockType'));
                            ThisIsaFrom=strcmp('From',get_param(BlockToTest,'BlockType'));
                            if ThisIsaGoto
                                GotoExist=1;
                                SPS.U.Mux(end+1)=1;
                                SPS.U.Tags{end+1}=get_param(BlockToTest,'GotoTag');
                            end
                            if ThisIsaFrom
                                FromExist=1;
                                BUT=Blocks(i);
                                switch BUT{1}
                                case 'Status'
                                    if SPS.PowerguiInfo.SPID
                                        FG=2;
                                    else
                                        FG=1;
                                    end
                                otherwise
                                    FG=1;
                                end
                                SPS.Y.Demux(end+1)=FG;
                                SPS.Y.Tags{end+1}=get_param(BlockToTest,'GotoTag');
                            end
                        end

                        if GotoExist&&~FromExist
                            spsbuild(SPS,SPSnetwork,'DummyFroms');
                        elseif GotoExist&&FromExist
                            spsbuild(SPS,SPSnetwork,'DummyFromsGotos');
                        elseif~GotoExist&&FromExist
                            spsbuild(SPS,SPSnetwork,'DummyGotos');
                        end

                        if SPS.PowerguiInfo.EchoMessage
                            OrphanBlock=strrep(OrphanBlock,newline,' ');
                            disp(['---> The ',OrphanBlock,' block will be ignored during compilation.'])
                            disp('---> Simulation results associated to this block, if any, will be irrelevant.');
                        end

                    else

                        powersysdomain_netlist('NoEquivalentCircuit');
                        if SPS.PowerguiInfo.EchoMessage
                            OrphanBlock=strrep(getfullname(options),newline,' ');
                            disp(['---> The ',OrphanBlock,' block will be ignored during compilation.'])
                        end
                    end
                end
            end
        end
        SPS.makecircuit=0;
    end


    SPS.rlc=keeprlc;
    if~Rules.CalledByPowergui&&(EquivalentCircuit||SpecialCircuit)
        set_param([SPS.PowerguiInfo.BlockName,'/EquivalentModel',num2str(SPSnetwork)],'UserData',SPS);


    end

    SPS=SPSrl('eval',Rules.PostEquivalentCircuitFcn,'PostEquivalentCircuitFcn',SPS);


    NumBerOfMultimeterBlocks=size(SPS.multimeters,1);
    if SPS.PowerguiInfo.EchoMessage&&NumBerOfMultimeterBlocks
        disp('Updating multimeter blocks ...')
    end

    for y=1:NumBerOfMultimeterBlocks
        MultimeterMask(SPS.multimeters{y},'powersolve',SPS);
    end



    set_param([SPS.PowerguiInfo.BlockName,'/Ground'],'UserData',[]);


    if SPS.PowerguiInfo.EchoMessage
        disp('Ready.');
    end


    function InitialFlux=CalculateInitialFlux(OutputIndice,Yss,Frequencies)


        if isempty(Frequencies)
            InitialFlux=0;
            return
        end
        InitialFlux=0;
        for j=1:size(Yss,2)
            if Frequencies(j)>0&&isfinite(Yss(OutputIndice,j))
                InitialFlux=InitialFlux-real(Yss(OutputIndice,j))/(2*pi*Frequencies(j));
            end
        end




        function varargout=UpdatePowerGuiFlag(input,sys)%#ok





            solverFlags=get_param(sys,'SolverStatusFlags');








            SL_CS_STATUS_POWERGUI=32;

            if(input)
                if(solverFlags>0)
                    solverFlags=bitor(solverFlags,SL_CS_STATUS_POWERGUI);
                else
                    solverFlags=SL_CS_STATUS_POWERGUI;
                end
            else
                if(solverFlags>0)
                    if(bitand(solverFlags,SL_CS_STATUS_POWERGUI))
                        solverFlags=bitxor(solverFlags,SL_CS_STATUS_POWERGUI);
                    end
                end
            end

            set_param(sys,'SolverStatusFlags',solverFlags);



            function SPS=SPS_ReduceDistLinePhasor(SPS)

                if SPS.PowerguiInfo.Phasor||SPS.PowerguiInfo.DiscretePhasor


                    sources=char(SPS.srcstr);
                    Nu=size(sources,1);
                    outputs=char(SPS.outstr);
                    Ny=size(outputs,1);

                    SPS.InputsNotDistLine=[];
                    for i=1:Nu
                        if isempty(strfind(sources(i,:),'I_in_phase_'))&&isempty(strfind(sources(i,:),'I_out_phase_'))
                            SPS.InputsNotDistLine=[SPS.InputsNotDistLine,i];
                        end
                    end

                    SPS.OutputsNotDistLine=[];
                    for i=1:Ny
                        if isempty(strfind(outputs(i,:),'U_in_phase_'))&&isempty(strfind(outputs(i,:),'U_out_phase_'))
                            SPS.OutputsNotDistLine=[SPS.OutputsNotDistLine,i];
                        end
                    end

                end

