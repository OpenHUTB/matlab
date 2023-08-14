function varargout=power_analyze_prv(varargin)







    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_analyze'));
    end


    narginchk(1,3);

    switch nargin

    case 1
        sys=varargin{1};
        options='version 3';
        X0Sw=[];

    case 2
        sys=varargin{1};
        options=varargin{2};
        X0Sw=[];

        switch options

        case 'V2'

            warning('SpecializedPowerSystems:PowerAnalyze:ObsoleteInputArgument','The power2sys command is obsolete.');
            options='version 3';

        case{'n','o'}

            warning('SpecializedPowerSystems:PowerAnalyze:ObsoleteInputArgument','Use of ''%s'' option in power_analyze function is obsolete. Use the ''net'' option to generate a netlist.',options);
            options='net';

        case 'setSwitchStatus'

            narginchk(3,3);
        end

    case 3

        sys=varargin{1};
        options=varargin{2};
        switch options
        case 'setSwitchStatus'
            X0Sw=varargin{3};
        otherwise
            narginchk(1,2);
        end

    end

    switch options
    case 'net'
        nargoutchk(0,0);
    end

    if exist(sys,'file')~=4
        Erreur.identifier='SpecializedPowerSystems:PowerAnalyze:ModelNotFound';
        Erreur.message=['There is no system named ''',sys,''' to open.'];
        psberror(Erreur);
    end

    if~bdIsLoaded(sys)
        open_system(sys);
    end




    warnstate=warning;
    warning('off','Simulink:Engine:UsingDiscreteSolver')
    warning('off','Simulink:Engine:UsingDefaultMaxStepSize')
    c=onCleanup(@()warning(warnstate));


    powersysdomain_netlist('clear',2);


    BLOCKLIST=powersysdomain_netlist('SPSnetlist',sys);


    PowerguiInfo.EchoMessage=0;
    internalSPS=powersolve(sys,options,PowerguiInfo,BLOCKLIST,X0Sw);




    for i=1:size(internalSPS.outstr,1)-1
        followingMeasure=internalSPS.outstr(i+1,1:end);
        if length(followingMeasure)>5
            switch followingMeasure(1:6)
            case 'Delta0'

                internalSPS.yss(i)=internalSPS.yss(i)+internalSPS.yss(i+1);
            end
        end
    end


    if isempty(internalSPS.srcstr)
        internalSPS.B=[];
        internalSPS.D=[];
        internalSPS.Bdiscrete=[];
        internalSPS.Ddiscrete=[];
    end





    switch options

    case 'getSwitchStatus'

        SPS.SwitchNames=internalSPS.SwitchNames';
        if internalSPS.PowerguiInfo.SPID
            SPS.SwitchStatus=internalSPS.SwitchGateInitialValue';
        else
            SPS.SwitchStatus=internalSPS.switches(:,3);
        end
        varargout={SPS};

    case 'sort'

        nargoutchk(0,1);




        SPS.Circuit=internalSPS.circuit;
        SPS.SampleTime=internalSPS.PowerguiInfo.Ts;
        SPS.RlcBranch=internalSPS.rlc;
        SPS.RlcBranchNames=internalSPS.rlcnames;
        SPS.SourceBranch=internalSPS.source;
        SPS.SourceBranchNames=internalSPS.sourcenames;
        SPS.InputNames=internalSPS.srcstr;
        SPS.OutputNames=internalSPS.outstr;
        SPS.OutputExpressions=internalSPS.yout;
        SPS.OutputMatrix=internalSPS.Outputs;
        SPS.MeasurementBlocks=internalSPS.measurenames;
        SPS.IdealSwitch=internalSPS.IdealSwitch;
        SPS.Breaker=internalSPS.Breaker;
        SPS.Diode=internalSPS.Diode;
        SPS.Thyristor=internalSPS.Thyristors;
        SPS.GTO=internalSPS.GTO;
        SPS.Mosfet=internalSPS.MOSFET;
        SPS.IGBT=internalSPS.IGBT;
        SPS.SimplifiedSyncMach=internalSPS.nbmodels(13);
        SPS.SynchronousMach=internalSPS.nbmodels(14);
        SPS.AsynchronousMach=internalSPS.nbmodels(15);
        SPS.PMSynchronousMach=internalSPS.nbmodels(16);
        SPS.SurgeArrestor=internalSPS.nbmodels(17);
        SPS.SaturableTransformer=internalSPS.nbmodels(18);
        SPS.DistributedParamLine=internalSPS.DistributedParameterLine;
        SPS.ImpedanceMeasurement=internalSPS.nbmodels(20);


        srcbranchblockhandles=SPS.SourceBranchNames;
        if numel(srcbranchblockhandles)>1
            SPS.SourceBranchNames=replace(unique(getfullname(srcbranchblockhandles)),newline,' ');
        elseif numel(srcbranchblockhandles)==1
            SPS.SourceBranchNames=replace(getfullname(srcbranchblockhandles),newline,' ');
        end
        varargout={SPS};

    case 'ss'

        nargoutchk(0,1);


        if~exist('ss/ss','file')
            Erreur.identifier='SpecializedPowerSystems:PowerAnalyze:CST';
            Erreur.message='Cannot find path to the SS function of the Control System Toolbox.';
            psberror(Erreur);
        end

        if internalSPS.PowerguiInfo.Discrete
            SPS=ss(internalSPS.Adiscrete,internalSPS.Bdiscrete,internalSPS.Cdiscrete,internalSPS.Ddiscrete);
            SPS.Ts=internalSPS.PowerguiInfo.Ts;
        else
            SPS=ss(internalSPS.A,internalSPS.B,internalSPS.C,internalSPS.D);
        end

        for i=1:size(internalSPS.srcstr,1);
            SPS.InputName{i,1}=strrep(internalSPS.srcstr{i},char(10),' ');
        end

        for i=1:size(internalSPS.outstr,1)
            SPS.Outputname{i,1}=strrep(deblank(internalSPS.outstr(i,:)),char(10),' ');
        end

        SPS.StateName=internalSPS.IndependentStates;
        SPS.notes=['This is the state-space representation of the ',internalSPS.circuit,' circuit.'];

        varargout={SPS};


    case 'structure'




        nargoutchk(0,1);

        SPS.circuit=internalSPS.circuit;
        SPS.states=internalSPS.IndependentStates;
        SPS.inputs=internalSPS.srcstr;
        SPS.outputs=internalSPS.yout;
        SPS.A=internalSPS.A;
        SPS.B=internalSPS.B;
        SPS.C=internalSPS.C;
        SPS.D=internalSPS.D;
        SPS.x0=internalSPS.x0;
        SPS.xss=internalSPS.xss;
        SPS.uss=internalSPS.uss;
        SPS.yss=internalSPS.yss;
        SPS.frequencies=internalSPS.freq;
        SPS.DependentStates=internalSPS.DependentStates;
        SPS.x0DependentStates=internalSPS.x0DependentStates;
        SPS.xssDependentStates=internalSPS.xssDependentStates;
        SPS.Adiscrete=internalSPS.Adiscrete;
        SPS.Bdiscrete=internalSPS.Bdiscrete;
        SPS.Cdiscrete=internalSPS.Cdiscrete;
        SPS.Ddiscrete=internalSPS.Ddiscrete;
        SPS.x0discrete=internalSPS.x0discrete;
        SPS.SampleTime=internalSPS.PowerguiInfo.Ts;
        SPS.Aswitch=internalSPS.Aswitch;
        SPS.Bswitch=internalSPS.Bswitch;
        SPS.Cswitch=internalSPS.Cswitch;
        SPS.Dswitch=internalSPS.Dswitch;
        SPS.x0switch=internalSPS.x0switch;
        SPS.Hlin=internalSPS.Hlin;
        SPS.OscillatoryModes=OscillatoryModes(internalSPS);

        varargout={SPS};

    case 'setSwitchStatus'




        nargoutchk(0,1);

        SPS.A=internalSPS.Aswitch;
        SPS.B=internalSPS.Bswitch;
        SPS.C=internalSPS.Cswitch;
        SPS.D=internalSPS.Dswitch;
        SPS.x0=internalSPS.x0switch;

        varargout={SPS};

    case 'detailed'

        nargoutchk(0,1);

        internalSPS.sourcenames=getfullname(internalSPS.sourcenames);
        internalSPS.OscillatoryModes=OscillatoryModes(internalSPS);

        varargout={internalSPS};

    case 'net'

        nargoutchk(0,0);

    case 'GetLoadFlowData'



        LF.model=sys;
        LF.powergui=internalSPS.PowerguiInfo.BlockName;
        LF.status=0;
        LF.sm=internalSPS.LoadFlow.sm;
        LF.asm=internalSPS.LoadFlow.asm;
        LF.pqload=internalSPS.LoadFlow.pqload;
        LF.vsrc=internalSPS.LoadFlow.vsrc;
        LF.rlcload=internalSPS.LoadFlow.rlcload;
        LF.xfo=internalSPS.LoadFlow.xfo;
        LF.Lines=internalSPS.LoadFlow.Lines;
        LF.bus=internalSPS.LoadFlow.bus;
        LF.H=internalSPS.LoadFlow.H;
        LF.VoltageRatio=internalSPS.LoadFlow.VoltageRatio;
        LF.freq=internalSPS.LoadFlow.freq;
        LF.Pbase=internalSPS.LoadFlow.Pbase;
        LF.ErrMax=internalSPS.LoadFlow.ErrMax;
        LF.Iterations=internalSPS.LoadFlow.Iterations;
        LF.error=internalSPS.LoadFlow.error;


        varargout={LF};

    case 'GetUnbalancedLoadFlowData'



        LF.model=sys;
        LF.powergui=internalSPS.PowerguiInfo.BlockName;
        LF.status=0;
        LF.sm=internalSPS.UnbalancedLoadFlow.sm;
        LF.asm=internalSPS.UnbalancedLoadFlow.asm;
        LF.pqload=internalSPS.UnbalancedLoadFlow.pqload;
        LF.vsrc=internalSPS.UnbalancedLoadFlow.vsrc;
        LF.rlcload=internalSPS.UnbalancedLoadFlow.rlcload;

        LF.Transfos=internalSPS.UnbalancedLoadFlow.Transfos;
        LF.Lines=internalSPS.UnbalancedLoadFlow.Lines;
        LF.bus=internalSPS.UnbalancedLoadFlow.bus;
        LF.H=internalSPS.UnbalancedLoadFlow.H;

        LF.freq=internalSPS.UnbalancedLoadFlow.freq;
        LF.Pbase=internalSPS.UnbalancedLoadFlow.Pbase;
        LF.ErrMax=internalSPS.UnbalancedLoadFlow.ErrMax;
        LF.Iterations=internalSPS.UnbalancedLoadFlow.Iterations;
        LF.error=internalSPS.UnbalancedLoadFlow.error;


        varargout={LF};

    otherwise

        nargoutchk(0,13);



        varargout(1)={internalSPS.A};
        varargout(2)={internalSPS.B};
        varargout(3)={internalSPS.C};
        varargout(4)={internalSPS.D};
        varargout(5)={internalSPS.x0};
        varargout(6)={internalSPS.states};
        varargout(7)={internalSPS.srcstr};
        varargout(8)={internalSPS.outstr};
        varargout(9)={internalSPS.uss};
        varargout(10)={internalSPS.xss};
        varargout(11)={internalSPS.yss};
        varargout(12)={internalSPS.freq};
        varargout(13)={internalSPS.Hlin};

    end




    function OM=OscillatoryModes(SPS)

        valp=eig(SPS.A);
        [~,i]=sort(imag(valp));
        valp=valp(i);
        OM=sprintf('Oscillatory modes and damping factors:\n');
        for i=1:size(SPS.A,1)

            if imag(valp(i))>0,
                fmode=imag(valp(i))/2/pi;
                zeta=-real(valp(i))/abs(valp(i));
                OM=char(OM,sprintf('f = %8g Hz    zeta = %8g',fmode,zeta));
            end
        end
