function out=DaeSolver(flag,varargin)










































    persistent SOLVER EQNS

    out=[];

    switch flag

    case 'config'
        [SOLVER,config_backdoor]=Simulink.Solver.internal.strictdeal(varargin{:});
        if ischar(SOLVER)
            SOLVER=str2func(SOLVER);
        end

        isSupported=...
        contains(func2str(SOLVER),'daessc','IgnoreCase',true)||...
        contains(func2str(SOLVER),'ode15s','IgnoreCase',true);
        if isSupported
            SOLVER(flag,config_backdoor);
        end
        SOLVER('restart');

    case 'restart'
        SOLVER(flag);

    case 'reset'
        [eqns,t0,x0,xp0]=Simulink.Solver.internal.strictdeal(varargin{:});
        out=SOLVER(flag,eqns,t0,x0,xp0);
        EQNS=eqns;

    case 'step'
        tstop=varargin{:};
        xwrapped=EQNS.applyStateRangeReduction(SOLVER('x'));
        out=SOLVER(flag,tstop,xwrapped);

    case 't'
        out=SOLVER(flag);

    case 'x'
        out=SOLVER(flag);

    case 'h'
        out=SOLVER(flag);

    case 'hNext'
        assert(false,'Method ''%s'' is currently not supported',flag);

    case 'hRecommended'
        [hrec,override_hnext]=Simulink.Solver.internal.strictdeal(varargin{:});

        isSupported=...
        contains(func2str(SOLVER),'daessc','IgnoreCase',true)||...
        contains(func2str(SOLVER),'ode15s','IgnoreCase',true);
        if isSupported
            SOLVER(flag,hrec,override_hnext);
        end

    case 'interp'
        ti=varargin{:};
        out=SOLVER(flag,ti);

    otherwise
        assert(false,'Unrecognized method name: ''%s''',flag);

    end

end
