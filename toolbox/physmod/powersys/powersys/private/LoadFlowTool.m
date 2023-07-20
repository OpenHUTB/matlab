function varargout=LoadFlowTool(varargin)

























    if nargout==1
        varargout{1}=[];
    end
    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_loadflow'));
    end
    sys=varargin{1};

    if exist(sys,'file')==4
        load_system(sys);
    end

    switch get_param(sys,'librarytype')
    case 'BlockLibrary'
        if nargout==1
            LF.error='The load flow function cannot be used on library blocks';
            varargout{1}=LF;
        end
        return
    end
    switch lower(varargin{2})
    case{'parameters','solve','detailed','noupdate','addbuses','solvefromapp'}
        Action=varargin{2};
    otherwise
        Erreur.message=sprintf('Unknown input argument');
        Erreur.identifier='SpecializedPowerSystems:Powerloadflow:InputArguments';
        psberror(Erreur);
        return
    end

    PowerguiInfo=getPowerguiInfo(sys,[]);
    if isempty(PowerguiInfo.BlockName)
        if nargout==1
            LF.error='There is no Powergui block in the model';
            varargout{1}=LF;
        end
        return
    end
    LF=[];
    switch nargin
    case 3
        if isstruct(varargin{3})
            LF=varargin{3};
        end
    end

    LoadFlowSolver=determineLoadFlowSolver(sys);
    switch LoadFlowSolver
    case 'Mixed'
        if nargout==1
            LF.error='Your model contains a mix of Load Flow Bus blocks set to perfom a Positive-Sequence load flow and set to perform an Unbalanced load flow. Please ensure that the Load Flow Bus blocks are set to perform either one or the other load flow type, but not both at the same time';
            LF.LoadFlowSolver='Mixed';
            varargout{1}=LF;
        end
        return
    end
    if isempty(LF)
        switch LoadFlowSolver
        case 'PositiveSequence'
            LF=power_analyze(sys,'GetLoadFlowData');

            [LF.Ybus1,LF.Ybus0,LF.Ybus2]=computeBalancedYbus(LF,PowerguiInfo.Pbase);
        case 'Unbalanced'
            LF=power_analyze(sys,'GetUnbalancedLoadFlowData');
            LF.Ybus=computeUnbalancedYbus(LF);
        end
        if isempty(LF.bus)
            if isempty(LF.error)
                LF.error='The model contains no Load Flow block';
            end

            switch Action
            case{'solve','detailed','noupdate','solvefromapp'}

                Action='parameters';
            end
        end
    end
    switch lower(Action)
    case 'parameters'
        LF.status=0;
    case{'noupdate','solve','detailed','solvefromapp'}
        switch LoadFlowSolver
        case 'PositiveSequence'
            LF=computeBalancedLoadFlow(LF);
        case 'Unbalanced'
            LF=computeUnbalancedLoadFlow(LF);
        end
    end
    if isempty(LF.error)
        switch Action
        case{'solve','detailed'}
            updateLoadFlowBlocks(LoadFlowSolver,LF,1);
        end
    end




    switch lower(Action)
    case 'addbuses'
        switch LoadFlowSolver
        case 'PositiveSequence'
            open_system(LF.model)
            LF=convertImplictLoadFlowBus(LF);
        case 'Unbalanced'
            LF=[];
            Erreur.message='The ''addbuses'' Action is not yet available to setup your model for unbalanced load flow.';
            Erreur.identifier='SpecializedPowerSystems:Powerloadflow:UnavailableInputArguments';
            warning(Erreur.identifier,Erreur.message);
        end
    end
    switch nargin
    case{3,4}
        if ischar(varargin{3})
            if LF.status==1
                LFFN=[];
                if nargin==4
                    if ischar(varargin{4})
                        LFFN=varargin{4};
                    end
                end
                switch lower(varargin{3})
                case{'report','rep'}
                    generateLoadFlowReport(LoadFlowSolver,LF,PowerguiInfo.UnitsV,PowerguiInfo.UnitsW,LFFN);
                case{'excelreport','excel'}
                    switch LoadFlowSolver
                    case 'PositiveSequence'
                        generateLoadFlowReport('Excel',LF,PowerguiInfo.UnitsV,PowerguiInfo.UnitsW,LFFN);
                    case 'Unbalanced'
                        Erreur.message='The ''excelreport'' Action is not yet available to produce Excel reports for unbalanced load flow.';
                        Erreur.identifier='SpecializedPowerSystems:Powerloadflow:UnavailableInputArguments';
                        warning(Erreur.identifier,Erreur.message);
                    end
                end
            end
        end
    end
    switch lower(Action)
    case{'noupdate','solve'}
        LF=restructureLF(LF,LoadFlowSolver);
    end
    if nargout==1
        switch lower(Action)
        case 'addbuses'
        otherwise
            LF.LoadFlowSolver=LoadFlowSolver;
        end
        varargout{1}=LF;
    end

    function LFstructured=restructureLF(LF,LoadFlowSolver)

        LFstructured.model=LF.model;
        LFstructured.frequency=LF.freq;
        LFstructured.basePower=LF.Pbase;
        LFstructured.tolerance=LF.ErrMax;
        LFstructured.Networks=LF.Networks;
        LFstructured.status=1;
        LFstructured.iterations=LF.niter;
        LFstructured.error=LF.error;
        switch LoadFlowSolver
        case 'PositiveSequence'
            LFstructured.Ybus1=LF.Ybus1;
        case 'Unbalanced'
            LFstructured.Ybus=LF.Ybus;
        end
        if~isempty(LF.bus)
            LFstructured.bus=struct(...
            'handle',{LF.bus.handle},...
            'ID',{LF.bus.ID},...
            'vbase',{LF.bus.vbase},...
            'vref',{LF.bus.vref},...
            'angle',{LF.bus.angle},...
            'sm',{LF.bus.sm},...
            'asm',{LF.bus.asm},...
            'vsrc',{LF.bus.vsrc},...
            'pqload',{LF.bus.pqload},...
            'rlcload',{LF.bus.rlcload},...
            'blocks',{LF.bus.blocks});
            for i=1:length(LF.bus)
                if LF.status==1


                    switch LF.bus(i).TypeNumber
                    case 1
                        BT='swing';
                    case 2
                        BT='PV';
                    case 3
                        BT='PQ';
                    end
                else
                    BT='';
                end
                LFstructured.bus(i).busType=BT;
            end
        else
            LFstructured.bus=[];
        end
        switch LoadFlowSolver
        case 'Unbalanced'

            LFstructured.sm=LF.sm;
            LFstructured.asm=LF.asm;
            LFstructured.vsrc=LF.vsrc;
            LFstructured.pqload=LF.pqload;
            LFstructured.rlcload=LF.rlcload;
            return
        end
        if isempty(LF.sm.blockType)
            LFstructured.sm=[];
        else
            LFstructured.sm=struct(...
            'handle',[LF.sm.handle],...
            'busNumber',[LF.sm.busNumber],...
            'busID',[LF.sm.busID],...
            'generatorType',[LF.sm.busType],...
            'Pnom',[LF.sm.pnom],...
            'Vnom',[LF.sm.vnom],...
            'P',[LF.sm.P],...
            'Q',[LF.sm.Q],...
            'Qmin',[LF.sm.Qmin],...
            'Qmax',[LF.sm.Qmax]);
        end
        if isempty(LF.asm.blockType)
            LFstructured.asm=[];
        else
            LFstructured.asm=struct(...
            'handle',[LF.asm.handle],...
            'busNumber',[LF.asm.busNumber],...
            'busID',[LF.asm.busID],...
            'Pnom',[LF.asm.pnom],...
            'Vnom',[LF.asm.vnom],...
            'Pmec',[LF.asm.P]);
        end
        if isempty(LF.vsrc.blockType)
            LFstructured.vsrc=[];
        else
            LFstructured.vsrc=struct(...
            'handle',[LF.vsrc.handle],...
            'busNumber',[LF.vsrc.busNumber],...
            'busID',[LF.vsrc.busID],...
            'generatorType',[LF.vsrc.busType],...
            'Vnom',[LF.vsrc.vnom],...
            'P',[LF.vsrc.P],...
            'Q',[LF.vsrc.Q],...
            'Qmin',[LF.vsrc.Qmin],...
            'Qmax',[LF.vsrc.Qmax]);
        end
        if isempty(LF.pqload.blockType)
            LFstructured.pqload=[];
        else
            LFstructured.pqload=struct(...
            'handle',[LF.pqload.handle],...
            'busNumber',[LF.pqload.busNumber],...
            'busID',[LF.pqload.busID],...
            'loadType',[LF.pqload.busType],...
            'Vnom',[LF.pqload.vnom],...
            'P',[LF.pqload.P],...
            'Q',[LF.pqload.Q]);
        end
        if isempty(LF.rlcload.blockType)
            LFstructured.rlcload=[];
        else
            LFstructured.rlcload=struct(...
            'handle',[LF.rlcload.handle],...
            'busNumber',[LF.rlcload.busNumber],...
            'busID',[LF.rlcload.busID],...
            'loadType',[LF.rlcload.busType],...
            'Vnom',[LF.rlcload.vnom],...
            'P',[LF.rlcload.P],...
            'Q',[LF.rlcload.Q]);
        end

        if LF.status~=1
            LFstructured.status=-1;
            LFstructured.error=LF.error;
            return
        end

        [LFstructured.bus.Sref]=LF.bus.Sref;
        [LFstructured.bus.Vbus]=LF.bus.Vbus;
        [LFstructured.bus.Sbus]=LF.bus.Sbus;
        [LFstructured.bus.Sgen]=LF.bus.Sgen;
        [LFstructured.bus.Spqload]=LF.bus.Spqload;
        switch LoadFlowSolver
        case 'PositiveSequence'
            [LFstructured.bus.Sshunt]=LF.bus.Sshunt;
        case 'Unbalanced'

        end
        [LFstructured.bus.Sref]=LF.bus.Sref;
        [LFstructured.bus.Qmin]=LF.bus.Qmin;
        [LFstructured.bus.Qmax]=LF.bus.Qmax;
        [LFstructured.bus.QminReached]=LF.bus.QminReached;
        [LFstructured.bus.QmaxReached]=LF.bus.QmaxReached;
        switch LoadFlowSolver
        case 'Unbalanced'

            LFstructured.sm=LF.sm;
            LFstructured.asm=LF.asm;
            LFstructured.vsrc=LF.vsrc;
            LFstructured.pqload=LF.pqload;
            LFstructured.rlcload=LF.rlcload;
            LFstructured.Ybus=LF.Ybus;
        case 'PositiveSequence'

            if~isempty(LFstructured.sm)
                [LFstructured.sm.S]=LF.sm.S{:};
                [LFstructured.sm.I]=LF.sm.I{:};
                [LFstructured.sm.Pmec]=LF.sm.pmec{:};
                [LFstructured.sm.Vt]=LF.sm.Vt{:};
                [LFstructured.sm.Vf]=LF.sm.Vf{:};
                [LFstructured.sm.th0]=LF.sm.th0deg{:};
                [LFstructured.sm.dw0]=LF.sm.dw0{:};
            end

            if~isempty(LFstructured.asm)
                [LFstructured.asm.S]=LF.asm.S{:};
                [LFstructured.asm.I]=LF.asm.I{:};
                [LFstructured.asm.T]=LF.asm.T{:};
                [LFstructured.asm.Vt]=LF.asm.Vt{:};
                [LFstructured.asm.slip]=LF.asm.slip{:};
            end

            if~isempty(LFstructured.vsrc)
                [LFstructured.vsrc.S]=LF.vsrc.S{:};
                [LFstructured.vsrc.I]=LF.vsrc.I{:};
                [LFstructured.vsrc.Vt]=LF.vsrc.Vt{:};
                [LFstructured.vsrc.Vint]=LF.vsrc.Vint{:};
            end

            if~isempty(LFstructured.pqload)
                [LFstructured.pqload.S]=LF.pqload.S{:};
                [LFstructured.pqload.I]=LF.pqload.I{:};
                [LFstructured.pqload.Vt]=LF.pqload.Vt{:};
            end

            if~isempty(LFstructured.rlcload)
                [LFstructured.rlcload.S]=LF.rlcload.S{:};
                [LFstructured.rlcload.I]=LF.rlcload.I{:};
                [LFstructured.rlcload.Vt]=LF.rlcload.Vt{:};
            end
            LFstructured.Ybus1=LF.Ybus1;
        end
        function[Ybus,Ybus0,Ybus2]=computeBalancedYbus(LF,Pbase)








            Nbus=length(LF.bus);
            NoutputRed=3*Nbus;
            NinputRed=3*Nbus;








            a=exp(1i*2*pi/3);
            Tabc2pos=[1,a,a^2]/3;
            Tabc2zero=[1,1,1]/3;
            Tabc2neg=[1,a^2,a]/3;
            Tout=zeros(Nbus,NoutputRed);
            Tout0=zeros(Nbus,NoutputRed);
            Tout2=zeros(Nbus,NoutputRed);
            k=1;
            for n=1:Nbus
                Vbase=LF.bus(n).vbase;
                Tout(n,k:k+2)=Tabc2pos/sqrt(2)*sqrt(3)/Vbase;
                Tout0(n,k:k+2)=Tabc2zero/sqrt(2)*sqrt(3)/Vbase;
                Tout2(n,k:k+2)=Tabc2neg/sqrt(2)*sqrt(3)/Vbase;
                k=k+3;
            end









            Tpos2abc=[1;a^2;a];
            Tzero2abc=[1;1;1];
            Tneg2abc=[1;a;a^2];
            Tin=zeros(NinputRed,Nbus);
            Tin0=zeros(NinputRed,Nbus);
            Tin2=zeros(NinputRed,Nbus);
            k=1;
            for n=1:Nbus
                Vbase=LF.bus(n).vbase;
                Tin(k:k+2,n)=Tpos2abc*Pbase/Vbase*sqrt(2)/sqrt(3);
                Tin0(k:k+2,n)=Tzero2abc*Pbase/Vbase*sqrt(2)/sqrt(3);
                Tin2(k:k+2,n)=Tneg2abc*Pbase/Vbase*sqrt(2)/sqrt(3);
                k=k+3;
            end

            Zbus=Tout*LF.H*Tin;
            Zbus0=Tout0*LF.H*Tin0;
            Zbus2=Tout2*LF.H*Tin2;
            Ybus=inv2(Zbus);
            Ybus0=inv2(Zbus0);
            Ybus2=inv2(Zbus2);







            for ib=1:Nbus
                Ybus(ib,ib)=Ybus(ib,ib)-1;
                Ybus0(ib,ib)=Ybus0(ib,ib)-1;
                Ybus2(ib,ib)=Ybus2(ib,ib)-1;
            end

            Ybus=(abs(Ybus)>1e-6).*Ybus;
            Ybus0=(abs(Ybus0)>1e-6).*Ybus0;
            Ybus2=(abs(Ybus2)>1e-6).*Ybus2;

            function out=inv2(in)

                if det(in)==0
                    out=ones(size(in))*inf;
                else
                    out=inv(in);
                end

                function Ybus=computeUnbalancedYbus(LF)
                    Nbus=size(LF.bus,2);
                    if Nbus==0
                        Ybus=[];
                        return
                    end
                    Vbase=[LF.bus.vbase];
                    Ibase=LF.Pbase./Vbase;

                    H=LF.H;





                    for i=1:Nbus
                        H(i,:)=H(i,:)./Vbase;
                    end
                    for i=1:Nbus
                        H(:,i)=H(:,i).*Ibase';
                    end

                    if rank(H)==Nbus
                        Ybus=inv(H);
                    else

                    end
                    Ybus=Ybus.*(abs(Ybus)>1e-10);






                    for ib=1:Nbus
                        Ybus(ib,ib)=Ybus(ib,ib)-1;
                    end
                    function LoadFlowSolver=determineLoadFlowSolver(sys)


                        BLOCKLIST=powersysdomain_netlist('SPSnetlist',sys);
                        if isempty(BLOCKLIST)

                            LoadFlowSolver='PositiveSequence';
                            return
                        end
                        idx=BLOCKLIST.filter_type('Load Flow Bus');
                        block=BLOCKLIST.elements(idx);
                        Phases=get_param(block,'Phases');
                        if all(strcmp(Phases,'single'))

                            LoadFlowSolver='PositiveSequence';
                            return
                        end
                        if all(strcmp(Phases,'single')==0)

                            LoadFlowSolver='Unbalanced';
                            return
                        else
                            LoadFlowSolver='Mixed';
                        end
                        function LF=computeBalancedLoadFlow(LF)




                            BusMonitor=[];
                            Pbase=LF.Pbase;
                            erPQ_max=LF.ErrMax;
                            niter_max=LF.Iterations;
                            LF.niter=0;
                            Ybus=LF.Ybus1;
                            Nbus=size(Ybus,1);
                            Vinit=ones(1,Nbus);
                            Vbase=zeros(1,Nbus);
                            for n=1:Nbus
                                Vbase(n)=LF.bus(n).vbase;
                            end

                            LF.error='';
                            Sbus=zeros(Nbus,1);
                            Qmin=-inf*ones(Nbus,1);
                            Qmax=inf*ones(1,Nbus);
                            BusType=3*ones(1,Nbus);
                            SpqloadGen=zeros(Nbus,1);
                            Sgen=zeros(Nbus,1);
                            Spqload=zeros(Nbus,1);
                            SpqGen=zeros(Nbus,1);

                            Nsm=length(LF.sm.busType);
                            for imac=1:Nsm
                                bus1=LF.sm.busNumber{imac};
                                if BusType(bus1)==1&&strcmp(LF.sm.busType{imac},'swing')
                                    LF.error=sprintf('--> Attempt to connect two ''swing'' synchronous machines or voltage sources at bus %s',LF.bus(bus1).ID);
                                    LF.error=char(LF.error,' ');
                                    LF.error=char(LF.error,' When connecting several synchronous machines or voltage sources on the same bus');
                                    LF.error=char(LF.error,' the following  combinations are allowed :');
                                    LF.error=char(LF.error,'     - one swing synchronous machine or ideal voltage source in parallel with one or several PQ generators');
                                    LF.error=char(LF.error,'     - one swing RX voltage source in parallel with one or several PV or PQ generators');
                                    LF.error=char(LF.error,'     - any mix of PV and PQ generators');
                                    LF.status=-1;
                                    return
                                end
                                if(BusType(bus1)==2&&strcmp(LF.sm.busType{imac},'swing'))||(BusType(bus1)==1&&strcmp(LF.sm.busType{imac},'PV'))
                                    LF.error=sprintf('--> Attempt to connect a ''swing'' synchronous machine at bus %s',LF.bus(bus1).ID);
                                    LF.error=char(LF.error,sprintf('    which is also specified as a ''PV'' generation bus.'));
                                    LF.error=char(LF.error,' ');
                                    LF.error=char(LF.error,' When connecting several synchronous machines or voltage sources on the same bus');
                                    LF.error=char(LF.error,' the following  combinations are allowed :');
                                    LF.error=char(LF.error,'     - one swing synchronous machine or ideal voltage source in parallel with one or several PQ generators');
                                    LF.error=char(LF.error,'     - one swing RX voltage source in parallel with one or several PV or PQ generators');
                                    LF.error=char(LF.error,'     - any mix of PV and PQ generators');

                                    LF.status=-1;
                                    return

                                end



                                IsFiniteQlimBus=isfinite(Qmin(bus1))|isfinite(Qmax(bus1));
                                IsFiniteQlim=isfinite(LF.sm.Qmin{imac})|isfinite(LF.sm.Qmax{imac});

                                if BusType(bus1)==2&&strcmp(LF.sm.busType{imac},'PV')&&(IsFiniteQlim||IsFiniteQlimBus)
                                    LF.error=sprintf('--> Attempt to connect a PV synchronous machine with finite Qmin or Qmax limits at bus %s where other PV sources are connected.\n',LF.bus(bus1).ID);
                                    LF.error=char(LF.error,'Only one PV generator with finite Q limits can be connected at a generation bus');

                                    LF.status=-1;
                                    return
                                end

                                switch LF.sm.busType{imac}

                                case 'swing'

                                    BusType(bus1)=1;
                                    Vinit(bus1)=LF.bus(bus1).vref*exp(1i*LF.bus(bus1).angle*pi/180);

                                case 'PV'

                                    BusType(bus1)=2;
                                    Vinit(bus1)=LF.bus(bus1).vref;
                                    Sbus(bus1)=Sbus(bus1)+LF.sm.P{imac}/Pbase;

                                    Qmin(bus1)=LF.sm.Qmin{imac}/Pbase;
                                    Qmax(bus1)=LF.sm.Qmax{imac}/Pbase;

                                case 'PQ'

                                    Sbus(bus1)=Sbus(bus1)+(LF.sm.P{imac}+1i*LF.sm.Q{imac})/Pbase;
                                    SpqGen(bus1)=SpqGen(bus1)+(LF.sm.P{imac}+1i*LF.sm.Q{imac})/Pbase;

                                    Qmin(bus1)=Qmin(bus1)+LF.sm.Qmin{imac}/Pbase;
                                    Qmax(bus1)=Qmin(bus1)+LF.sm.Qmax{imac}/Pbase;
                                end

                            end




                            Nvsrc=length(LF.vsrc.busType);

                            if Nvsrc>0
                                if~isfield(LF.vsrc,'InternalBus'),LF.vsrc.InternalBus{Nvsrc}=[];end
                            end

                            for imac=1:Nvsrc

                                Recom='When connecting several synchronous machines or voltage sources on the same bus the following  combinations are allowed :';
                                Recom=char(Recom,' ');
                                Recom=char(Recom,'- one swing synchronous machine or ideal voltage source in parallel with one or several PQ generators,');
                                Recom=char(Recom,'- one swing RX voltage source in parallel with one or several PV or PQ generators,');
                                Recom=char(Recom,'- any mix of PV and PQ generators.');

                                bus1=LF.vsrc.busNumber{imac};

                                if BusType(bus1)==1&&strcmp(LF.vsrc.busType{imac},'swing')
                                    LF.error=sprintf('--> Attempt to connect two swing synchronous machines or voltage sources at bus %s',LF.bus(bus1).ID);
                                    LF.error=char(LF.error,' ');
                                    LF.error=char(LF.error,Recom);
                                    LF.status=-1;
                                    return
                                end

                                if(BusType(bus1)==2&&strcmp(LF.vsrc.busType{imac},'swing')&&strcmp(LF.vsrc.blockType{imac},'Vprog'))
                                    LF.error=sprintf('--> Attempt to connect a ''swing'' type ideal voltage source at bus %s',LF.bus(bus1).ID);
                                    LF.error=char(LF.error,sprintf('    which is also specified as a PV generation bus.'));
                                    LF.error=char(LF.error,' ');
                                    LF.error=char(LF.error,Recom);
                                    LF.status=-1;
                                    return
                                end

                                if(BusType(bus1)==1&&strcmp(LF.vsrc.busType{imac},'PV'))
                                    imac_swing=find(cell2mat(LF.vsrc.busNumber)==bus1&strcmp('swing',LF.vsrc.busType)&strcmp('Vsrc',LF.vsrc.blockType),1);




                                    if isempty(imac_swing)
                                        LF.error=sprintf('--> Attempt to connect a ''PV'' type voltage source at bus %s',LF.bus(bus1).ID);
                                        LF.error=char(LF.error,sprintf('    which is also specified as a swing bus.'));
                                        LF.error=char(LF.error,' ');
                                        LF.error=char(LF.error,Recom);
                                        LF.status=-1;
                                        return
                                    end

                                end









                                if BusType(bus1)==2&&strcmp(LF.vsrc.busType{imac},'swing')&&isempty(LF.vsrc.InternalBus{imac})



                                    Nbus=Nbus+1;
                                    bus2=Nbus;

                                    z1=LF.vsrc.r{imac}+1i*LF.vsrc.x{imac};


                                    Ybus(bus1,bus2)=-1/z1;
                                    Ybus(bus2,bus1)=-1/z1;
                                    Ybus(bus1,bus1)=Ybus(bus1,bus1)+1/z1;
                                    Ybus(bus2,bus2)=1/z1;
                                    LF.Ybus1=Ybus;

                                    LF.VoltageRatio(bus1,bus2)=1;
                                    LF.VoltageRatio(bus2,bus1)=1;

                                    BusType(bus2)=1;
                                    Sbus(bus2,1)=0;
                                    SpqGen(bus2,1)=0;
                                    Sgen(bus2,1)=0;
                                    LF.bus(bus2).ID=[LF.bus(bus1).ID,'Internal'];
                                    LF.bus(bus2).vbase=LF.bus(bus1).vbase;
                                    LF.bus(bus2).vref=LF.bus(bus1).vref;
                                    LF.bus(bus2).angle=LF.bus(bus1).angle;
                                    Vinit(bus2)=LF.bus(bus1).vref*exp(1i*LF.bus(bus1).angle*pi/180);
                                    Qmin(bus2)=-inf;
                                    Qmax(bus2)=inf;
                                    LF.vsrc.InternalBus{imac}=bus2;

                                elseif BusType(bus1)==1&&strcmp(LF.vsrc.busType{imac},'PV')&&isempty(LF.vsrc.InternalBus{imac})



                                    BusType(bus1)=2;
                                    Nbus=Nbus+1;
                                    bus2=Nbus;

                                    imac_swing=find(cell2mat(LF.vsrc.busNumber)==bus1&strcmp('swing',LF.vsrc.busType));
                                    z1=LF.vsrc.r{imac_swing}+1i*LF.vsrc.x{imac_swing};


                                    Ybus(bus1,bus2)=-1/z1;
                                    Ybus(bus2,bus1)=-1/z1;
                                    Ybus(bus1,bus1)=Ybus(bus1,bus1)+1/z1;
                                    Ybus(bus2,bus2)=1/z1;
                                    LF.Ybus1=Ybus;

                                    LF.VoltageRatio(bus1,bus2)=1;
                                    LF.VoltageRatio(bus2,bus1)=1;

                                    BusType(bus2)=1;
                                    Sbus(bus2,1)=0;
                                    SpqGen(bus2,1)=0;
                                    Sgen(bus2,1)=0;
                                    LF.bus(bus2).ID=[LF.bus(bus1).ID,'Internal'];
                                    LF.bus(bus2).vbase=LF.bus(bus1).vbase;
                                    LF.bus(bus2).vref=LF.bus(bus1).vref;
                                    LF.bus(bus2).angle=LF.bus(bus1).angle;
                                    Vinit(bus2)=LF.bus(bus1).vref*exp(1i*LF.bus(bus1).angle*pi/180);
                                    Qmin(bus2)=-inf;
                                    Qmax(bus2)=inf;
                                    LF.vsrc.InternalBus{imac_swing}=bus2;

                                end



                                IsFiniteQlimBus=isfinite(Qmin(bus1))|isfinite(Qmax(bus1));
                                IsFiniteQlim=isfinite(LF.vsrc.Qmin{imac})|isfinite(LF.vsrc.Qmax{imac});

                                if BusType(bus1)==2&&strcmp(LF.vsrc.busType{imac},'PV')&&(IsFiniteQlim||IsFiniteQlimBus)
                                    LF.error=sprintf('--> Attempt to connect a PV voltage source with finite Qmin or Qmax limits at bus %s where other PV sources are connected.\n',LF.bus(bus1).ID);
                                    LF.error=char(LF.error,'Only one PV generator with finite Q limits can be connected at a generation bus.');

                                    LF.status=-1;
                                    return
                                end

                                if isempty(LF.vsrc.InternalBus{imac})

                                    switch LF.vsrc.busType{imac}

                                    case 'swing'

                                        BusType(bus1)=1;
                                        Vinit(bus1)=LF.bus(bus1).vref*exp(1i*LF.bus(bus1).angle*pi/180);

                                    case 'PV'

                                        BusType(bus1)=2;
                                        Vinit(bus1)=LF.bus(bus1).vref;
                                        Sbus(bus1)=Sbus(bus1)+LF.vsrc.P{imac}/Pbase;

                                        Qmin(bus1)=LF.vsrc.Qmin{imac}/Pbase;
                                        Qmax(bus1)=LF.vsrc.Qmax{imac}/Pbase;

                                    case{'PQ'}

                                        Sbus(bus1)=Sbus(bus1)+(LF.vsrc.P{imac}+1i*LF.vsrc.Q{imac})/Pbase;
                                        SpqGen(bus1)=SpqGen(bus1)+(LF.vsrc.P{imac}+1i*LF.vsrc.Q{imac})/Pbase;

                                        Qmin(bus1)=Qmin(bus1)+LF.vsrc.Q{imac}/Pbase;
                                        Qmax(bus1)=Qmax(bus1)+LF.vsrc.Q{imac}/Pbase;
                                    end

                                else



                                    BusType(LF.vsrc.InternalBus{imac})=1;
                                end

                            end



                            Npqload=length(LF.pqload.busType);

                            for imac=1:Npqload

                                bus1=LF.pqload.busNumber{imac};

                                if(BusType(bus1)==1||BusType(bus1)==2)&&strcmp(LF.pqload.busType{imac},'I')
                                    LF.error=sprintf('--> A constant current load cannot be connected at bus %d which is specified as a swing bus or PV generation bus',bus1);

                                    LF.status=-1;
                                    return
                                end

                                if(BusType(bus1)==3||BusType(bus1)==4)&&strcmp(LF.pqload.busType{imac},'I')

                                    BusType(bus1)=4;
                                end


                                if BusType(bus1)==2


                                    Sbus(bus1)=Sbus(bus1)-LF.pqload.P{imac}/Pbase;
                                    SpqloadGen(bus1)=SpqloadGen(bus1)+(LF.pqload.P{imac}+1i*LF.pqload.Q{imac})/Pbase;



                                    Qmin(bus1)=Qmin(bus1)-LF.pqload.Q{imac}/Pbase;
                                    Qmax(bus1)=Qmax(bus1)-LF.pqload.Q{imac}/Pbase;

                                else
                                    Sbus(bus1)=Sbus(bus1)-(LF.pqload.P{imac}+1i*LF.pqload.Q{imac})/Pbase;
                                end

                            end



                            Nrlcload=length(LF.rlcload.busType);

                            for imac=1:Nrlcload

                                bus1=LF.rlcload.busNumber{imac};

                                if~strcmp(LF.rlcload.busType{imac},'Z')

                                    if(BusType(bus1)==1||BusType(bus1)==2)&&strcmp(LF.rlcload.busType{imac},'I')
                                        LF.error=sprintf('--> A constant current load cannot be connected at bus %d which is specified as a swing bus or generation bus',bus1);

                                        LF.status=-1;
                                        return
                                    end

                                    if(BusType(bus1)==3||BusType(bus1)==4)&&strcmp(LF.rlcload.busType{imac},'I')

                                        BusType(bus1)=4;
                                    end


                                    if BusType(bus1)==2


                                        Sbus(bus1)=Sbus(bus1)-LF.rlcload.P{imac}/Pbase;
                                        SpqloadGen(bus1)=SpqloadGen(bus1)+(LF.rlcload.P{imac}+1i*LF.rlcload.Q{imac})/Pbase;



                                        Qmin(bus1)=Qmin(bus1)-LF.rlcload.Q{imac}/Pbase;
                                        Qmax(bus1)=Qmax(bus1)-LF.rlcload.Q{imac}/Pbase;


                                    else
                                        Sbus(bus1)=Sbus(bus1)-(LF.rlcload.P{imac}+1i*LF.rlcload.Q{imac})/Pbase;
                                    end

                                end

                            end







                            Nasm=length(LF.asm.busType);

                            for imac=1:Nasm

                                switch get_param(LF.asm.handle{imac},'RotorType')
                                case{'Wound','Double squirrel-cage'}


                                    S1='The Load Flow Tool does not yet support asynchronous machines with Rotor Type parameter set to ''Wound'' or ''Double-squirrel cage.''';

                                    S2=sprintf('If applicable, you can change the Rotor Type parameter of the following block to ''Squirrel-cage'' to perform the load flow:\n\n%s',getfullname(LF.asm.handle{imac}));

                                    LF.error=sprintf('%s\n\n%s',S1,S2);

                                    LF.status=-1;
                                    return
                                end
                                bus1=LF.asm.busNumber{imac};
                                busm=Nbus+imac;
                                bus2=Nbus+Nasm+imac;


                                z1=(LF.asm.r1{imac}+1i*LF.asm.x1{imac})*Pbase/LF.asm.pnom{imac}*(LF.asm.vnom{imac}/Vbase(bus1))^2;
                                z2=(LF.asm.r2{imac}+1i*LF.asm.x2{imac})*Pbase/LF.asm.pnom{imac}*(LF.asm.vnom{imac}/Vbase(bus1))^2;
                                zm=1i*LF.asm.xm{imac}*Pbase/LF.asm.pnom{imac}*(LF.asm.vnom{imac}/Vbase(bus1))^2;






                                Ybus(bus1,busm)=-1/z1;
                                Ybus(busm,bus1)=-1/z1;
                                Ybus(busm,bus2)=-1/z2;
                                Ybus(bus2,busm)=-1/z2;


                                Ybus(bus1,bus1)=Ybus(bus1,bus1)+1/z1;
                                Ybus(busm,busm)=1/z1+1/z2+1/zm;
                                Ybus(bus2,bus2)=1/z2;

                                BusType(busm)=3;
                                BusType(bus2)=3;
                                Sbus(busm)=0;
                                Sbus(bus2)=-LF.asm.P{imac}/Pbase;
                                Vinit(busm)=Vinit(bus1);
                                Vinit(bus2)=Vinit(bus1);
                                Qmin(busm)=-inf;
                                Qmin(bus2)=-inf;
                                Qmax(busm)=inf;
                                Qmax(bus2)=inf;
                                LF.asm.InternalBuses{imac}=[busm,bus2];

                            end

                            Nbus=size(Ybus,1);



                            for ibus=1:Nbus
                                LF.bus(ibus).TypeNumber=BusType(ibus);
                            end

                            LF.Ybus1asm=Ybus;

                            for ibus=1:Nbus
                                LF.bus(ibus).Sref=Sbus(ibus);
                                LF.bus(ibus).Qmin=Qmin(ibus);
                                LF.bus(ibus).Qmax=Qmax(ibus);
                            end


                            [LF,niter,ErrorMessage]=balancedNewtonRaphson(LF,BusMonitor,erPQ_max,niter_max);



                            if~isempty(ErrorMessage)
                                LF.error=ErrorMessage;
                                LF.status=-1;
                                return
                            end

                            Sbus_net=zeros(Nbus,1);
                            V=zeros(Nbus,1);

                            for ibus=1:Nbus
                                Sbus_net(ibus)=LF.bus(ibus).Sbus;
                                V(ibus)=LF.bus(ibus).Vbus;
                            end

                            if niter<niter_max

                                ibSwing=find(BusType==1);
                                ibGen=find(BusType==2);
                                ibLoad=find(BusType==3);















                                n=ibLoad<=(Nbus-2*Nasm);
                                ibLoad1=ibLoad(n);




                                if isempty(ibGen)
                                    ibGen=[];
                                end
                                if isempty(ibLoad1)
                                    ibLoad1=[];
                                end


                                Sgen(ibGen)=Sbus_net(ibGen)+SpqloadGen(ibGen);
                                Sgen(ibLoad1)=Sgen(ibLoad1)+SpqGen(ibLoad1);
                                Sgen(ibSwing)=Sbus_net(ibSwing)-Sbus(ibSwing)+SpqGen(ibSwing);


                                Spqload(ibLoad1)=-Sbus_net(ibLoad1)+SpqGen(ibLoad1);
                                Spqload(ibGen)=SpqloadGen(ibGen);
                                Spqload(ibSwing)=-Sbus(ibSwing)+SpqGen(ibSwing);

                                for ib=1:Nbus-2*Nasm

                                    LF.bus(ib).Sgen=Sgen(ib);
                                    LF.bus(ib).Spqload=Spqload(ib);

                                    Yshunt=sum(abs(Ybus(ib,:)).*exp(1i*angle(Ybus(ib,:)+Ybus(:,ib).')));

                                    LF.bus(ib).Sshunt=abs(V(ib))^2*conj(Yshunt);

                                    if any(LF.ibGenQmin==ib)
                                        LF.bus(ib).QminReached=1;
                                    else
                                        LF.bus(ib).QminReached=0;
                                    end

                                    if any(LF.ibGenQmax==ib)
                                        LF.bus(ib).QmaxReached=1;
                                    else
                                        LF.bus(ib).QmaxReached=0;
                                    end

                                end



                                for imac=1:Nsm

                                    bus1=LF.sm.busNumber{imac};
                                    Rs=LF.sm.rs{imac};
                                    Xd=LF.sm.xd{imac};
                                    Xq=LF.sm.xq{imac};

                                    switch LF.sm.busType{imac}

                                    case 'swing'

                                        Sgenerator=Sgen(bus1)-SpqGen(bus1);
                                        LF.sm.prefpu{imac}=real(Sgen(bus1))*Pbase./LF.sm.pnom{imac};

                                    case 'PV'

                                        if abs(real(Sgen(bus1)-SpqGen(bus1))-LF.sm.P{imac})<=erPQ_max




                                            Sgenerator=Sgen(bus1)-SpqGen(bus1);
                                        else




                                            Sgenerator=LF.sm.P{imac}/Pbase+...
                                            1i*imag(Sgen(bus1)-SpqGen(bus1))*LF.sm.P{imac}/(real(Sgen(bus1)-SpqGen(bus1))*Pbase);
                                        end

                                        LF.sm.prefpu{imac}=LF.sm.P{imac}/LF.sm.pnom{imac};

                                    case 'PQ'


                                        Sgenerator=(LF.sm.P{imac}+1i*LF.sm.Q{imac})/Pbase;
                                        LF.sm.prefpu{imac}=LF.sm.P{imac}/LF.sm.pnom{imac};

                                    end

                                    Imac=conj(Sgenerator*Pbase/LF.sm.pnom{imac}/(V(bus1)*Vbase(bus1)/LF.sm.vnom{imac}));
                                    LF.sm.I{imac}=Imac;
                                    LF.sm.S{imac}=V(bus1)*Vbase(bus1)/LF.sm.vnom{imac}*conj(LF.sm.I{imac});
                                    LF.sm.pmec{imac}=(real(LF.sm.S{imac})+Rs*(abs(Imac))^2)*LF.sm.pnom{imac};
                                    LF.sm.S{imac}=LF.sm.S{imac}*LF.sm.pnom{imac}/Pbase;

                                    Ef1=V(bus1)*Vbase(bus1)/LF.sm.vnom{imac}+Imac*Rs+1i*Imac*Xq;


                                    Id=abs(abs(Imac))*sin(angle(Ef1)-angle(Imac))*exp(1i*(angle(Ef1)-pi/2));
                                    Iq=abs(abs(Imac))*cos(angle(Ef1)-angle(Imac))*exp(1i*(angle(Ef1)));


                                    Ean=V(bus1)*Vbase(bus1)/LF.sm.vnom{imac}+Rs*Imac+1i*Id*Xd+1i*Iq*Xq;
                                    LF.sm.Vf{imac}=abs(Ean);
                                    LF.sm.Vt{imac}=V(bus1)*Vbase(bus1)/LF.sm.vnom{imac};


                                    LF.sm.th0deg{imac}=angle(Ean)*180/pi-90;

                                end



                                for imac=1:Nvsrc

                                    bus1=LF.vsrc.busNumber{imac};
                                    z=(LF.vsrc.r{imac}+1i*LF.vsrc.x{imac});

                                    if isempty(LF.vsrc.InternalBus{imac})

                                        switch LF.vsrc.busType{imac}

                                        case 'swing'
                                            Sgenerator=Sgen(bus1)-SpqGen(bus1);

                                        case 'PV'

                                            if abs(real(Sgen(bus1)-SpqGen(bus1))-LF.vsrc.P{imac})<=erPQ_max




                                                Sgenerator=Sgen(bus1)-SpqGen(bus1);
                                            else




                                                Sgenerator=LF.vsrc.P{imac}/Pbase+...
                                                1i*imag(Sgen(bus1)-SpqGen(bus1))*LF.vsrc.P{imac}/(real(Sgen(bus1)-SpqGen(bus1))*Pbase);
                                            end

                                        case 'PQ'


                                            Sgenerator=(LF.vsrc.P{imac}+1i*LF.vsrc.Q{imac})/Pbase;
                                        end

                                        I=conj(Sgenerator/V(bus1));

                                    else

                                        I=(V(LF.vsrc.InternalBus{imac})-V(bus1))/z;
                                    end

                                    LF.vsrc.I{imac}=I;
                                    LF.vsrc.S{imac}=V(bus1)*conj(I);
                                    LF.vsrc.Vt{imac}=V(bus1);
                                    LF.vsrc.Vint{imac}=LF.vsrc.Vt{imac}+z*I;

                                end



                                Nbus=Nbus-2*Nasm;

                                for imac=1:Nasm

                                    bus1=LF.asm.busNumber{imac};
                                    busm=Nbus+imac;
                                    bus2=Nbus+Nasm+imac;
                                    z1=LF.asm.r1{imac}+1i*LF.asm.x1{imac};
                                    LF.asm.I{imac}=(V(bus1)-V(busm))*Vbase(bus1)/LF.asm.vnom{imac}/z1;
                                    LF.asm.S{imac}=V(bus1)*Vbase(bus1)/LF.asm.vnom{imac}*conj(LF.asm.I{imac});
                                    LF.asm.S{imac}=LF.asm.S{imac}*LF.asm.pnom{imac}/Pbase;




                                    LF.asm.slip{imac}=1/(1+(abs(V(bus2)*Vbase(bus1)/LF.asm.vnom{imac})^2)/(LF.asm.P{imac}/LF.asm.pnom{imac})/LF.asm.r2{imac});
                                    LF.asm.T{imac}=(LF.asm.P{imac}/LF.asm.pnom{imac})/(1-LF.asm.slip{imac});
                                    LF.asm.Vt{imac}=V(bus1);

                                end



                                for imac=1:Npqload

                                    bus1=LF.pqload.busNumber{imac};
                                    I=conj((LF.pqload.P{imac}+1i*LF.pqload.Q{imac})/Pbase/V(bus1));
                                    LF.pqload.Vt{imac}=V(bus1);
                                    LF.pqload.I{imac}=I;
                                    LF.pqload.S{imac}=V(bus1)*conj(I);

                                end



                                for imac=1:Nrlcload

                                    if~strcmp(LF.rlcload.busType{imac},'Z')

                                        bus1=LF.rlcload.busNumber{imac};
                                        I=conj((LF.rlcload.P{imac}+1i*LF.rlcload.Q{imac})/Pbase/V(bus1));
                                        LF.rlcload.Vt{imac}=V(bus1);
                                        LF.rlcload.I{imac}=I;
                                        LF.rlcload.S{imac}=V(bus1)*conj(I);

                                    end

                                end

                            else
                                LF.error=sprintf('The load flow did not converge in %d iterations',niter_max);
                                LF.status=-1;
                                return
                            end



                            for i=1:length(LF.rlcload.handle)

                                switch LF.rlcload.busType{i}

                                case 'Z'







                                    LF.rlcload.Vt{i}=LF.bus(LF.rlcload.busNumber{i}).Vbus;
                                    LF.rlcload.S{i}=(LF.rlcload.P{i}+1i*LF.rlcload.Q{i})/Pbase*...
                                    (abs(LF.rlcload.Vt{i})*...
                                    LF.bus(LF.rlcload.busNumber{i}).vbase/LF.rlcload.vnom{i})^2;
                                end

                            end

                            LF.niter=niter;
                            LF.status=1;
                            function[LF,niter,ErrorMessage]=balancedNewtonRaphson(LF,BusMonitor,erPQ_max,niter_max)







































































































































































































                                [node_numbers,subnet_numbers,nb_subnetworks]=getBalancedSubnetworks(LF);






                                LF.NbOfNetworks=nb_subnetworks;


                                for ires=1:nb_subnetworks

                                    n=subnet_numbers==ires&node_numbers<10000;

                                    node_res=node_numbers(n);
                                    LF.Networks(ires).busNumber=sort(node_res);

                                    SwingBus=[];
                                    for ibus=node_res
                                        if LF.bus(ibus).TypeNumber==1
                                            SwingBus=[SwingBus,ibus];%#ok
                                        end
                                    end

                                    LF.Networks(ires).SwingBus=SwingBus;

                                    if isempty(SwingBus)
                                        for ibus=node_res
                                            LF.bus(ibus).IsInSubnetWithSwingBus=0;
                                        end
                                    else
                                        for ibus=node_res
                                            LF.bus(ibus).IsInSubnetWithSwingBus=1;
                                        end
                                    end

                                end



                                nbus_select=[];
                                Nbus1=size(LF.Ybus1asm,1);

                                for ibus=1:Nbus1
                                    if LF.bus(ibus).IsInSubnetWithSwingBus
                                        nbus_select=[nbus_select,ibus];%#ok % list of retained bus numbers
                                    end
                                end



                                Sbus=zeros(Nbus1,1);
                                Vinit=zeros(Nbus1,1);
                                Qmin=zeros(Nbus1,1);
                                Qmax=zeros(Nbus1,1);

                                BusType=zeros(1,Nbus1);

                                for ibus=1:Nbus1

                                    if isempty(LF.bus(ibus).vref)
                                        Vinit(ibus)=0;
                                    else
                                        Vinit(ibus)=LF.bus(ibus).vref*exp(1i*LF.bus(ibus).angle*pi/180);
                                    end
                                    Sbus(ibus)=LF.bus(ibus).Sref;
                                    Qmin(ibus)=LF.bus(ibus).Qmin;
                                    Qmax(ibus)=LF.bus(ibus).Qmax;
                                    BusType(ibus)=LF.bus(ibus).TypeNumber;

                                end

                                BusIDstr=char(LF.bus.ID);



                                Vinit=Vinit(nbus_select);
                                Sbus=Sbus(nbus_select);
                                Qmin=Qmin(nbus_select);
                                Qmax=Qmax(nbus_select);
                                BusType=BusType(nbus_select);
                                BusIDstr=BusIDstr(nbus_select,:);

                                Ybus=LF.Ybus1asm(nbus_select,nbus_select);
                                Nbus=size(Ybus,1);




                                V=Vinit;
                                Sg=zeros(Nbus,1);
                                ibGenQmin=[];
                                ibGenQmax=[];
                                niter=0;
                                ErrorMessage='';

                                ibSwing=find(BusType==1);

                                if isempty(ibSwing)
                                    ErrorMessage=sprintf('--> The model contains no swing bus.');
                                    ErrorMessage=char(ErrorMessage,sprintf('At least one bus must be specified as ''swing'' bus type.'));
                                    return
                                end

                                ibGen=find(BusType==2);
                                ibLoad=find(BusType==3|BusType==4);
                                ibGenLoad=find(BusType~=1);
                                ibIconst=find(BusType==4);





                                TitleBusMonitor=[];
                                FormatBusMonitor=[];
                                val=[];

                                JacP=zeros(Nbus,2*Nbus);
                                JacQ=zeros(Nbus,2*Nbus);


                                DangVmagV=zeros(2*Nbus,1);
                                index=1:Nbus;
                                Y=Ybus;
                                k_VcorIconst=ones(Nbus,1);









                                Ybus_Zconst=Ybus;

                                for ib=1:Nbus

                                    if BusType(ib)==1


                                        Ybus_Zconst(ib,ib)=Ybus_Zconst(ib,ib)+1000;
                                    else




                                        Ybus_Zconst(ib,ib)=Ybus_Zconst(ib,ib)-conj(Sbus(ib));

                                    end

                                end

                                I=zeros(Nbus,1);
                                I(ibSwing)=V(ibSwing)*1000;

                                Vinit2=Ybus_Zconst\I;


                                V(ibGen)=abs(V(ibGen)).*exp(1i*angle(Vinit2(ibGen)));

                                V(ibLoad)=Vinit2(ibLoad);












                                if~isempty(ibLoad)
                                    BusIDload=char(LF.bus(ibLoad).ID);
                                    if~isempty(BusIDload)
                                        n=find(BusIDload(:,1)~='*');
                                    else

                                        n=1:size(BusIDload,1);
                                    end
                                    ibLoad1=ibLoad(n);


                                    if any(abs(Vinit2(ibLoad1))<0.7|abs(Vinit2(ibLoad1))>1.3)
                                        V(ibLoad1)=1.0*exp(1i*angle(Vinit2(ibLoad1)));
                                    else
                                        V(ibLoad1)=abs(Vinit2(ibLoad1)).*exp(1i*angle(Vinit2(ibLoad1)));
                                    end
                                end

                                Vmag=abs(V)';Vang=angle(V)';
                                Ymag=abs(Y);Yang=angle(Y);



                                P=zeros(Nbus,1);Q=zeros(Nbus,1);


                                for ib=1:Nbus


                                    Sg(ib)=V(ib)*sum(conj(V.*conj(Ybus(ib,:)')));

                                    if BusType(ib)==3
                                        P(ib)=real(Sg(ib)-Sbus(ib));
                                        Q(ib)=imag(Sg(ib)-Sbus(ib));

                                    elseif BusType(ib)==2
                                        P(ib)=real(Sg(ib)-Sbus(ib));

                                    elseif BusType(ib)==4
                                        P(ib)=real(Sg(ib)-Sbus(ib))/Vmag(ib);
                                        Q(ib)=imag(Sg(ib)-Sbus(ib))/Vmag(ib);
                                    end

                                end

                                PQ=[P;Q];



                                if~isempty(BusMonitor)

                                    val=niter;
                                    TitleBusMonitor='#- ';
                                    TitleBusMonito2='   ';
                                    FormatBusMonitor='%2d';

                                    for i=1:length(BusMonitor)

                                        ib=strcmp(BusMonitor{i},BusIDstr);

                                        if isempty(ib)
                                            ErrorMessage=sprintf('-->Monitored bus %s = does not correspond to an existing bus identification ',BusMonitor{i});
                                            return
                                        end

                                        str=sprintf('------V%s------ ------S%s----- ',BusMonitor{i},BusMonitor{i});
                                        TitleBusMonitor=[TitleBusMonitor,str];%#ok
                                        TitleBusMonito2=[TitleBusMonito2,'(pu)   (deg)   P(pu)  Q(pu)  '];%#ok
                                        FormatBusMonitor=[FormatBusMonitor,'%6.3f %7.2f %6.3f %6.3f '];%#ok
                                        val=[val,abs(V(ib)),angle(V(ib))*180/pi,real(Sg(ib)),imag(Sg(ib))];%#ok

                                    end

                                end

                                k_VcorIconst(ibIconst)=Vmag(ibIconst);
                                erP=abs((real(Sg(ibGenLoad)-Sbus(ibGenLoad).*k_VcorIconst(ibGenLoad))));
                                [erPmax,i]=max(erP);
                                iberPmax=ibGenLoad(i);

                                if isempty(ibGenLoad)
                                    erPmax=0;iberPmax=0;
                                end

                                erQ=abs((imag(Sg(ibLoad)-Sbus(ibLoad).*k_VcorIconst(ibLoad))));
                                [erQmax,i]=max(erQ);
                                iberQmax=ibLoad(i);

                                if isempty(ibLoad)
                                    erQmax=0;
                                    iberQmax=0;
                                end

                                if~isempty(BusMonitor)

                                    val=[val,erPmax,iberPmax,erQmax,iberQmax,];
                                    TitleBusMonitor=[TitleBusMonitor,' --DPmax-- --DQmax--\n'];
                                    TitleBusMonito2=[TitleBusMonito2,' (pu)   #  (pu)   #'];
                                    FormatBusMonitor=[FormatBusMonitor,' %6.3f %2d %6.3f %2d\n'];

                                    fprintf(TitleBusMonitor);
                                    fprintf('%s\n',TitleBusMonito2);
                                    fprintf(FormatBusMonitor,val);

                                end



                                for solution=1:2


                                    if solution==1


                                        ibGenQmin=[];
                                        ibGenQmax=[];
                                        indexGenLoad=[ibGenLoad,ibLoad+Nbus];
                                        ibGenQlimLoad=ibLoad;

                                    else






                                        ibGenQmin=find(BusType==2&(imag(Sg)<Qmin)');
                                        ibGenQmax=find(BusType==2&(imag(Sg)>Qmax)');
                                        ibGenQlimLoad=[ibLoad,ibGenQmin,ibGenQmax];
                                        Sbus(ibGenQmin)=real(Sbus(ibGenQmin))+1i*Qmin(ibGenQmin);
                                        Sbus(ibGenQmax)=real(Sbus(ibGenQmax))+1i*Qmax(ibGenQmax);

                                        indexGenLoad=[ibGenLoad,ibGenQlimLoad+Nbus];
                                        ibGenQlimLoad=[ibLoad,ibGenQmin,ibGenQmax];

                                        if isempty(ibGenQmin)&&isempty(ibGenQmax)
                                            break
                                        elseif~isempty(BusMonitor)
                                            fprintf('End of 1st series of iterations without Q limits (%d iterations)\n',niter)
                                        end

                                    end

                                    while(erPmax>erPQ_max||erQmax>erPQ_max)&&niter<niter_max

                                        niter=niter+1;




















                                        for ib=1:Nbus

                                            n=index~=ib;
                                            ind=index(n);

                                            if BusType(ib)==4



                                                JacP(ib,ib)=-sum(Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                JacP(ib,ind)=Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                JacP(ib,ib+Nbus)=Ymag(ib,ib)*cos(Yang(ib,ib));

                                                JacP(ib,ind+Nbus)=Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                            else



                                                JacP(ib,ib)=-Vmag(ib)*sum(Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                JacP(ib,ind)=Vmag(ib)*Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                JacP(ib,ib+Nbus)=2*Vmag(ib)*Ymag(ib,ib)*cos(Yang(ib,ib))+...
                                                sum(Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                JacP(ib,ind+Nbus)=Vmag(ib)*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                            end

                                        end


                                        for ib=1:Nbus

                                            n=index~=ib;
                                            ind=index(n);

                                            if BusType==4



                                                JacQ(ib,ib)=sum(Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                JacQ(ib,ind)=-Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                JacQ(ib,ib+Nbus)=-Ymag(ib,ib).*sin(Yang(ib,ib));

                                                JacQ(ib,ind+Nbus)=Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                            else



                                                JacQ(ib,ib)=Vmag(ib)*sum(Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                JacQ(ib,ind)=-Vmag(ib)*Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                JacQ(ib,ib+Nbus)=-2*Vmag(ib)*Ymag(ib,ib).*sin(Yang(ib,ib))+...
                                                sum(Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                JacQ(ib,ind+Nbus)=Vmag(ib)*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                            end

                                        end

                                        Jac=[JacP;JacQ];









                                        DangVmagV(indexGenLoad)=-Jac(indexGenLoad,indexGenLoad)\PQ(indexGenLoad);
                                        DangV=DangVmagV(1:Nbus);
                                        DmagV=DangVmagV(Nbus+1:2*Nbus);

                                        Vang=Vang+DangV';
                                        Vmag=Vmag+DmagV';
                                        V=Vmag'.*exp(1i*Vang');



                                        for ib=1:Nbus
                                            Sg(ib)=V(ib)*sum(conj(V.*conj(Ybus(ib,:)')));
                                        end



                                        P(ibGenLoad)=real(Sg(ibGenLoad)-Sbus(ibGenLoad));
                                        Q(ibGenQlimLoad)=imag(Sg(ibGenQlimLoad)-Sbus(ibGenQlimLoad));

                                        P(ibIconst)=real(Sg(ibIconst)-Sbus(ibIconst).*Vmag(ibIconst)');
                                        Q(ibIconst)=imag(Sg(ibIconst)-Sbus(ibIconst).*Vmag(ibIconst)');

                                        PQ=[P;Q];



                                        val=niter;

                                        for i=1:length(BusMonitor)
                                            ib=strcmp(BusMonitor(i),BusIDstr);
                                            val=[val,abs(V(ib)),angle(V(ib))*180/pi,real(Sg(ib)),imag(Sg(ib))];%#ok
                                        end

                                        k_VcorIconst(ibIconst)=Vmag(ibIconst);

                                        erP=abs((real(Sg(ibGenLoad)-Sbus(ibGenLoad).*k_VcorIconst(ibGenLoad))));
                                        [erPmax,i]=max(erP);
                                        iberPmax=ibGenLoad(i);


                                        if~isempty(ibGenQlimLoad)


                                            erQ=abs((imag(Sg(ibGenQlimLoad)-Sbus(ibGenQlimLoad).*k_VcorIconst(ibGenQlimLoad))));
                                            [erQmax,i]=max(erQ);

                                            iberQmax=ibGenQlimLoad(i);

                                        else

                                            erQmax=0;
                                            iberQmax=0;

                                        end

                                        if~isempty(BusMonitor)
                                            val=[val,erPmax,iberPmax,erQmax,iberQmax];%#ok
                                            fprintf(FormatBusMonitor,val);
                                        end

                                    end


                                    if solution==1
                                        erPmax=inf;
                                    end

                                end





                                Vbus=zeros(Nbus1,1);
                                Vbus(nbus_select)=V;
                                Sbus=zeros(Nbus1,1);
                                Sbus(nbus_select)=Sg;
                                ibGenQmin=nbus_select(ibGenQmin);
                                ibGenQmax=nbus_select(ibGenQmax);

                                for ibus=1:Nbus1
                                    LF.bus(ibus).Vbus=Vbus(ibus);
                                    LF.bus(ibus).Sbus=Sbus(ibus);
                                end

                                LF.ibGenQmin=ibGenQmin;
                                LF.ibGenQmax=ibGenQmax;
                                function[node_numbers,subnet_numbers,nb_subnetworks]=getBalancedSubnetworks(LF)















                                    Ybus=(LF.Ybus1asm);
                                    Nbus=size(Ybus,1);




                                    node_mat=zeros(0,2);
                                    nbranch=0;

                                    for node1=1:Nbus

                                        nbranch=nbranch+1;


                                        node_mat(nbranch,:)=[node1,node1+10000];

                                        for node2=node1+1:Nbus

                                            if Ybus(node1,node2)~=0

                                                nbranch=nbranch+1;
                                                node_mat(nbranch,:)=[node1,node2];
                                            end

                                        end

                                    end







                                    if isempty(node_mat)
                                        return
                                    end

                                    node_mat=node_mat(:,1:2);

                                    node_numbers=-123456;
                                    subnet_numbers=[];
                                    indres=1;

                                    for i=1:size(node_mat,1)

                                        if isempty(find(node_mat(i,1)==node_numbers,1))&&isempty(find(node_mat(i,2)==node_numbers,1))

                                            if i==1
                                                node_numbers=[];
                                            end

                                            ww=node_mat(i,:);
                                            wwold=[];

                                            while length(ww)>length(wwold)

                                                wwold=ww;

                                                for j=1:size(node_mat,1)


                                                    if~isempty(find(ww==node_mat(j,1),1))

                                                        if isempty(find(ww==node_mat(j,2),1))

                                                            ww=[ww,node_mat(j,2)];%#ok
                                                        end
                                                    end


                                                    if~isempty(find(ww==node_mat(j,2),1))

                                                        if isempty(find(ww==node_mat(j,1),1))

                                                            ww=[ww,node_mat(j,1)];%#ok
                                                        end
                                                    end

                                                end

                                            end

                                            node_numbers=[node_numbers,ww];%#ok
                                            subnet_numbers=[subnet_numbers,indres*ones(1,length(ww))];%#ok
                                            indres=indres+1;


                                        end

                                    end

                                    nb_subnetworks=indres-1;
                                    function LF=computeUnbalancedLoadFlow(LF)









                                        BusMonitor=[];
                                        Pbase=LF.Pbase;
                                        erPQ_max=LF.ErrMax;
                                        niter_max=LF.Iterations;

                                        LF.niter=0;

                                        Ybus=LF.Ybus;
                                        Nbus=size(Ybus,1);
                                        Vinit=ones(1,Nbus);

                                        Vbase=zeros(1,Nbus);

                                        for n=1:Nbus
                                            Vbase(n)=LF.bus(n).vbase;
                                        end


                                        a=exp(1i*2*pi/3);
                                        a2=a*a;

                                        LF.error='';


                                        Sbus=zeros(Nbus,1);
                                        SbusPP=zeros(Nbus,1);
                                        SbusPN=zeros(Nbus,1);
                                        SbusSM=zeros(Nbus,1);
                                        SbusDYN=zeros(Nbus,1);
                                        SbusASM=zeros(Nbus,1);


                                        Qmin=-inf*ones(Nbus,1);
                                        Qmax=inf*ones(Nbus,1);
                                        BusType=3*ones(1,Nbus);
                                        SpqloadGen=zeros(Nbus,1);
                                        SpqloadGenPP=zeros(Nbus,1);
                                        SpqloadGenPN=zeros(Nbus,1);
                                        Sgen=zeros(Nbus,1);
                                        Spqload=zeros(Nbus,1);
                                        SpqGen=zeros(Nbus,1);
                                        SpqGenPP=zeros(Nbus,1);
                                        SpqGenPN=zeros(Nbus,1);



                                        for i=1:Nbus
                                            LF.bus(i).TypeNumberPP=0;
                                            LF.bus(i).TypeNumberPN=0;
                                            LF.bus(i).Vng=0;
                                        end



                                        Nsm=length([LF.sm.handle]);

                                        for imac=1:Nsm

                                            BlockName=get(LF.sm.handle{imac},'Name');
                                            BlockName=strrep(BlockName,newline,char(32));

                                            if any(isnan(LF.sm.busNumber{imac}))||all(LF.sm.busNumber{imac}==0)
                                                LF.error=sprintf('--> The ''%s'' type synchronous machine block ''%s'' must be connected to a Load Flow Bus block',LF.sm.busType{imac},BlockName);

                                                LF.status=-1;
                                                return
                                            end

                                            bus1=LF.sm.busNumber{imac};


















                                            if strcmp(LF.sm.busType{imac},'swing')

                                                LF.error=sprintf('--> ''%s'' Generator Type is specified for synchronous machine %s connected at bus %s',LF.sm.busType{imac},BlockName,LF.bus(bus1(1)).ID(1:end-2));
                                                LF.error=char(LF.error,' ');
                                                LF.error=char(LF.error,' As the three-phase synchronous machine can control positive-sequence voltage only');
                                                LF.error=char(LF.error,' ''swing'' Generator Type is not allowed for this block during unbalanced Load Flow solution.');
                                                LF.error=char(LF.error,' Please change the Generator Type to ''PV'' or ''PQ''.');
                                                LF.error=char(LF.error,' If you need controlling individual phase voltages, you may use instead');
                                                LF.error=char(LF.error,' the Three-Phase Source block with ''PV'' or ''swing'' Generator Type.');

                                                LF.status=-1;
                                                return

                                            end
















































                                            if any(BusType(bus1)==2)&&strcmp(LF.sm.busType{imac},'PV')
                                                LF.error=sprintf('--> Attempt to connect a PV synchronous machine at bus %s where other PV sources are connected.\n',LF.bus(bus1).ID);
                                                LF.error=char(LF.error,'Only one PV generator can be connected at a generation bus');

                                                LF.status=-1;
                                                return
                                            end









                                            switch LF.sm.busType{imac}

                                            case 'swing'

                                                BusType(bus1)=1;


                                                Vinit(bus1)=[LF.bus(bus1).vref].*exp(1i*[LF.bus(bus1).angle]*pi/180);


                                            case 'PV'

                                                BusType(bus1)=2;
                                                Vinit(bus1)=LF.bus(bus1).vref;

                                                SbusSM(bus1(1))=SbusSM(bus1(1))+LF.sm.P{imac}/Pbase;

                                                Qmin(bus1)=LF.sm.Qmin{imac}/Pbase;
                                                Qmax(bus1)=LF.sm.Qmax{imac}/Pbase;

                                            case 'PQ'

                                                SbusSM(bus1(1))=SbusSM(bus1(1))+(LF.sm.P{imac}+1i*LF.sm.Q{imac})/Pbase;


                                                Qmin(bus1)=Qmin(bus1)+LF.sm.Qmin{imac}/Pbase;
                                                Qmax(bus1)=Qmin(bus1)+LF.sm.Qmax{imac}/Pbase;
                                            end

                                        end



                                        NvsrcBlocks=length([LF.vsrc.handle]);

                                        Nvsrc=0;
                                        for iBlock=1:NvsrcBlocks
                                            BlockName=get(LF.vsrc.handle{iBlock},'Name');
                                            BlockName=strrep(BlockName,newline,char(32));

                                            if any(isnan(LF.vsrc.busNumber{iBlock}))||all(LF.vsrc.busNumber{iBlock}==0)
                                                LF.error=sprintf('--> The ''%s'' type source block ''%s'' must be connected to a Load Flow Bus block',LF.vsrc.busType{iBlock},BlockName);
                                                LF.status=-1;
                                                return
                                            end

                                            Nphases=length(LF.vsrc.busNumber{iBlock});
                                            if Nphases==2&&strcmp(LF.vsrc.blockType{iBlock},'Vsrc 1ph')
                                                Nphases=1;
                                            end

                                            for iphase=1:Nphases
                                                Nvsrc=Nvsrc+1;
                                                switch char(LF.vsrc.connection{iBlock})
                                                case 'Yg'
                                                    connection3ph={'ag','bg','cg'};
                                                    connection=connection3ph{iphase};
                                                case{'Y','Yn'}
                                                    connection3ph={'an','bn','cn'};
                                                    connection=connection3ph{iphase};
                                                otherwise
                                                    if Nphases==1
                                                        connection=LF.vsrc.connection{iBlock};
                                                    else
                                                        error(message('physmod:powersys:library:UnbalancedLFInvalidVSrcConnection',char(LF.vsrc.connection{iBlock}),BlockName));
                                                    end
                                                end


                                                switch char(connection)
                                                case{'ag','bg','cg'}

                                                case{'ab','bc','ca','an','bn','cn'}

                                                    if~strcmp(char(LF.vsrc.busType{iBlock}),'PQ')
                                                        LF.error=sprintf('--> Voltage source block %s (''%s'' connection, ''%s'' type)',...
                                                        BlockName,char(connection),char(LF.vsrc.busType{iBlock}));
                                                        LF.error=[LF.error,sprintf('\n Only ''PQ'' type  is allowed for phase-phase and phase_neutral sources )')];
                                                        LF.status=-1;
                                                        return
                                                    end
                                                end

                                                Recom='When connecting several synchronous machines or voltage sources on the same bus the following  combinations are allowed :';
                                                Recom=char(Recom,' ');
                                                Recom=char(Recom,'- one swing synchronous machine or ideal voltage source in parallel with one or several PQ generators,');
                                                Recom=char(Recom,'- one swing RX voltage source in parallel with one or several PV or PQ generators,');
                                                Recom=char(Recom,'- any mix of PV and PQ generators.');

                                                bus1=LF.vsrc.busNumber{iBlock}(iphase);

                                                if BusType(bus1)==1&&strcmp(LF.vsrc.busType{iBlock},'swing')
                                                    LF.error=sprintf('--> Attempt to connect two swing synchronous machines or voltage sources at bus %s',LF.bus(bus1).ID);
                                                    LF.error=char(LF.error,' ');
                                                    LF.error=char(LF.error,Recom);
                                                    LF.status=-1;
                                                    return
                                                end

                                                if(BusType(bus1)==2&&strcmp(LF.vsrc.busType{iBlock},'swing')&&strcmp(LF.vsrc.blockType{iBlock},'Vprog'))
                                                    LF.error=sprintf('--> Attempt to connect a ''swing'' type ideal voltage source at bus %s',LF.bus(bus1).ID);
                                                    LF.error=char(LF.error,sprintf('    which is also specified as a PV generation bus.'));
                                                    LF.error=char(LF.error,' ');
                                                    LF.error=char(LF.error,Recom);
                                                    LF.status=-1;
                                                    return
                                                end

                                                if(BusType(bus1)==1&&strcmp(LF.vsrc.busType{iBlock},'PV'))

                                                    LF.error=sprintf('--> Attempt to connect a ''PV'' type voltage source at bus %s',LF.bus(bus1).ID);
                                                    LF.error=char(LF.error,sprintf('    which is also specified as a swing bus.'));
                                                    LF.error=char(LF.error,' ');
                                                    LF.error=char(LF.error,Recom);
                                                    LF.status=-1;
                                                    return
                                                end



                                                IsFiniteQlimBus=isfinite(Qmin(bus1))|isfinite(Qmax(bus1));
                                                IsFiniteQlim=isfinite(LF.vsrc.Qmin{iBlock}(iphase))|isfinite(LF.vsrc.Qmax{iBlock}(iphase));

                                                if BusType(bus1)==2&&strcmp(LF.vsrc.busType{iBlock},'PV')&&(IsFiniteQlim||IsFiniteQlimBus)
                                                    LF.error=sprintf('--> Attempt to connect a PV voltage source with finite Qmin or Qmax limits at bus %s where other PV sources are connected.\n',LF.bus(bus1).ID);
                                                    LF.error=char(LF.error,'Only one PV generator with finite Q limits can be connected at a generation bus.');

                                                    LF.status=-1;
                                                    return
                                                end

                                                switch char(connection)
                                                case{'ab','bc','ca'}
                                                    SpqGenPP(bus1)=SpqGenPP(bus1)+(LF.vsrc.P{iBlock}(iphase)+1i*LF.vsrc.Q{iBlock}(iphase))/Pbase;
                                                case{'an','bn','cn'}
                                                    SpqGenPN(bus1)=SpqGenPN(bus1)+(LF.vsrc.P{iBlock}(iphase)+1i*LF.vsrc.Q{iBlock}(iphase))/Pbase;
                                                end

                                                switch LF.vsrc.busType{iBlock}

                                                case 'swing'

                                                    BusType(bus1)=1;
                                                    Vinit(bus1)=LF.bus(bus1).vref*exp(1i*LF.bus(bus1).angle*pi/180);

                                                case 'PV'

                                                    BusType(bus1)=2;
                                                    Vinit(bus1)=LF.bus(bus1).vref;
                                                    Sbus(bus1)=Sbus(bus1)+LF.vsrc.P{iBlock}(iphase)/Pbase;

                                                    Qmin(bus1)=LF.vsrc.Qmin{iBlock}(iphase)/Pbase;
                                                    Qmax(bus1)=LF.vsrc.Qmax{iBlock}(iphase)/Pbase;

                                                case{'PQ'}
                                                    switch char(connection)
                                                    case{'ag','bg','cg'}
                                                        Sbus(bus1)=Sbus(bus1)+(LF.vsrc.P{iBlock}(iphase)+1i*LF.vsrc.Q{iBlock}(iphase))/Pbase;
                                                        SpqGen(bus1)=SpqGen(bus1)+(LF.vsrc.P{iBlock}(iphase)+1i*LF.vsrc.Q{iBlock}(iphase))/Pbase;

                                                        Qmin(bus1)=Qmin(bus1)+LF.vsrc.Q{iBlock}(iphase)/Pbase;
                                                        Qmax(bus1)=Qmax(bus1)+LF.vsrc.Q{iBlock}(iphase)/Pbase;

                                                    case{'ab','bc','ca'}
                                                        SbusPP(bus1)=SbusPP(bus1)+(LF.vsrc.P{iBlock}(iphase)+1i*LF.vsrc.Q{iBlock}(iphase))/Pbase;
                                                        switch LF.bus(bus1).TypeNumberPP
                                                        case 0
                                                            LF.bus(bus1).TypeNumberPP=3;
                                                        case 3

                                                        case 4
                                                            LF.error=sprintf('Phase-phase source %s Bus No %d Type ''PQ'' -> A phase-phase ''I'' load is already connected to this bus',BlockName,bus1);
                                                            LF.status=-1;
                                                            return
                                                        end

                                                    case{'an','bn','cn'}
                                                        SbusPN(bus1)=SbusPN(bus1)+(LF.vsrc.P{iBlock}(iphase)+1i*LF.vsrc.Q{iBlock}(iphase))/Pbase;
                                                        switch LF.bus(bus1).TypeNumberPN
                                                        case 0
                                                            LF.bus(bus1).TypeNumberPN=3;
                                                        case 3

                                                        case 4
                                                            LF.error=sprintf('Phase-neutral source %s Bus No %d Type ''PQ'' -> A phase-neutral ''I'' load is already connected to this bus',BlockName,bus1);
                                                            LF.status=-1;
                                                            return
                                                        end

                                                    end
                                                end

                                            end
                                        end



                                        Npqload=length([LF.pqload.handle]);

                                        for imac=1:Npqload

                                            BlockName=get(LF.pqload.handle{imac},'Name');
                                            BlockName=strrep(BlockName,newline,char(32));

                                            if any(isnan(LF.pqload.busNumber{imac}))||all(LF.pqload.busNumber{imac}==0)
                                                LF.error=sprintf('--> The dynamic load block ''%s'' must be connected to a Load Flow Bus block',BlockName);

                                                LF.status=-1;
                                                return
                                            end

                                            bus1=LF.pqload.busNumber{imac};

                                            SbusDYN(bus1(1))=SbusDYN(bus1(1))-(LF.pqload.P{imac}+1i*LF.pqload.Q{imac})/Pbase;

                                            Qmin(bus1)=Qmin(bus1)+LF.pqload.Qmin{imac}/Pbase;
                                            Qmax(bus1)=Qmin(bus1)+LF.pqload.Qmax{imac}/Pbase;

                                        end



                                        NrlcloadBlocks=length([LF.rlcload.handle]);

                                        Nrlcload=0;
                                        for iBlock=1:NrlcloadBlocks
                                            BlockName=get(LF.rlcload.handle{iBlock},'Name');
                                            BlockName=strrep(BlockName,newline,char(32));

                                            if(any(isnan(LF.rlcload.busNumber{iBlock}))||all(LF.rlcload.busNumber{iBlock}==0))&&~strcmp(LF.rlcload.busType{iBlock},'Z')
                                                LF.error=sprintf('--> The ''%s'' type RLC load block ''%s'' must be connected to a Load Flow Bus block',LF.rlcload.busType{iBlock},BlockName);

                                                LF.status=-1;
                                                return
                                            end

                                            Nphases=length(LF.rlcload.busNumber{iBlock});
                                            if Nphases==2&&strcmp(LF.rlcload.blockType{iBlock},'RLC load 1ph')
                                                Nphases=1;
                                            end

                                            if strcmp(LF.rlcload.busType{iBlock},'Z'),continue;end
                                            for iphase=1:Nphases
                                                Nrlcload=Nrlcload+1;
                                                switch char(LF.rlcload.connection{iBlock})
                                                case 'Yg'
                                                    connection3ph={'ag','bg','cg'};
                                                    connection=connection3ph{iphase};
                                                case 'Yn'
                                                    connection3ph={'an','bn','cn'};
                                                    connection=connection3ph{iphase};
                                                case 'D'
                                                    connection3ph={'ab','bc','ca'};
                                                    connection=connection3ph{iphase};
                                                case{'ag','bg','cg','an','bn','cn','ab','bc','ca'}
                                                    Nphases=1;
                                                    connection=LF.rlcload.connection{iBlock};
                                                otherwise
                                                    error(message('physmod:powersys:library:UnbalancedLFInvalidRLCLoadConnection',char(LF.rlcload.connection{iBlock}),BlockName));

                                                end

                                                bus1=LF.rlcload.busNumber{iBlock}(iphase);

                                                if Nphases==1&&strcmp(LF.rlcload.blockType{iBlock},'RLC load 1ph')
                                                    switch connection
                                                    case{'ab','bc'}
                                                        bus1=min(LF.rlcload.busNumber{iBlock});
                                                    case{'ca'}
                                                        bus1=max(LF.rlcload.busNumber{iBlock});
                                                    end
                                                end

                                                switch char(connection)
                                                case{'ag','bg','cg'}

                                                    if(BusType(bus1)==1||BusType(bus1)==2)&&strcmp(LF.rlcload.busType{iBlock},'I')
                                                        LF.error=sprintf('--> The constant current load %s cannot be connected at bus %d which is specified as a swing bus or generation bus',BlockName,bus1);

                                                        LF.status=-1;
                                                        return
                                                    end

                                                    if(BusType(bus1)==3||BusType(bus1)==4)&&strcmp(LF.rlcload.busType{iBlock},'I')

                                                        BusType(bus1)=4;
                                                    end


                                                    if BusType(bus1)==2


                                                        Sbus(bus1)=Sbus(bus1)-LF.rlcload.P{iBlock}(iphase)/Pbase;
                                                        SpqloadGen(bus1)=SpqloadGen(bus1)+(LF.rlcload.P{iBlock}(iphase)+1i*LF.rlcload.Q{iBlock}(iphase))/Pbase;



                                                        Qmin(bus1)=Qmin(bus1)-LF.rlcload.Q{iBlock}(iphase)/Pbase;
                                                        Qmax(bus1)=Qmax(bus1)-LF.rlcload.Q{iBlock}(iphase)/Pbase;


                                                    else
                                                        Sbus(bus1)=Sbus(bus1)-(LF.rlcload.P{iBlock}(iphase)+1i*LF.rlcload.Q{iBlock}(iphase))/Pbase;
                                                    end

                                                case{'ab','bc','ca'}
                                                    SbusPP(bus1)=SbusPP(bus1)-(LF.rlcload.P{iBlock}(iphase)+1i*LF.rlcload.Q{iBlock}(iphase))/Pbase;
                                                    SpqloadGenPP(bus1)=SpqloadGenPP(bus1)+(LF.rlcload.P{iBlock}(iphase)+1i*LF.rlcload.Q{iBlock}(iphase))/Pbase;
                                                    switch char(LF.rlcload.busType(iBlock))
                                                    case 'PQ'
                                                        switch LF.bus(bus1).TypeNumberPP
                                                        case 0
                                                            LF.bus(bus1).TypeNumberPP=3;
                                                        case 3

                                                        case 4
                                                            LF.error=sprintf('RLC phase-phase load %s Bus No %d Type ''PQ'' -> A phase-phase ''I'' load or source is already connected to this bus',BlockName,bus1);
                                                            LF.status=-1;
                                                            return
                                                        end

                                                    case 'I'
                                                        switch LF.bus(bus1).TypeNumberPP
                                                        case 0
                                                            LF.bus(bus1).TypeNumberPP=4;
                                                        case 3
                                                            LF.error=sprintf('RLC phase-phase load No %s Bus No %d Type ''I'' -> A phase-phase ''PQ'' load or source is already connected to this bus',BlockName,bus1);
                                                            LF.status=-1;
                                                            return
                                                        case 4

                                                        end
                                                    end

                                                case{'an','bn','cn'}
                                                    SbusPN(bus1)=SbusPN(bus1)-(LF.rlcload.P{iBlock}(iphase)+1i*LF.rlcload.Q{iBlock}(iphase))/Pbase;
                                                    SpqloadGenPN(bus1)=SpqloadGenPN(bus1)+(LF.rlcload.P{iBlock}(iphase)+1i*LF.rlcload.Q{iBlock}(iphase))/Pbase;
                                                    switch char(LF.rlcload.busType(iBlock))
                                                    case 'PQ'
                                                        switch LF.bus(bus1).TypeNumberPN
                                                        case 0
                                                            LF.bus(bus1).TypeNumberPN=3;
                                                        case 3

                                                        case 4
                                                            LF.error=sprintf('RLC phase-neutral load %s Bus No %d Type ''PQ'' -> A phase-neutral ''I'' load or source is already connected to this bus',BlockName,bus1);
                                                            LF.status=-1;
                                                            return
                                                        end

                                                    case 'I'
                                                        switch LF.bus(bus1).TypeNumberPN
                                                        case 0
                                                            LF.bus(bus1).TypeNumberPN=4;
                                                        case 3
                                                            LF.error=sprintf('RLC phase-neutral load %s Bus No %d Type ''I'' -> A phase-neutral ''PQ'' load or source is already connected to this bus',BlockName,bus1);
                                                            LF.status=-1;
                                                            return
                                                        case 4

                                                        end
                                                    end

                                                end
                                            end
                                        end



                                        Nasm=length([LF.asm.handle]);

                                        for imac=1:Nasm

                                            BlockName=get(LF.asm.handle{imac},'Name');
                                            BlockName=strrep(BlockName,newline,char(32));

                                            if any(isnan(LF.asm.busNumber{imac}))||all(LF.asm.busNumber{imac}==0)
                                                LF.error=sprintf('--> The asynchronous machine block ''%s'' must be connected to a Load Flow Bus block',BlockName);

                                                LF.status=-1;
                                                return
                                            end

                                            switch get_param(LF.asm.handle{imac},'RotorType')
                                            case{'Wound','Double squirrel-cage'}


                                                S1='The Load Flow Tool does not yet support asynchronous machines with Rotor Type parameter set to ''Wound'' or ''Double-squirrel cage.''';

                                                S2=sprintf('If applicable, you can change the Rotor Type parameter of the following block to ''Squirrel-cage'' to perform the load flow:\n\n%s',BlockName);

                                                LF.error=sprintf('%s\n\n%s',S1,S2);

                                                LF.status=-1;
                                                return
                                            end

                                            bus1=LF.asm.busNumber{imac};

                                            SbusASM(bus1(1))=SbusASM(bus1(1))+LF.asm.pmec{imac}/Pbase;

                                        end



                                        for ibus=1:Nbus
                                            LF.bus(ibus).TypeNumber=BusType(ibus);
                                        end

                                        for ibus=1:Nbus
                                            LF.bus(ibus).Sref=Sbus(ibus);
                                            LF.bus(ibus).SrefPP=SbusPP(ibus);
                                            LF.bus(ibus).SrefPN=SbusPN(ibus);
                                            LF.bus(ibus).SrefSM=SbusSM(ibus);
                                            LF.bus(ibus).SrefDYN=SbusDYN(ibus);
                                            LF.bus(ibus).SrefASM=SbusASM(ibus);

                                            LF.bus(ibus).Qmin=Qmin(ibus);
                                            LF.bus(ibus).Qmax=Qmax(ibus);
                                        end


                                        [LF,niter,ErrorMessage]=unbalancedNewtonRaphson(LF,BusMonitor,erPQ_max,niter_max);



                                        if~isempty(ErrorMessage)
                                            LF.error=ErrorMessage;
                                            LF.status=-1;
                                            return
                                        end

                                        Sbus_net=zeros(Nbus,1);
                                        V=zeros(Nbus,1);

                                        for ibus=1:Nbus
                                            Sbus_net(ibus)=LF.bus(ibus).Sbus;
                                            V(ibus)=LF.bus(ibus).Vbus;
                                        end






                                        for ib=1:Nbus
                                            NumberOfPhases=LF.bus(ib).NumberOfPhases;
                                            if NumberOfPhases>0

                                                ib1=ib:ib+NumberOfPhases-1;
                                                ib2=ib1+1;ib2(end)=ib1(1);
                                                ib3=ib1-1;ib3(1)=ib1(end);



                                                kVcorPP=ones(length(ib1),1);
                                                kVcorPP2=ones(length(ib1),1);
                                                n=1;
                                                for ibus=ib1
                                                    if LF.bus(ibus).TypeNumberPP==4
                                                        kVcorPP(n)=abs(V(ib1(n))-V(ib2(n)))/sqrt(3);
                                                        n=n+1;
                                                    end
                                                end
                                                kVcorPP2(2:end)=kVcorPP(1:end-1);
                                                kVcorPP2(1)=kVcorPP(end);

                                                if any(SpqGenPP(ib1))



                                                    SPG=SpqGenPP(ib1).*kVcorPP.*(1+V(ib2)./(V(ib1)-V(ib2)))-SpqGenPP(ib3).*kVcorPP2.*V(ib1)./(V(ib3)-V(ib1));
                                                    SpqGen(ib1)=SpqGen(ib1)+SPG;
                                                end
                                                if any(SpqloadGenPP(ib1))



                                                    SPG=SpqloadGenPP(ib1).*kVcorPP.*(1+V(ib2)./(V(ib1)-V(ib2)))-SpqloadGenPP(ib3).*kVcorPP2.*V(ib1)./(V(ib3)-V(ib1));
                                                    SpqloadGen(ib1)=SpqloadGen(ib1)+SPG;
                                                end


                                                Vng=LF.bus(ib).Vng;

                                                kVcorPN=ones(length(ib1),1);
                                                n=1;
                                                for ibus=ib1
                                                    if LF.bus(ibus).TypeNumberPN==4
                                                        kVcorPN(n)=abs(V(ib1(n)));
                                                        n=n+1;
                                                    end
                                                end

                                                if any(SpqGenPN(ib1))



                                                    SPG=SpqGenPN(ib1).*kVcorPN.*(1+Vng./(V(ib1)-Vng));
                                                    SpqGen(ib1)=SpqGen(ib1)+SPG;
                                                end
                                                if any(SpqloadGenPN(ib1))



                                                    SPG=SpqGenPN(ib1).*kVcorPN.*(1+Vng./(V(ib1)-Vng));
                                                    SpqloadGen(ib1)=SpqloadGen(ib1)+SPG;
                                                end



                                                if LF.bus(ib).sm>0
                                                    MachineNumber=LF.bus(ib).sm;
                                                    for imac=MachineNumber
                                                        if strcmp(LF.sm.busType{imac},'PQ')
                                                            Pnom=LF.sm.pnom{imac};
                                                            Z2=LF.sm.Z2{imac}*LF.Pbase/Pnom;
                                                            Z2_c=conj(Z2);
                                                            S=(LF.sm.P{imac}+1i*LF.sm.Q{imac})/LF.Pbase;
                                                            Va=V(ib1(1));
                                                            Vb=V(ib1(2));
                                                            Vc=V(ib1(3));
                                                            Va_c=conj(Va);
                                                            Vb_c=conj(Vb);
                                                            Vc_c=conj(Vc);

                                                            A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                            Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*S);
                                                            Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*S)*a;
                                                            Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*S)*a2;
                                                            Sa=Na/A;
                                                            Sb=Nb/A;
                                                            Sc=Nc/A;
                                                            SPG=[Sa;Sb;Sc];

                                                            SpqGen(ib1)=SpqGen(ib1)+SPG;
                                                        end
                                                    end
                                                end


                                                if LF.bus(ib).pqload>0
                                                    Z2_c=1e6;
                                                    S=SbusDYN(ib);
                                                    Va=V(ib1(1));
                                                    Vb=V(ib1(2));
                                                    Vc=V(ib1(3));
                                                    Va_c=conj(Va);
                                                    Vb_c=conj(Vb);
                                                    Vc_c=conj(Vc);

                                                    A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                    Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*S);
                                                    Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*S)*a;
                                                    Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*S)*a2;
                                                    Sa=Na/A;
                                                    Sb=Nb/A;
                                                    Sc=Nc/A;
                                                    SPG=[Sa;Sb;Sc];

                                                    if BusType(ib)==2
                                                        SpqloadGen(ib1)=SpqloadGen(ib1)-SPG;
                                                    end
                                                end

                                            end
                                        end



                                        if niter<niter_max

                                            ibSwing=find(BusType==1);
                                            ibGen=find(BusType==2);
                                            ibLoad=find(BusType==3|BusType==4);






















                                            if isempty(ibGen)
                                                ibGen=[];
                                            end
                                            if isempty(ibLoad)
                                                ibLoad=[];
                                            end


                                            Sgen(ibGen)=Sbus_net(ibGen)+SpqloadGen(ibGen);
                                            Sgen(ibLoad)=Sgen(ibLoad)+SpqGen(ibLoad);
                                            Sgen(ibSwing)=Sbus_net(ibSwing)-Sbus(ibSwing)+SpqGen(ibSwing);


                                            Spqload(ibLoad)=-Sbus_net(ibLoad)+SpqGen(ibLoad);
                                            Spqload(ibGen)=SpqloadGen(ibGen);
                                            Spqload(ibSwing)=-Sbus(ibSwing)+SpqGen(ibSwing);

                                            for ib=1:Nbus
                                                LF.bus(ib).Sgen=Sgen(ib);
                                                LF.bus(ib).Spqload=Spqload(ib);

                                                LF.bus(ib).SpqloadGenPP=SpqloadGenPP(ib);
                                                LF.bus(ib).SpqloadGenPN=SpqloadGenPN(ib);
                                                LF.bus(ib).SpqGenPP=SpqGenPP(ib);
                                                LF.bus(ib).SpqGenPN=SpqGenPN(ib);

                                                if any(LF.ibGenQmin==ib)
                                                    LF.bus(ib).QminReached=1;
                                                else
                                                    LF.bus(ib).QminReached=0;
                                                end

                                                if any(LF.ibGenQmax==ib)
                                                    LF.bus(ib).QmaxReached=1;
                                                else
                                                    LF.bus(ib).QmaxReached=0;
                                                end
                                            end



                                            for imac=1:Nsm

                                                bus1=LF.sm.busNumber{imac};
                                                Rs=LF.sm.rs{imac};
                                                Xd=LF.sm.xd{imac};
                                                Xq=LF.sm.xq{imac};

                                                switch LF.sm.busType{imac}

                                                case 'swing'

                                                    Sgenerator=Sgen(bus1)-SpqGen(bus1);
                                                    LF.sm.prefpu{imac}=real(Sgen(bus1))*Pbase./LF.sm.pnom{imac};
                                                    Sgenerator=sum(Sgenerator);

                                                case 'PV'

                                                    if abs(sum(real(Sgen(bus1)-SpqGen(bus1)))-LF.sm.P{imac}/Pbase)<=erPQ_max





                                                        Sgenerator=Sgen(bus1)-SpqGen(bus1);
                                                        Sgenerator=sum(Sgenerator);
                                                    else




                                                        Sgenerator=LF.sm.P{imac}/Pbase+...
                                                        1i*sum(imag(Sgen(bus1)-SpqGen(bus1)))*LF.sm.P{imac}/sum((real(Sgen(bus1)-SpqGen(bus1)))*Pbase);
                                                        Sgenerator=sum(Sgenerator);
                                                    end

                                                    LF.sm.prefpu{imac}=LF.sm.P{imac}/LF.sm.pnom{imac};


                                                case 'PQ'


                                                    Sgenerator=(LF.sm.P{imac}+1i*LF.sm.Q{imac})/Pbase;
                                                    LF.sm.prefpu{imac}=LF.sm.P{imac}/LF.sm.pnom{imac};

                                                end


                                                Va=V(bus1(1));
                                                Vb=V(bus1(2));
                                                Vc=V(bus1(3));
                                                Va_c=conj(Va);
                                                Vb_c=conj(Vb);
                                                Vc_c=conj(Vc);

                                                Pnom=LF.sm.pnom{imac};
                                                Z2=LF.sm.Z2{imac}*Pbase/Pnom;
                                                Z2_c=conj(Z2);
                                                A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*Sgenerator);
                                                Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*Sgenerator)*a;
                                                Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*Sgenerator)*a2;
                                                Sa=Na/A;
                                                Sb=Nb/A;
                                                Sc=Nc/A;
                                                Sabc=[Sa,Sb,Sc]*Pbase/Pnom;
                                                Vabc=V(bus1).'.*Vbase(bus1)/(LF.sm.vnom{imac}/sqrt(3));
                                                Iabc=conj([Sa,Sb,Sc]*Pbase/(Pnom/3)./Vabc);


                                                Vseq1=sum(V(bus1).'.*Vbase(bus1)/(LF.sm.vnom{imac}/sqrt(3)).*[1,a,a2])/3;
                                                Iseq1=sum(Iabc.*[1,a,a2])/3;

                                                LF.sm.I{imac}=Iabc;
                                                LF.sm.S{imac}=Sabc;
                                                LF.sm.pmec{imac}=sum(real(Sabc)*Pnom+Rs*(abs(Iabc)).^2*(Pnom/3));
                                                Ef1=Vseq1+Iseq1*Rs+1i*Iseq1*Xq;

                                                Id=abs(abs(Iseq1))*sin(angle(Ef1)-angle(Iseq1))*exp(1i*(angle(Ef1)-pi/2));
                                                Iq=abs(abs(Iseq1))*cos(angle(Ef1)-angle(Iseq1))*exp(1i*(angle(Ef1)));

                                                Ean=Vseq1+Rs*Iseq1+1i*Id*Xd+1i*Iq*Xq;
                                                LF.sm.Vf{imac}=abs(Ean);
                                                LF.sm.Vt{imac}=V(bus1).'.*Vbase(bus1)/(LF.sm.vnom{imac}/sqrt(3));

                                                LF.sm.th0deg{imac}=angle(Ean)*180/pi-90;

                                            end


                                            for iBlock=1:NvsrcBlocks
                                                Nphases=length(LF.vsrc.busNumber{iBlock});
                                                if Nphases==2&&strcmp(LF.vsrc.blockType{iBlock},'Vsrc 1ph')
                                                    Nphases=1;
                                                end
                                                for iphase=1:Nphases
                                                    bus1=LF.vsrc.busNumber{iBlock}(iphase);
                                                    Zbase=(LF.bus(bus1).vbase)^2/LF.Pbase;
                                                    Lbase=Zbase/(2*pi*LF.freq);
                                                    z=(LF.vsrc.r{iBlock}/Zbase+1i*LF.vsrc.x{iBlock}/Lbase);

                                                    switch LF.vsrc.busType{iBlock}
                                                    case 'swing'
                                                        Sgenerator=Sgen(bus1)-SpqGen(bus1);
                                                    case 'PV'
                                                        if abs(real(Sgen(bus1)-SpqGen(bus1))-LF.vsrc.P{iBlock}(iphase))<=erPQ_max




                                                            Sgenerator=Sgen(bus1)-SpqGen(bus1);
                                                        else




                                                            Sgenerator=LF.vsrc.P{iBlock}(iphase)/Pbase+...
                                                            1i*imag(Sgen(bus1)-SpqGen(bus1))*LF.vsrc.P{iBlock}(iphase)/(real(Sgen(bus1)-SpqGen(bus1))*Pbase);
                                                        end
                                                    case 'PQ'


                                                        Sgenerator=(LF.vsrc.P{iBlock}(iphase)+1i*LF.vsrc.Q{iBlock}(iphase))/Pbase;
                                                    end

                                                    switch LF.vsrc.connection{iBlock}
                                                    case{'Yg','ag','bg','cg'}

                                                        I=conj(Sgenerator/V(bus1));
                                                        LF.vsrc.I{iBlock}(iphase)=I;
                                                        LF.vsrc.S{iBlock}(iphase)=V(bus1)*conj(I);
                                                        LF.vsrc.Vt{iBlock}(iphase)=V(bus1);
                                                        LF.vsrc.Vint{iBlock}(iphase)=LF.vsrc.Vt{iBlock}(iphase)+z*I;
                                                    case{'Y','Yn','an','bn','cn'}

                                                        Vng=LF.bus(LF.vsrc.busNumber{iBlock}(1)).Vng;
                                                        I=conj(Sgenerator/(V(bus1)-Vng));
                                                        LF.vsrc.I{iBlock}(iphase)=I;
                                                        LF.vsrc.S{iBlock}(iphase)=V(bus1)*conj(I);
                                                        LF.vsrc.Vt{iBlock}(iphase)=V(bus1);
                                                        LF.vsrc.Vint{iBlock}(iphase)=LF.vsrc.Vt{iBlock}(iphase)-Vng+z*I;
                                                    end


                                                    if strcmp(LF.vsrc.blockType{iBlock},'Vsrc 1ph')&&length(LF.vsrc.busNumber{iBlock})==2
                                                        LF.vsrc.Vt{iBlock}=V(LF.vsrc.busNumber{iBlock});
                                                        LF.vsrc.Vint{iBlock}=LF.vsrc.Vt{iBlock};
                                                    end

                                                end
                                            end



                                            for imac=1:Nasm

                                                bus1=LF.asm.busNumber{imac};
                                                Pnom=LF.asm.pnom{imac};
                                                Pmec=LF.asm.pmec{imac}/Pnom;
                                                Vnom=LF.asm.vnom{imac};
                                                r1=LF.asm.r1{imac};
                                                x1=LF.asm.x1{imac};
                                                r2=LF.asm.r2{imac};
                                                x2=LF.asm.x2{imac};
                                                xm=LF.asm.xm{imac};


                                                Vabc=V(bus1).*[LF.bus(bus1).vbase]'/(Vnom/sqrt(3));
                                                [Sabc,s,T1,T2]=unbalancedThreePhaseASM(Vabc,Pmec,r1,x1,r2,x2,xm);
                                                Iabc=3*(conj(Sabc./Vabc)).';
                                                LF.asm.I{imac}=Iabc;
                                                LF.asm.S{imac}=Sabc;
                                                LF.asm.slip{imac}=s;
                                                LF.asm.T{imac}=T1+T2;
                                                LF.asm.Vt{imac}=V(bus1);

                                            end


                                            for imac=1:Npqload

                                                bus1=LF.pqload.busNumber{imac};

                                                Z2_c=1e6;
                                                S=(LF.pqload.P{imac}+1i*LF.pqload.Q{imac})/Pbase;
                                                Va=V(bus1(1));
                                                Vb=V(bus1(2));
                                                Vc=V(bus1(3));
                                                Va_c=conj(Va);
                                                Vb_c=conj(Vb);
                                                Vc_c=conj(Vc);

                                                A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*S);
                                                Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*S)*a;
                                                Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*S)*a2;
                                                Sa=Na/A;
                                                Sb=Nb/A;
                                                Sc=Nc/A;
                                                Sabc=[Sa,Sb,Sc];
                                                Iabc=conj(Sabc./V(bus1).');
                                                Vseq1=sum(V(bus1).'.*Vbase(bus1)/(LF.pqload.vnom{imac}/sqrt(3)).*[1,a,a2])/3;
                                                LF.pqload.Vt{imac}=V(bus1);
                                                LF.pqload.Vseq1{imac}=Vseq1;
                                                LF.pqload.I{imac}=Iabc;
                                                LF.pqload.S{imac}=Sabc;

                                            end


                                            for iBlock=1:NrlcloadBlocks
                                                if strcmp(LF.rlcload.busType{iBlock},'Z'),continue;end
                                                Nphases=length(LF.rlcload.busNumber{iBlock});
                                                if Nphases==2&&strcmp(LF.rlcload.blockType{iBlock},'RLC load 1ph')
                                                    Nphases=1;
                                                end
                                                for iphase=1:Nphases
                                                    bus1=LF.rlcload.busNumber{iBlock}(iphase);
                                                    I=conj((LF.rlcload.P{iBlock}(iphase)+1i*LF.rlcload.Q{iBlock}(iphase))/Pbase/V(bus1));
                                                    LF.rlcload.Vt{iBlock}(iphase)=V(bus1);
                                                    LF.rlcload.I{iBlock}(iphase)=I;
                                                    LF.rlcload.S{iBlock}(iphase)=V(bus1)*conj(I);


                                                    if strcmp(LF.rlcload.blockType{iBlock},'RLC load 1ph')&&length(LF.rlcload.busNumber{iBlock})==2
                                                        LF.rlcload.Vt{iBlock}=V(LF.rlcload.busNumber{iBlock});
                                                    end
                                                end

                                            end

                                        else
                                            LF.error=sprintf('The load flow did not converge in %d iterations',niter_max);
                                            LF.status=-1;
                                            return
                                        end

                                        if any(isnan([LF.bus.Vbus]))
                                            LF.error=sprintf('The load flow did not converge (NaN)');
                                            LF.status=-1;
                                            return
                                        end
























                                        LF.niter=niter;
                                        LF.status=1;
                                        function[Sabc,s,T1,T2,Z2]=unbalancedThreePhaseASM(Vabc,Pm1,r1,x1,r2,x2,xm)



















                                            a=exp(1i*2*pi/3);
                                            a2=a*a;

                                            T=[1,1,1
                                            1,a2,a
                                            1,a,a2];

                                            V1=1/3*sum(Vabc.*[1;a;a2]);
                                            V2=1/3*sum(Vabc.*[1;a2;a]);
                                            V1mag=abs(V1);



                                            z1=r1+1i*x1;
                                            zm=1i*xm;
                                            zth=z1*zm/(z1+zm);
                                            rth=real(zth);
                                            xth=imag(zth);

                                            Vm2=V1mag^2*xm^2/(r1^2+(x1+xm)^2);

                                            aa=Pm1;
                                            b=2*Pm1*rth-Vm2;
                                            c=Pm1*(x2+xth)^2+Pm1*rth^2+Vm2*r2;
                                            delta=b^2-4*aa*c;
                                            r2_s=(-b+sqrt(delta))/(2*aa);
                                            s=r2/r2_s;



                                            Vth=V1*zm/(z1+zm);
                                            zth=z1*zm/(z1+zm);
                                            i2=Vth/(zth+r2/s+1i*x2);
                                            Vm=i2*(r2/s+1i*x2);
                                            i1_1=i2+Vm/zm;

                                            T1=r2*(abs(i2))^2*(1-s)/s/(1-s);




                                            s2=2-s;
                                            Vth=V2*zm/(z1+zm);
                                            i2=Vth/(zth+r2/s2+1i*x2);
                                            Vm=i2*(r2/s2+1i*x2);
                                            i1_2=i2+Vm/zm;

                                            T2=r2*(abs(i2))^2*(1-s2)/s2/(1-s2);



                                            Iabc=T*[0;i1_1;i1_2];
                                            Sabc=1/3*Vabc.*conj(Iabc);


                                            Z2=V2/i1_2;
                                            function[LF,niter,ErrorMessage]=unbalancedNewtonRaphson(LF,BusMonitor,erPQ_max,niter_max)
































































































































































































































                                                [node_numbers,subnet_numbers,nb_subnetworks]=getUnbalancedSubnetworks(LF);






                                                LF.NbOfNetworks=nb_subnetworks;

                                                for ires=1:nb_subnetworks

                                                    n=subnet_numbers==ires&node_numbers<10000;

                                                    node_res=node_numbers(n);
                                                    LF.Networks(ires).busNumber=sort(node_res);

                                                    SwingBus=[];
                                                    for ibus=node_res
                                                        if LF.bus(ibus).TypeNumber==1
                                                            SwingBus=[SwingBus,ibus];%#ok
                                                        end
                                                    end

                                                    LF.Networks(ires).SwingBus=SwingBus;

                                                    if isempty(SwingBus)
                                                        for ibus=node_res
                                                            LF.bus(ibus).IsInSubnetWithSwingBus=0;
                                                        end
                                                    else
                                                        for ibus=node_res
                                                            LF.bus(ibus).IsInSubnetWithSwingBus=1;
                                                        end
                                                    end

                                                end



                                                nbus_select=[];
                                                Nbus1=size(LF.Ybus,1);

                                                for ibus=1:Nbus1
                                                    if LF.bus(ibus).IsInSubnetWithSwingBus
                                                        nbus_select=[nbus_select,ibus];%#ok % list of retained bus numbers
                                                    end
                                                end



                                                Sbus=zeros(Nbus1,1);
                                                SbusPP=zeros(Nbus1,1);
                                                SbusPN=zeros(Nbus1,1);
                                                SbusSM=zeros(Nbus1,1);
                                                SbusDYN=zeros(Nbus1,1);
                                                SbusASM=zeros(Nbus1,1);
                                                Vinit=zeros(Nbus1,1);
                                                Qmin=zeros(Nbus1,1);
                                                Qmax=zeros(Nbus1,1);

                                                BusType=zeros(1,Nbus1);

                                                for ibus=1:Nbus1

                                                    if isempty(LF.bus(ibus).vref)
                                                        Vinit(ibus)=0;
                                                    else
                                                        Vinit(ibus)=LF.bus(ibus).vref*exp(1i*LF.bus(ibus).angle*pi/180);
                                                    end
                                                    Sbus(ibus)=LF.bus(ibus).Sref;
                                                    SbusPP(ibus)=LF.bus(ibus).SrefPP;
                                                    SbusPN(ibus)=LF.bus(ibus).SrefPN;
                                                    SbusSM(ibus)=LF.bus(ibus).SrefSM;
                                                    SbusDYN(ibus)=LF.bus(ibus).SrefDYN;
                                                    SbusASM(ibus)=LF.bus(ibus).SrefASM;

                                                    Qmin(ibus)=LF.bus(ibus).Qmin;
                                                    Qmax(ibus)=LF.bus(ibus).Qmax;
                                                    BusType(ibus)=LF.bus(ibus).TypeNumber;

                                                end

                                                BusIDstr=char(LF.bus.ID);


                                                Vinit=Vinit(nbus_select);
                                                Sbus=Sbus(nbus_select);
                                                Qmin=Qmin(nbus_select);
                                                Qmax=Qmax(nbus_select);
                                                BusType=BusType(nbus_select);
                                                BusIDstr=BusIDstr(nbus_select,:);

                                                Ybus=LF.Ybus(nbus_select,nbus_select);
                                                Nbus=size(Ybus,1);


                                                a=exp(1i*2*pi/3);
                                                a2=a*a;

                                                kDeltaV1=10;



                                                V=Vinit;

                                                ibGenQmin=[];
                                                ibGenQmax=[];
                                                niter=0;
                                                ErrorMessage='';

                                                ibSwing=find(BusType==1);

                                                if isempty(ibSwing)
                                                    ErrorMessage=sprintf('--> The model contains no swing bus.');
                                                    ErrorMessage=char(ErrorMessage,sprintf('At least one bus must be specified as ''swing'' bus type.'));
                                                    return
                                                end

                                                ibGen=find(BusType==2);
                                                ibLoad=find(BusType==3|BusType==4);
                                                ibGenLoad=find(BusType~=1);



                                                ibLoad_SMPV=ibLoad;
                                                for imac=1:length(LF.sm.busType)
                                                    if strcmp(LF.sm.busType{imac},'PV')
                                                        ibLoad_SMPV=[ibLoad_SMPV,LF.sm.busNumber{imac}];%#ok
                                                    end
                                                end
                                                ibLoad_SMPV=sort(ibLoad_SMPV);


                                                ibIconst=find(BusType==4);





                                                TitleBusMonitor=[];
                                                FormatBusMonitor=[];
                                                val=[];

                                                JacP=zeros(Nbus,2*Nbus);
                                                JacQ=zeros(Nbus,2*Nbus);


                                                DangVmagV=zeros(2*Nbus,1);
                                                index=1:Nbus;
                                                Y=Ybus;
                                                k_VcorIconst=ones(Nbus,1);









                                                Ybus_Zconst=Ybus;

                                                for ib=1:Nbus

                                                    if BusType(ib)==1


                                                        Ybus_Zconst(ib,ib)=Ybus_Zconst(ib,ib)+1000;
                                                    else




                                                        Ybus_Zconst(ib,ib)=Ybus_Zconst(ib,ib)-conj(Sbus(ib));
                                                        if LF.bus(ib).NumberOfPhases>0
                                                            for ib1=ib:ib+LF.bus(ib).NumberOfPhases-1


                                                                Ybus_Zconst(ib1,ib1)=Ybus_Zconst(ib1,ib1)-conj(SbusSM(ib))/3;
                                                                Ybus_Zconst(ib1,ib1)=Ybus_Zconst(ib1,ib1)-conj(SbusDYN(ib))/3;
                                                                Ybus_Zconst(ib1,ib1)=Ybus_Zconst(ib1,ib1)+conj(SbusASM(ib))/3;



                                                                Ybus_Zconst(ib1,ib1)=Ybus_Zconst(ib1,ib1)-conj(SbusPN(ib1));



                                                                ib2=ib1+1;
                                                                if ib1==ib+LF.bus(ib).NumberOfPhases-1,ib2=ib;end

                                                                Ybus_Zconst(ib1,ib1)=Ybus_Zconst(ib1,ib1)-conj(SbusPP(ib1)/2);
                                                                Ybus_Zconst(ib2,ib2)=Ybus_Zconst(ib2,ib2)-conj(SbusPP(ib1)/2);
                                                            end

                                                        end
                                                    end

                                                end

                                                I=zeros(Nbus,1);
                                                I(ibSwing)=V(ibSwing)*1000;

                                                Vinit2=Ybus_Zconst\I;


                                                V(ibGen)=abs(V(ibGen)).*exp(1i*angle(Vinit2(ibGen)));

                                                V(ibLoad)=Vinit2(ibLoad);

                                                Vmag=abs(V)';Vang=angle(V)';
                                                Ymag=abs(Y);Yang=angle(Y);



                                                P=zeros(Nbus,1);Q=zeros(Nbus,1);

                                                Ibus=Ybus*V;
                                                Sg=V.*conj(Ibus);
                                                Sg1=Sg;
                                                for ib=1:Nbus

                                                    if BusType(ib)==3
                                                        P(ib)=real(Sg(ib)-Sbus(ib));
                                                        Q(ib)=imag(Sg(ib)-Sbus(ib));





                                                        if LF.bus(ib).NumberOfPhases>0
                                                            ib1=ib:ib+LF.bus(ib).NumberOfPhases-1;
                                                            if any(SbusPP(ib1))
                                                                ib2=ib1+1;ib2(end)=ib1(1);
                                                                ib3=ib1-1;ib3(1)=ib1(end);











                                                                SPP=SbusPP(ib1).*(1+V(ib2)./(V(ib1)-V(ib2)))-SbusPP(ib3).*V(ib1)./(V(ib3)-V(ib1));
                                                                P(ib1)=real(Sg(ib1)-Sbus(ib1)-SPP);
                                                                Q(ib1)=imag(Sg(ib1)-Sbus(ib1)-SPP);
                                                                Sg(ib1)=Sg(ib1)-SPP;
                                                            end

                                                            if any(SbusPN(ib1))
                                                                if length(ib1)~=3,error('phase-neutral load connected at a bus with number of phases not equal to 3');end













                                                                Vng=neutralGroundVoltage(SbusPN(ib1),V(ib1));



                                                                SPN=SbusPN(ib1).*(1+Vng./(V(ib1)-Vng));


                                                                P(ib1)=real(Sg(ib1)-Sbus(ib1)-SPN);
                                                                Q(ib1)=imag(Sg(ib1)-Sbus(ib1)-SPN);
                                                                Sg(ib1)=Sg(ib1)-SPN;
                                                            end


                                                            if any(SbusSM(ib1))


                                                                MachineNumber=LF.bus(ib).sm;
                                                                for imac=MachineNumber
                                                                    Pnom=LF.sm.pnom{imac};
                                                                    Z2=LF.sm.Z2{imac}*LF.Pbase/Pnom;
                                                                    Z2_c=conj(Z2);

                                                                    S=(LF.sm.P{imac}+1i*LF.sm.Q{imac})/LF.Pbase;

                                                                    Va=V(ib1(1));
                                                                    Vb=V(ib1(2));
                                                                    Vc=V(ib1(3));
                                                                    Va_c=conj(Va);
                                                                    Vb_c=conj(Vb);
                                                                    Vc_c=conj(Vc);

                                                                    A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                                    Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*S);
                                                                    Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*S)*a;
                                                                    Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*S)*a2;
                                                                    Sa=Na/A;
                                                                    Sb=Nb/A;
                                                                    Sc=Nc/A;
                                                                    Sabc=[Sa;Sb;Sc];

                                                                    P(ib1)=real(Sg(ib1)-Sbus(ib1)-Sabc);
                                                                    Q(ib1)=imag(Sg(ib1)-Sbus(ib1)-Sabc);
                                                                    Sg(ib1)=Sg(ib1)-Sabc;
                                                                end
                                                            end


                                                            if any(SbusASM(ib1))



                                                                MachineNumber=LF.bus(ib).asm;
                                                                for imac=MachineNumber
                                                                    Pnom=LF.asm.pnom{imac};
                                                                    Pmec=LF.asm.pmec{imac}/Pnom;
                                                                    Vnom=LF.asm.vnom{imac};
                                                                    r1=LF.asm.r1{imac};
                                                                    x1=LF.asm.x1{imac};
                                                                    r2=LF.asm.r2{imac};
                                                                    x2=LF.asm.x2{imac};
                                                                    xm=LF.asm.xm{imac};


                                                                    Vabc=V(ib1).*[LF.bus(ib1).vbase]'/(Vnom/sqrt(3));
                                                                    Sabc=unbalancedThreePhaseASM(Vabc,Pmec,r1,x1,r2,x2,xm);

                                                                    Sabc=-Sabc*Pnom/LF.Pbase;

                                                                    P(ib1)=real(Sg(ib1)-Sbus(ib1)-Sabc);
                                                                    Q(ib1)=imag(Sg(ib1)-Sbus(ib1)-Sabc);
                                                                    Sg(ib1)=Sg(ib1)-Sabc;
                                                                end
                                                            end
                                                        end

                                                    elseif BusType(ib)==2
                                                        P(ib)=real(Sg(ib)-Sbus(ib));


                                                        if LF.bus(ib).NumberOfPhases>0
                                                            ib1=ib:ib+LF.bus(ib).NumberOfPhases-1;

                                                            if any(SbusSM(ib1))


                                                                MachineNumber=LF.bus(ib).sm;
                                                                for imac=MachineNumber
                                                                    Pnom=LF.sm.pnom{imac};
                                                                    Z2=LF.sm.Z2{imac}*LF.Pbase/Pnom;
                                                                    Z2_c=conj(Z2);



                                                                    Qmac=imag(sum(Sg(ib1))-sum([LF.bus(ib1).Sref])-sum([LF.bus(ib1).SrefPP])...
                                                                    -sum([LF.bus(ib1).SrefPN])-sum([LF.bus(ib1).SrefDYN]));
                                                                    S=LF.sm.P{imac}/LF.Pbase+1i*Qmac;

                                                                    Va=V(ib1(1));
                                                                    Vb=V(ib1(2));
                                                                    Vc=V(ib1(3));
                                                                    Va_c=conj(Va);
                                                                    Vb_c=conj(Vb);
                                                                    Vc_c=conj(Vc);

                                                                    A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                                    Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*S);
                                                                    Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*S)*a;
                                                                    Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*S)*a2;
                                                                    Sa=Na/A;
                                                                    Sb=Nb/A;
                                                                    Sc=Nc/A;
                                                                    Sabc=[Sa;Sb;Sc];

                                                                    P(ib1)=real(Sg(ib1)-Sbus(ib1)-Sabc);
                                                                    Q(ib1)=imag(Sg(ib1)-Sbus(ib1)-Sabc);
                                                                    Sg(ib1)=Sg(ib1)-Sabc;



                                                                    if strcmp(LF.sm.busType{imac},'PV')
                                                                        V1ref=LF.bus(ib1(1)).vref;
                                                                        V1mag=abs(1/3*sum(V(ib1).*[1;a;a2]));
                                                                        Q(ib1)=Q(ib1)+kDeltaV1*(V1mag-V1ref);
                                                                    end

                                                                end
                                                            end
                                                        end


                                                    elseif BusType(ib)==4
                                                        P(ib)=real(Sg(ib)-Sbus(ib))/Vmag(ib);
                                                        Q(ib)=imag(Sg(ib)-Sbus(ib))/Vmag(ib);
                                                    end

                                                end

                                                PQ=[P;Q];






                                                if~isempty(BusMonitor)

                                                    val=niter;
                                                    TitleBusMonitor='#- ';
                                                    TitleBusMonito2='   ';
                                                    FormatBusMonitor='%2d';

                                                    for i=1:length(BusMonitor)
                                                        ib=strcmp(BusMonitor{i},BusIDstr);

                                                        if isempty(ib)
                                                            ErrorMessage=sprintf('-->Monitored bus %s = does not correspond to an existing bus identification ',BusMonitor{i});
                                                            return
                                                        end

                                                        str=sprintf('------V%s------ ------S%s----- ',BusMonitor{i},BusMonitor{i});
                                                        TitleBusMonitor=[TitleBusMonitor,str];%#ok
                                                        TitleBusMonito2=[TitleBusMonito2,'(pu)   (deg)   P(pu)  Q(pu)  '];%#ok
                                                        FormatBusMonitor=[FormatBusMonitor,'%6.3f %7.2f %6.3f %6.3f '];%#ok
                                                        val=[val,abs(V(ib)),angle(V(ib))*180/pi,real(Sg(ib)),imag(Sg(ib))];%#ok

                                                    end

                                                end

                                                k_VcorIconst(ibIconst)=Vmag(ibIconst);
                                                erP=abs((real(Sg(ibGenLoad)-Sbus(ibGenLoad).*k_VcorIconst(ibGenLoad))));
                                                [erPmax,i]=max(erP);
                                                iberPmax=ibGenLoad(i);

                                                if isempty(ibGenLoad)
                                                    erPmax=0;iberPmax=0;
                                                end

                                                erQ=abs((imag(Sg(ibLoad)-Sbus(ibLoad).*k_VcorIconst(ibLoad))));
                                                [erQmax,i]=max(erQ);
                                                iberQmax=ibLoad(i);

                                                if isempty(ibLoad)
                                                    erQmax=0;
                                                    iberQmax=0;
                                                end

                                                if~isempty(BusMonitor)

                                                    val=[val,erPmax,iberPmax,erQmax,iberQmax,];
                                                    TitleBusMonitor=[TitleBusMonitor,' --DPmax-- --DQmax--\n'];
                                                    TitleBusMonito2=[TitleBusMonito2,' (pu)   #  (pu)   #'];
                                                    FormatBusMonitor=[FormatBusMonitor,' %6.3f %2d %6.3f %2d\n'];

                                                    fprintf(TitleBusMonitor);
                                                    fprintf('%s\n',TitleBusMonito2);
                                                    fprintf(FormatBusMonitor,val);

                                                end



                                                for solution=1:2


                                                    if solution==1


                                                        ibGenQmin=[];
                                                        ibGenQmax=[];



                                                        indexGenLoad=[ibGenLoad,ibLoad_SMPV+Nbus];


                                                        ibGenQlimLoad=ibLoad;

                                                    else






                                                        ibGenQmin=find(BusType==2&(imag(Sg)<Qmin)');
                                                        ibGenQmax=find(BusType==2&(imag(Sg)>Qmax)');
                                                        ibGenQlimLoad=[ibLoad,ibGenQmin,ibGenQmax];
                                                        Sbus(ibGenQmin)=real(Sbus(ibGenQmin))+1i*Qmin(ibGenQmin);
                                                        Sbus(ibGenQmax)=real(Sbus(ibGenQmax))+1i*Qmax(ibGenQmax);

                                                        indexGenLoad=[ibGenLoad,ibGenQlimLoad+Nbus];
                                                        ibGenQlimLoad=[ibLoad,ibGenQmin,ibGenQmax];

                                                        if isempty(ibGenQmin)&&isempty(ibGenQmax)
                                                            break
                                                        elseif~isempty(BusMonitor)
                                                            fprintf('End of 1st series of iterations without Q limits (%d iterations)\n',niter)
                                                        end

                                                    end


                                                    erV1_max_allSM=inf;



                                                    while(erPmax>erPQ_max||erQmax>erPQ_max||erV1_max_allSM>1e-5)&&niter<niter_max

                                                        niter=niter+1;
                                                        erV1_max_allSM=0;




















                                                        for ib=1:Nbus

                                                            n=index~=ib;
                                                            ind=index(n);

                                                            if BusType(ib)==4



                                                                JacP(ib,ib)=-sum(Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                                JacP(ib,ind)=Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                                JacP(ib,ib+Nbus)=Ymag(ib,ib)*cos(Yang(ib,ib));

                                                                JacP(ib,ind+Nbus)=Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                                            else



                                                                JacP(ib,ib)=-Vmag(ib)*sum(Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                                JacP(ib,ind)=Vmag(ib)*Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                                JacP(ib,ib+Nbus)=2*Vmag(ib)*Ymag(ib,ib)*cos(Yang(ib,ib))+...
                                                                sum(Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                                JacP(ib,ind+Nbus)=Vmag(ib)*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                                            end

                                                        end


                                                        for ib=1:Nbus

                                                            n=index~=ib;
                                                            ind=index(n);

                                                            if BusType==4



                                                                JacQ(ib,ib)=sum(Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                                JacQ(ib,ind)=-Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                                JacQ(ib,ib+Nbus)=-Ymag(ib,ib).*sin(Yang(ib,ib));

                                                                JacQ(ib,ind+Nbus)=Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                                            else



                                                                JacQ(ib,ib)=Vmag(ib)*sum(Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                                JacQ(ib,ind)=-Vmag(ib)*Vmag(ind).*Ymag(ib,ind).*cos(Vang(ib)-Vang(ind)-Yang(ib,ind));



                                                                JacQ(ib,ib+Nbus)=-2*Vmag(ib)*Ymag(ib,ib).*sin(Yang(ib,ib))+...
                                                                sum(Vmag(ind).*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind)));

                                                                JacQ(ib,ind+Nbus)=Vmag(ib)*Ymag(ib,ind).*sin(Vang(ib)-Vang(ind)-Yang(ib,ind));

                                                            end

                                                        end


                                                        for ib=1:Nbus
                                                            if(LF.bus(ib).NumberOfPhases)>0

                                                                ib1=ib:ib+LF.bus(ib).NumberOfPhases-1;

                                                                if any(SbusPP(ib1))
                                                                    ib2=ib1+1;ib2(end)=ib1(1);
                                                                    ib3=ib1-1;ib3(1)=ib1(end);











                                                                    dS_dVmag1=-(SbusPP(ib1).*V(ib2).*(V(ib1)-V(ib2)).^(-2)+...
                                                                    SbusPP(ib3).*((V(ib3)-V(ib1)).^(-1)+V(ib1).*(V(ib3)-V(ib1)).^(-2))).*exp(1i*Vang(ib1).');
                                                                    dS_dVang1=dS_dVmag1./exp(1i*Vang(ib1).')*1i.*V(ib1);



                                                                    dS_dVmag2=SbusPP(ib1).*(((V(ib1)-V(ib2)).^(-1)+V(ib2).*(V(ib1)-V(ib2)).^(-2))).*exp(1i*Vang(ib2).');
                                                                    dS_dVang2=dS_dVmag2./exp(1i*Vang(ib2).')*1i.*V(ib2);



                                                                    dS_dVmag3=SbusPP(ib3).*V(ib1).*(V(ib3)-V(ib1)).^(-2).*exp(1i*Vang(ib3).');
                                                                    dS_dVang3=dS_dVmag3./exp(1i*Vang(ib3).')*1i.*V(ib3);



















                                                                    icolMat=[ib1;ib2;ib3];
                                                                    n=0;
                                                                    for ibus=ib1
                                                                        n=n+1;
                                                                        icolJac=icolMat(:,n);

                                                                        JacP(ibus,icolJac)=JacP(ibus,icolJac)-real([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                        JacP(ibus,icolJac+Nbus)=JacP(ibus,icolJac+Nbus)-real([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);


                                                                        JacQ(ibus,icolJac)=JacQ(ibus,icolJac)-imag([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                        JacQ(ibus,icolJac+Nbus)=JacQ(ibus,icolJac+Nbus)-imag([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);

                                                                    end
                                                                end


                                                                if any(SbusPN(ib1))

                                                                    ib2=ib1+1;ib2(end)=ib1(1);
                                                                    ib3=ib1-1;ib3(1)=ib1(end);


                                                                    Vng=neutralGroundVoltage(SbusPN(ib1),V(ib1));










                                                                    VPN=V(ib1)-Vng;
                                                                    IPN=conj(SbusPN(ib1)./VPN);
                                                                    ZPN=VPN./IPN;
                                                                    ZPP=(ZPN(1)*ZPN(2)+ZPN(2)*ZPN(3)+ZPN(3)*ZPN(1))./(ZPN([3,1,2]));
                                                                    IPP=(V(ib1)-V(ib2))./ZPP;
                                                                    SbusPPeq=(V(ib1)-V(ib2)).*conj(IPP);








                                                                    dS_dVmag1=-(SbusPPeq.*V(ib2).*(V(ib1)-V(ib2)).^(-2)+...
                                                                    SbusPP(ib3).*((V(ib3)-V(ib1)).^(-1)+V(ib1).*(V(ib3)-V(ib1)).^(-2))).*exp(1i*Vang(ib1).');
                                                                    dS_dVang1=dS_dVmag1./exp(1i*Vang(ib1).')*1i.*V(ib1);




                                                                    dS_dVmag2=SbusPPeq.*(((V(ib1)-V(ib2)).^(-1)+V(ib2).*(V(ib1)-V(ib2)).^(-2))).*exp(1i*Vang(ib2).');
                                                                    dS_dVang2=dS_dVmag2./exp(1i*Vang(ib2).')*1i.*V(ib2);




                                                                    dS_dVmag3=SbusPPeq([3,1,2]).*V(ib1).*(V(ib3)-V(ib1)).^(-2).*exp(1i*Vang(ib3).');
                                                                    dS_dVang3=dS_dVmag3./exp(1i*Vang(ib3).')*1i.*V(ib3);

                                                                    icolMat=[ib1;ib2;ib3];
                                                                    n=0;
                                                                    for ibus=ib1
                                                                        n=n+1;
                                                                        icolJac=icolMat(:,n);

                                                                        JacP(ibus,icolJac)=JacP(ibus,icolJac)-real([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                        JacP(ibus,icolJac+Nbus)=JacP(ibus,icolJac+Nbus)-real([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);


                                                                        JacQ(ibus,icolJac)=JacQ(ibus,icolJac)-imag([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                        JacQ(ibus,icolJac+Nbus)=JacQ(ibus,icolJac+Nbus)-imag([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);

                                                                    end

                                                                end




                                                                if~isempty(LF.bus(ib).sm)

                                                                    ib2=ib1+1;ib2(end)=ib1(1);
                                                                    ib3=ib1-1;ib3(1)=ib1(end);

                                                                    MachineNumber=LF.bus(ib).sm;
                                                                    for imac=MachineNumber
                                                                        Pnom=LF.sm.pnom{imac};
                                                                        Z2=LF.sm.Z2{imac}*LF.Pbase/Pnom;
                                                                        switch(BusType(ib))
                                                                        case 1


                                                                            S=sum(Sg1(ib1))-sum([LF.bus(ib1).Sref])-sum([LF.bus(ib1).SrefPP])-sum([LF.bus(ib1).SrefPN]);
                                                                        case 2


                                                                            Qmac=imag(sum(Sg1(ib1))-sum([LF.bus(ib1).Sref])-sum([LF.bus(ib1).SrefPP])...
                                                                            -sum([LF.bus(ib1).SrefPN])-sum([LF.bus(ib1).SrefDYN]));
                                                                            S=LF.sm.P{imac}/LF.Pbase+1i*Qmac;
                                                                        case 3


                                                                            S=(LF.sm.P{imac}+1i*LF.sm.Q{imac})/LF.Pbase;

                                                                        end










                                                                        [dS_dVmag1,dS_dVang1,dS_dVmag2,dS_dVang2,dS_dVmag3,dS_dVang3]=machinePowerDerivatives(V(ib1),Z2,S);


                                                                        icolMat=[ib1;ib2;ib3];
                                                                        n=0;
                                                                        for ibus=ib1
                                                                            n=n+1;
                                                                            icolJac=icolMat(:,n);

                                                                            JacP(ibus,icolJac)=JacP(ibus,icolJac)-real([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                            JacP(ibus,icolJac+Nbus)=JacP(ibus,icolJac+Nbus)-real([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);


                                                                            JacQ(ibus,icolJac)=JacQ(ibus,icolJac)-imag([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                            JacQ(ibus,icolJac+Nbus)=JacQ(ibus,icolJac+Nbus)-imag([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);

                                                                        end

                                                                        if strcmp(LF.sm.busType{imac},'PV')













                                                                            [dV1_dVmag1,dV1_dVang1,dV1_dVmag2,dV1_dVang2,dV1_dVmag3,dV1_dVang3]=positiveSequenceVoltageDerivatives(V(ib1));
                                                                            JacV1=zeros(1,2*Nbus);
                                                                            JacV1(ib1)=[dV1_dVang1,dV1_dVang2,dV1_dVang3];
                                                                            JacV1(ib1+Nbus)=[dV1_dVmag1,dV1_dVmag2,dV1_dVmag3];


                                                                            JacQ(ib1(1),:)=JacQ(ib1(1),:)+JacV1*kDeltaV1;
                                                                            JacQ(ib1(2),:)=JacQ(ib1(2),:)+JacV1*kDeltaV1;
                                                                            JacQ(ib1(3),:)=JacQ(ib1(3),:)+JacV1*kDeltaV1;
                                                                        end


                                                                    end
                                                                end




                                                                if~isempty(LF.bus(ib).asm)

                                                                    ib2=ib1+1;ib2(end)=ib1(1);
                                                                    ib3=ib1-1;ib3(1)=ib1(end);



                                                                    MachineNumber=LF.bus(ib).asm;
                                                                    for imac=MachineNumber
                                                                        Pnom=LF.asm.pnom{imac};
                                                                        Pmec=LF.asm.pmec{imac}/Pnom;
                                                                        Vnom=LF.asm.vnom{imac};
                                                                        r1=LF.asm.r1{imac};
                                                                        x1=LF.asm.x1{imac};
                                                                        r2=LF.asm.r2{imac};
                                                                        x2=LF.asm.x2{imac};
                                                                        xm=LF.asm.xm{imac};


                                                                        Vabc=V(ib1).*[LF.bus(ib1).vbase]'/(Vnom/sqrt(3));
                                                                        [Sabc,~,~,~,Z2]=unbalancedThreePhaseASM(Vabc,Pmec,r1,x1,r2,x2,xm);

                                                                        S=-sum(Sabc*Pnom/LF.Pbase);
                                                                        Z2=Z2*LF.Pbase/Pnom;








                                                                        [dS_dVmag1,dS_dVang1,dS_dVmag2,dS_dVang2,dS_dVmag3,dS_dVang3]=machinePowerDerivatives(V(ib1),Z2,S);


                                                                        icolMat=[ib1;ib2;ib3];
                                                                        n=0;
                                                                        for ibus=ib1
                                                                            n=n+1;
                                                                            icolJac=icolMat(:,n);

                                                                            JacP(ibus,icolJac)=JacP(ibus,icolJac)-real([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                            JacP(ibus,icolJac+Nbus)=JacP(ibus,icolJac+Nbus)-real([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);


                                                                            JacQ(ibus,icolJac)=JacQ(ibus,icolJac)-imag([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                            JacQ(ibus,icolJac+Nbus)=JacQ(ibus,icolJac+Nbus)-imag([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);

                                                                        end
                                                                    end
                                                                end



                                                                if~isempty(LF.bus(ib).pqload)

                                                                    ib2=ib1+1;ib2(end)=ib1(1);
                                                                    ib3=ib1-1;ib3(1)=ib1(end);

                                                                    Z2=1e6;
                                                                    S=SbusDYN(ib1(1));










                                                                    [dS_dVmag1,dS_dVang1,dS_dVmag2,dS_dVang2,dS_dVmag3,dS_dVang3]=machinePowerDerivatives(V(ib1),Z2,S);


                                                                    icolMat=[ib1;ib2;ib3];
                                                                    n=0;
                                                                    for ibus=ib1
                                                                        n=n+1;
                                                                        icolJac=icolMat(:,n);

                                                                        JacP(ibus,icolJac)=JacP(ibus,icolJac)-real([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                        JacP(ibus,icolJac+Nbus)=JacP(ibus,icolJac+Nbus)-real([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);


                                                                        JacQ(ibus,icolJac)=JacQ(ibus,icolJac)-imag([dS_dVang1(n),dS_dVang2(n),dS_dVang3(n)]);

                                                                        JacQ(ibus,icolJac+Nbus)=JacQ(ibus,icolJac+Nbus)-imag([dS_dVmag1(n),dS_dVmag2(n),dS_dVmag3(n)]);

                                                                    end
                                                                end



                                                            end
                                                        end

                                                        Jac=[JacP;JacQ];








                                                        DangVmagV(indexGenLoad)=-Jac(indexGenLoad,indexGenLoad)\PQ(indexGenLoad);
                                                        DangV=DangVmagV(1:Nbus);
                                                        DmagV=DangVmagV(Nbus+1:2*Nbus);


                                                        Vang=Vang+DangV';
                                                        Vmag=Vmag+DmagV';
                                                        V=Vmag'.*exp(1i*Vang');


                                                        Ibus=Ybus*V;
                                                        Sg=V.*conj(Ibus);
                                                        Sg1=Sg;



                                                        P(ibGenLoad)=real(Sg(ibGenLoad)-Sbus(ibGenLoad));



                                                        Q(ibLoad_SMPV)=imag(Sg(ibLoad_SMPV)-Sbus(ibLoad_SMPV));



                                                        P(ibIconst)=real(Sg(ibIconst)-Sbus(ibIconst).*Vmag(ibIconst)');
                                                        Q(ibIconst)=imag(Sg(ibIconst)-Sbus(ibIconst).*Vmag(ibIconst)');

                                                        for ib=1:Nbus

                                                            if LF.bus(ib).NumberOfPhases>0
                                                                ib1=ib:ib+LF.bus(ib).NumberOfPhases-1;

                                                                if any(SbusPP(ib1))
                                                                    ib2=ib1+1;ib2(end)=ib1(1);
                                                                    ib3=ib1-1;ib3(1)=ib1(end);









                                                                    kVcorPP=ones(length(ib1),1);
                                                                    kVcorPP2=ones(length(ib1),1);
                                                                    n=1;

                                                                    for ibus=ib1
                                                                        if LF.bus(ibus).TypeNumberPP==4
                                                                            kVcorPP(n)=abs(V(ib1(n))-V(ib2(n)))/sqrt(3);
                                                                            n=n+1;
                                                                        end
                                                                    end
                                                                    kVcorPP2(2:end)=kVcorPP(1:end-1);
                                                                    kVcorPP2(1)=kVcorPP(end);





                                                                    SPP=SbusPP(ib1).*kVcorPP.*(1+V(ib2)./(V(ib1)-V(ib2)))-SbusPP(ib3).*kVcorPP2.*V(ib1)./(V(ib3)-V(ib1));
                                                                    P(ib1)=P(ib1)-real(SPP);
                                                                    Q(ib1)=Q(ib1)-imag(SPP);
                                                                    Sg(ib1)=Sg(ib1)-SPP;
                                                                end


                                                                if any(SbusPN(ib1))
                                                                    if length(ib1)~=3,error('phase-neutral load connected at a bus with number of phases not equal to 3');end













                                                                    kVcorPN=ones(length(ib1),1);
                                                                    n=1;
                                                                    for ibus=ib1
                                                                        if LF.bus(ibus).TypeNumberPN==4
                                                                            kVcorPN(n)=abs(V(ib1(n)));
                                                                            n=n+1;
                                                                        end
                                                                    end


                                                                    Vng=neutralGroundVoltage(SbusPN(ib1),V(ib1));

                                                                    LF.bus(ib).Vng=Vng;





                                                                    SPN=SbusPN(ib1).*kVcorPN.*(1+Vng./(V(ib1)-Vng));
                                                                    P(ib1)=P(ib1)-real(SPN);
                                                                    Q(ib1)=Q(ib1)-imag(SPN);
                                                                    Sg(ib1)=Sg(ib1)-SPN;

                                                                end



                                                                if~isempty(LF.bus(ib).sm)


                                                                    MachineNumber=LF.bus(ib).sm;
                                                                    for imac=MachineNumber
                                                                        Pnom=LF.sm.pnom{imac};
                                                                        Z2=LF.sm.Z2{imac}*LF.Pbase/Pnom;
                                                                        Z2_c=conj(Z2);
                                                                        switch(BusType(ib))
                                                                        case 1


                                                                            S=sum(Sg1(ib1))-sum([LF.bus(ib1).Sref])-sum([LF.bus(ib1).SrefPP])-sum([LF.bus(ib1).SrefPN]);
                                                                        case 2


                                                                            Qmac=imag(sum(Sg1(ib1))-sum([LF.bus(ib1).Sref])-sum([LF.bus(ib1).SrefPP])...
                                                                            -sum([LF.bus(ib1).SrefPN])-sum([LF.bus(ib1).SrefDYN]));
                                                                            S=LF.sm.P{imac}/LF.Pbase+1i*Qmac;
                                                                        case 3


                                                                            S=(LF.sm.P{imac}+1i*LF.sm.Q{imac})/LF.Pbase;
                                                                        end

                                                                        Va=V(ib1(1));
                                                                        Vb=V(ib1(2));
                                                                        Vc=V(ib1(3));
                                                                        Va_c=conj(Va);
                                                                        Vb_c=conj(Vb);
                                                                        Vc_c=conj(Vc);

                                                                        A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                                        Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*S);
                                                                        Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*S)*a;
                                                                        Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*S)*a2;
                                                                        Sa=Na/A;
                                                                        Sb=Nb/A;
                                                                        Sc=Nc/A;
                                                                        Sabc=[Sa;Sb;Sc];

                                                                        P(ib1)=P(ib1)-real(Sabc);
                                                                        Q(ib1)=Q(ib1)-imag(Sabc);
                                                                        Sg(ib1)=Sg(ib1)-Sabc;



                                                                        if strcmp(LF.sm.busType{imac},'PV')
                                                                            V1ref=LF.bus(ib1(1)).vref;
                                                                            V1mag=abs(1/3*sum(V(ib1).*[1;a;a2]));
                                                                            Q(ib1)=Q(ib1)+kDeltaV1*(V1mag-V1ref);
                                                                            erV1=(V1mag-V1ref)/V1ref;
                                                                            if abs(erV1)>erV1_max_allSM
                                                                                erV1_max_allSM=abs(erV1);
                                                                            end
                                                                        end


                                                                    end
                                                                end



                                                                if~isempty(LF.bus(ib).asm)



                                                                    MachineNumber=LF.bus(ib).asm;
                                                                    for imac=MachineNumber
                                                                        Pnom=LF.asm.pnom{imac};
                                                                        Pmec=LF.asm.pmec{imac}/Pnom;
                                                                        Vnom=LF.asm.vnom{imac};
                                                                        r1=LF.asm.r1{imac};
                                                                        x1=LF.asm.x1{imac};
                                                                        r2=LF.asm.r2{imac};
                                                                        x2=LF.asm.x2{imac};
                                                                        xm=LF.asm.xm{imac};


                                                                        Vabc=V(ib1).*[LF.bus(ib1).vbase]'/(Vnom/sqrt(3));
                                                                        Sabc=unbalancedThreePhaseASM(Vabc,Pmec,r1,x1,r2,x2,xm);

                                                                        Sabc=-Sabc*Pnom/LF.Pbase;

                                                                        P(ib1)=P(ib1)-real(Sabc);
                                                                        Q(ib1)=Q(ib1)-imag(Sabc);
                                                                        Sg(ib1)=Sg(ib1)-Sabc;
                                                                    end
                                                                end



                                                                if~isempty(LF.bus(ib).pqload)


                                                                    Z2_c=1e6;
                                                                    S=SbusDYN(ib1(1));
                                                                    Va=V(ib1(1));
                                                                    Vb=V(ib1(2));
                                                                    Vc=V(ib1(3));
                                                                    Va_c=conj(Va);
                                                                    Vb_c=conj(Vb);
                                                                    Vc_c=conj(Vc);

                                                                    A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                                    Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-3i*sqrt(3)*Z2_c*S);
                                                                    Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-3i*sqrt(3)*Z2_c*S)*a;
                                                                    Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-3i*sqrt(3)*Z2_c*S)*a2;
                                                                    Sa=Na/A;
                                                                    Sb=Nb/A;
                                                                    Sc=Nc/A;
                                                                    Sabc=[Sa;Sb;Sc];

                                                                    P(ib1)=P(ib1)-real(Sabc);
                                                                    Q(ib1)=Q(ib1)-imag(Sabc);
                                                                    Sg(ib1)=Sg(ib1)-Sabc;
                                                                end

                                                            end
                                                        end


                                                        PQ=[P;Q];








                                                        val=niter;

                                                        for i=1:length(BusMonitor)
                                                            ib=strcmp(BusMonitor(i),BusIDstr);
                                                            val=[val,abs(V(ib)),angle(V(ib))*180/pi,real(Sg(ib)),imag(Sg(ib))];%#ok
                                                        end

                                                        k_VcorIconst(ibIconst)=Vmag(ibIconst);

                                                        erP=abs((real(Sg(ibGenLoad)-Sbus(ibGenLoad).*k_VcorIconst(ibGenLoad))));
                                                        [erPmax,i]=max(erP);
                                                        iberPmax=ibGenLoad(i);


                                                        if~isempty(ibGenQlimLoad)


                                                            erQ=abs((imag(Sg(ibGenQlimLoad)-Sbus(ibGenQlimLoad).*k_VcorIconst(ibGenQlimLoad))));
                                                            [erQmax,i]=max(erQ);

                                                            iberQmax=ibGenQlimLoad(i);

                                                        else

                                                            erQmax=0;
                                                            iberQmax=0;

                                                        end

                                                        if~isempty(BusMonitor)
                                                            val=[val,erPmax,iberPmax,erQmax,iberQmax];%#ok
                                                            fprintf(FormatBusMonitor,val);
                                                        end

                                                    end


                                                    if solution==1
                                                        erPmax=inf;
                                                    end

                                                end



                                                Ibus=Ybus*V;
                                                Sg=V.*conj(Ibus);





                                                Vbus=zeros(Nbus1,1);
                                                Vbus(nbus_select)=V;
                                                Sbus=zeros(Nbus1,1);
                                                Sbus(nbus_select)=Sg;
                                                ibGenQmin=nbus_select(ibGenQmin);
                                                ibGenQmax=nbus_select(ibGenQmax);

                                                for ibus=1:Nbus1
                                                    LF.bus(ibus).Vbus=Vbus(ibus);
                                                    LF.bus(ibus).Sbus=Sbus(ibus);
                                                end

                                                LF.ibGenQmin=ibGenQmin;
                                                LF.ibGenQmax=ibGenQmax;
                                                function[node_numbers,subnet_numbers,nb_subnetworks]=getUnbalancedSubnetworks(LF)















                                                    Ybus=(LF.Ybus);
                                                    Nbus=size(Ybus,1);



                                                    for iblock=1:length(LF.rlcload.blockType)

                                                        if any(isnan(LF.rlcload.busNumber{iblock}))
                                                        else

                                                            switch LF.rlcload.blockType{iblock}
                                                            case 'RLC load'
                                                                Ybus(LF.rlcload.busNumber{iblock}(1),LF.rlcload.busNumber{iblock}(2))=1;
                                                                Ybus(LF.rlcload.busNumber{iblock}(2),LF.rlcload.busNumber{iblock}(3))=1;
                                                            case 'RLC load 1ph'
                                                                if length(LF.rlcload.busNumber{iblock})==2
                                                                    Ybus(LF.rlcload.busNumber{iblock}(1),LF.rlcload.busNumber{iblock}(2))=1;
                                                                else
                                                                    for iblock2=1:length(LF.rlcload.blockType)
                                                                        if strcmp(LF.rlcload.blockType{iblock2},'RLC load 1ph')&&length(LF.rlcload.busNumber{iblock2})==1&&iblock2~=iblock

                                                                            if isnan(LF.rlcload.busNumber{iblock})||isnan(LF.rlcload.busNumber{iblock2})
                                                                            else
                                                                                if strcmp(LF.bus(LF.rlcload.busNumber{iblock}).ID(1:end-2),LF.bus(LF.rlcload.busNumber{iblock2}).ID(1:end-2))
                                                                                    Ybus(LF.rlcload.busNumber{iblock},LF.rlcload.busNumber{iblock2})=1;
                                                                                end
                                                                            end

                                                                        end
                                                                    end
                                                                end
                                                            end

                                                        end

                                                    end




                                                    node_mat=zeros(0,2);
                                                    nbranch=0;

                                                    for node1=1:Nbus

                                                        nbranch=nbranch+1;


                                                        node_mat(nbranch,:)=[node1,node1+10000];

                                                        for node2=node1+1:Nbus

                                                            if Ybus(node1,node2)~=0

                                                                nbranch=nbranch+1;
                                                                node_mat(nbranch,:)=[node1,node2];
                                                            end

                                                        end

                                                    end







                                                    if isempty(node_mat)
                                                        return
                                                    end

                                                    node_mat=node_mat(:,1:2);

                                                    node_numbers=-123456;
                                                    subnet_numbers=[];
                                                    indres=1;

                                                    for i=1:size(node_mat,1)

                                                        if isempty(find(node_mat(i,1)==node_numbers,1))&&isempty(find(node_mat(i,2)==node_numbers,1))

                                                            if i==1
                                                                node_numbers=[];
                                                            end

                                                            ww=node_mat(i,:);
                                                            wwold=[];

                                                            while length(ww)>length(wwold)

                                                                wwold=ww;

                                                                for j=1:size(node_mat,1)


                                                                    if~isempty(find(ww==node_mat(j,1),1))

                                                                        if isempty(find(ww==node_mat(j,2),1))

                                                                            ww=[ww,node_mat(j,2)];%#ok
                                                                        end
                                                                    end


                                                                    if~isempty(find(ww==node_mat(j,2),1))

                                                                        if isempty(find(ww==node_mat(j,1),1))

                                                                            ww=[ww,node_mat(j,1)];%#ok
                                                                        end
                                                                    end

                                                                end

                                                            end

                                                            node_numbers=[node_numbers,ww];%#ok
                                                            subnet_numbers=[subnet_numbers,indres*ones(1,length(ww))];%#ok
                                                            indres=indres+1;


                                                        end

                                                    end

                                                    nb_subnetworks=indres-1;
                                                    function[Vng]=neutralGroundVoltage(SPN,VPG)




                                                        ib1=[1,2,3];
                                                        ib2=[2,3,1];
                                                        ib3=[3,1,2];









                                                        Ssum=sum(SPN(ib1));
                                                        a=sum(VPG(ib1).*(Ssum-SPN(ib1)));
                                                        b=(sum(((SPN(ib1).*VPG(ib2)+SPN(ib2).*VPG(ib1)).^2...
                                                        -2*VPG(ib1).*VPG(ib2).*SPN(ib3)*Ssum...
                                                        +2*SPN(ib1).*SPN(ib2).*VPG(ib3).^2)))^0.5;

                                                        Vng1=(a+b)/2/Ssum;


                                                        Vng=Vng1;
                                                        function[dS_dVmag1,dS_dVang1,dS_dVmag2,dS_dVang2,dS_dVmag3,dS_dVang3]=machinePowerDerivatives(V,Z2,S)




















                                                            Va=V(1);
                                                            Vb=V(2);
                                                            Vc=V(3);
                                                            Va_c=conj(Va);
                                                            Vb_c=conj(Vb);
                                                            Vc_c=conj(Vc);
                                                            Vanga=angle(Va);
                                                            Vangb=angle(Vb);
                                                            Vangc=angle(Vc);

                                                            a=exp(1i*2*pi/3);
                                                            a2=a*a;
                                                            Z2_c=conj(Z2);
                                                            k_Z2_S=3i*sqrt(3)*Z2_c*S;

                                                            A=Z2_c*(a2*(Va-Vb)+(Vb-Vc)+a*(Vc-Va));
                                                            Na=Va/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-k_Z2_S);
                                                            Nb=Vb/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-k_Z2_S)*a;
                                                            Nc=Vc/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-k_Z2_S)*a2;






                                                            dNa_dVmaga=1/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-k_Z2_S)*exp(1i*Vanga)+1/3*Va*(-(Vb-Vc))*exp(-1i*Vanga);
                                                            dNb_dVmagb=1/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-k_Z2_S)*a*exp(1i*Vangb)+1/3*Vb*(-(Vc-Va))*a*exp(-1i*Vangb);
                                                            dNc_dVmagc=1/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-k_Z2_S)*a2*exp(1i*Vangc)+1/3*Vc*(-(Va-Vb))*a2*exp(-1i*Vangc);

                                                            dA_dVmaga=Z2_c*(a2-a)*exp(1i*Vanga);
                                                            dA_dVmagb=Z2_c*(-a2+1)*exp(1i*Vangb);
                                                            dA_dVmagc=Z2_c*(-1+a)*exp(1i*Vangc);

                                                            dSa_dVmaga=(dNa_dVmaga*A-dA_dVmaga*Na)/A^2;
                                                            dSb_dVmagb=(dNb_dVmagb*A-dA_dVmagb*Nb)/A^2;
                                                            dSc_dVmagc=(dNc_dVmagc*A-dA_dVmagc*Nc)/A^2;

                                                            dS_dVmag1=[dSa_dVmaga;dSb_dVmagb;dSc_dVmagc];


                                                            dNa_dVanga=1/3*(-(Vb-Vc)*(Va_c+a*Vb_c+a2*Vc_c)-k_Z2_S)*1i*Va+1/3*Va*(-(Vb-Vc))*-1i*Va_c;
                                                            dNb_dVangb=1/3*(-(Vc-Va)*(Vb_c+a*Vc_c+a2*Va_c)-k_Z2_S)*a*1i*Vb+1/3*Vb*(-(Vc-Va))*a*-1i*Vb_c;
                                                            dNc_dVangc=1/3*(-(Va-Vb)*(Vc_c+a*Va_c+a2*Vb_c)-k_Z2_S)*a2*1i*Vc+1/3*Vc*(-(Va-Vb))*a2*-1i*Vc_c;

                                                            dA_dVanga=Z2_c*(a2-a)*1i*Va;
                                                            dA_dVangb=Z2_c*(-a2+1)*1i*Vb;
                                                            dA_dVangc=Z2_c*(-1+a)*1i*Vc;

                                                            dSa_dVanga=(dNa_dVanga*A-dA_dVanga*Na)/A^2;
                                                            dSb_dVangb=(dNb_dVangb*A-dA_dVangb*Nb)/A^2;
                                                            dSc_dVangc=(dNc_dVangc*A-dA_dVangc*Nc)/A^2;

                                                            dS_dVang1=[dSa_dVanga;dSb_dVangb;dSc_dVangc];


                                                            dNa_dVmagb=-1/3*Va*(Va_c+a*Vb_c+a2*Vc_c)*exp(1i*Vangb)+1/3*Va*(-(Vb-Vc))*a*exp(-1i*Vangb);
                                                            dNb_dVmagc=-1/3*Vb*(Vb_c+a*Vc_c+a2*Va_c)*exp(1i*Vangc)*a+1/3*Vb*(-(Vc-Va))*a*exp(-1i*Vangc)*a;
                                                            dNc_dVmaga=-1/3*Vc*(Vc_c+a*Va_c+a2*Vb_c)*exp(1i*Vanga)*a2+1/3*Vc*(-(Va-Vb))*a*exp(-1i*Vanga)*a2;

                                                            dSa_dVmagb=(dNa_dVmagb*A-dA_dVmagb*Na)/A^2;
                                                            dSb_dVmagc=(dNb_dVmagc*A-dA_dVmagc*Nb)/A^2;
                                                            dSc_dVmaga=(dNc_dVmaga*A-dA_dVmaga*Nc)/A^2;

                                                            dS_dVmag2=[dSa_dVmagb;dSb_dVmagc;dSc_dVmaga];


                                                            dNa_dVangb=-1/3*Va*(Va_c+a*Vb_c+a2*Vc_c)*1i*Vb+1/3*Va*(-(Vb-Vc))*a*-1i*Vb_c;
                                                            dNb_dVangc=-1/3*Vb*(Vb_c+a*Vc_c+a2*Va_c)*1i*Vc*a+1/3*Vb*(-(Vc-Va))*a*-1i*Vc_c*a;
                                                            dNc_dVanga=-1/3*Vc*(Vc_c+a*Va_c+a2*Vb_c)*1i*Va*a2+1/3*Vc*(-(Va-Vb))*a*-1i*Va_c*a2;

                                                            dSa_dVangb=(dNa_dVangb*A-dA_dVangb*Na)/A^2;
                                                            dSb_dVangc=(dNb_dVangc*A-dA_dVangc*Nb)/A^2;
                                                            dSc_dVanga=(dNc_dVanga*A-dA_dVanga*Nc)/A^2;

                                                            dS_dVang2=[dSa_dVangb;dSb_dVangc;dSc_dVanga];


                                                            dNa_dVmagc=1/3*Va*(Va_c+a*Vb_c+a2*Vc_c)*exp(1i*Vangc)+1/3*Va*(-(Vb-Vc))*a2*exp(-1i*Vangc);
                                                            dNb_dVmaga=1/3*Vb*(Vb_c+a*Vc_c+a2*Va_c)*exp(1i*Vanga)*a+1/3*Vb*(-(Vc-Va))*a2*exp(-1i*Vanga)*a;
                                                            dNc_dVmagb=1/3*Vc*(Vc_c+a*Va_c+a2*Vb_c)*exp(1i*Vangb)*a2+1/3*Vc*(-(Va-Vb))*a2*exp(-1i*Vangb)*a2;

                                                            dSa_dVmagc=(dNa_dVmagc*A-dA_dVmagc*Na)/A^2;
                                                            dSb_dVmaga=(dNb_dVmaga*A-dA_dVmaga*Nb)/A^2;
                                                            dSc_dVmagb=(dNc_dVmagb*A-dA_dVmagb*Nc)/A^2;

                                                            dS_dVmag3=[dSa_dVmagc;dSb_dVmaga;dSc_dVmagb];


                                                            dNa_dVangc=1/3*Va*(Va_c+a*Vb_c+a2*Vc_c)*1i*Vc+1/3*Va*(-(Vb-Vc))*a2*-1i*Vc_c;
                                                            dNb_dVanga=1/3*Vb*(Vb_c+a*Vc_c+a2*Va_c)*1i*Va*a+1/3*Vb*(-(Vc-Va))*a2*-1i*Va_c*a;
                                                            dNc_dVangb=1/3*Vc*(Vc_c+a*Va_c+a2*Vb_c)*1i*Vb*a2+1/3*Vc*(-(Va-Vb))*a2*-1i*Vb_c*a2;

                                                            dSa_dVangc=(dNa_dVangc*A-dA_dVangc*Na)/A^2;
                                                            dSb_dVanga=(dNb_dVanga*A-dA_dVanga*Nb)/A^2;
                                                            dSc_dVangb=(dNc_dVangb*A-dA_dVangb*Nc)/A^2;

                                                            dS_dVang3=[dSa_dVangc;dSb_dVanga;dSc_dVangb];
                                                            function[dV1_dVmag1,dV1_dVang1,dV1_dVmag2,dV1_dVang2,dV1_dVmag3,dV1_dVang3]=positiveSequenceVoltageDerivatives(V)





















                                                                Va=V(1);
                                                                Vb=V(2);
                                                                Vc=V(3);
                                                                Vmaga=abs(Va);
                                                                Vmagb=abs(Vb);
                                                                Vmagc=abs(Vc);
                                                                Vanga=angle(Va);
                                                                Vangb=angle(Vb);
                                                                Vangc=angle(Vc);

                                                                a=exp(1i*2*pi/3);
                                                                a2=a*a;
                                                                sq3=sqrt(3);

                                                                V1=1/3*(Va+a*Vb+a2*Vc);
                                                                R=real(V1);
                                                                I=imag(V1);
                                                                V1_mag=abs(V1);

                                                                dV1_dVmag1=1/V1_mag*(R*cos(Vanga)+I*sin(Vanga))/3;
                                                                dV1_dVmag2=1/V1_mag/2*(R*(-cos(Vangb)-sq3*sin(Vangb))+I*(sq3*cos(Vangb)-sin(Vangb)))/3;
                                                                dV1_dVmag3=1/V1_mag/2*(R*(-cos(Vangc)+sq3*sin(Vangc))+I*(-sq3*cos(Vangc)-sin(Vangc)))/3;

                                                                dV1_dVang1=1/V1_mag*Vmaga*(R*-sin(Vanga)+I*cos(Vanga))/3;
                                                                dV1_dVang2=1/V1_mag/2*Vmagb*(R*(sin(Vangb)-sq3*cos(Vangb))+I*(-sq3*sin(Vangb)-cos(Vangb)))/3;
                                                                dV1_dVang3=1/V1_mag/2*Vmagc*(R*(sin(Vangc)+sq3*cos(Vangc))+I*(sq3*sin(Vangc)-cos(Vangc)))/3;