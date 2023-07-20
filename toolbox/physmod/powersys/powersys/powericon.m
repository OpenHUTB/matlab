function varargout=powericon(varargin);%#ok





    if nargin==0
        disp('POWERICON is a gateway function used by Specialized Power Systems to access its private directory.');
        return
    end

    switch varargin{1}


    case{'Series RLC Branch',...
        'Series RLC Load',...
        'Parallel RLC Branch',...
        'Parallel RLC Load',...
        'Mutual Inductance',...
        'Linear Transformer',...
        'Saturable Transformer',...
        'PM Synchronous Machine',...
        'Asynchronous Machine',...
        'Distributed Parameters Line',...
        'Breaker',...
        'PowerSwitch',...
        'Bus Bar',...
        '3-phase inductive source - Ungrounded neutral',...
        '3-phase RL  positive & zero-sequence impedance',...
        '3-phase RLC series element',...
        '3-phase parallel RLC element',...
        '3-phase series RLC load',...
        '3-phase parallel RLC load',...
        'Three-phase Linear Transformer 12-terminals',...
        'Three-Phase Fault',...
        'Three-Phase Breaker',...
        'Three-phase transmission line pi-section'}


        if(power_initmask()==false)
            varargout(1:nargout)={0};
            return
        else
            [varargout{1:nargout}]=blocicon(varargin);
        end

        return

    case 'STG Model'
        [varargout{1:nargout}]=psbstginit(varargin{2:12});

        errorFlag=varargout{8};
        massNumber=varargout{11};

        Erreur.identifier='SpecializedPowerSystems:SteamTrubineBlock:InvalidParameters';

        switch errorFlag
        case 1
            Erreur.message='Torque fractions total (gen.A)  is not 1 p.u.';
            psberror(Erreur);
        case 3
            Erreur.message='You requested the multi-mass shaft but set all mass inertia constants to zero. Please use the single-mass option.';
            psberror(Erreur);
        case 4
            Erreur.message=['Inconsistent mass inertias and power fractions. Mass #',...
            num2str(massNumber),' has inertia set to zero but the ',...
            'corresponding torque fraction is not zero.'];
            psberror(Erreur);
        case 5
            Erreur.message='Parameters error';
            psberror(Erreur);
        end

        return

    case 'Machines Demux Model'
        varargout{1}=0;
        psbcbmachdemux(varargin{2});
        return

    case 'Distributed Parameter Line Model'
        [varargout{1:nargout}]=blmodlin(varargin{2:6});
        return

    case 'testlink'
        action=['[varargout{1:nargout}]=',varargin{2},'(varargin{3:end});'];
        eval(action);
        return

    case{'ThreePhaseTransformer2Init'};

        if strcmp('stopped',get_param(bdroot,'SimulationStatus'))
            varargout{1}=-1;
            return
        end

    end

    [varargout{1:nargout}]=feval(varargin{:});
