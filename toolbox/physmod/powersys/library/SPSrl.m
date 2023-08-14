function varargout=SPSrl(varargin)










































































    switch varargin{1}

    case 'get'



        SPSrulesBlock=find_system(varargin{2},...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'SPSRulesBlock','SPSRules');

        if~isempty(SPSrulesBlock)

            SPSrulesBlock=SPSrulesBlock{1};
            Rules=getSPSmaskvalues(SPSrulesBlock,{'SPSRules'});
            if~isequal(varargin{3},'NoMessages')
                disp(['Third-Party Rule block detected: ',SPSrulesBlock]);
            end
            if isequal(varargin{3},'GetLoadFlowData')
                Rules=[];

            end
        else
            Rules=[];
        end



        if~isfield(Rules,'PreBlockAnalysisFcn')
            Rules.PreBlockAnalysisFcn='';
        end
        if~isfield(Rules,'PostBlockAnalysisFcn')
            Rules.PostBlockAnalysisFcn='';
        end

        if~isfield(Rules,'PreStateSpaceFcn')
            Rules.PreStateSpaceFcn='';
        end
        if~isfield(Rules,'PostStateSpaceFcn')
            Rules.PostStateSpaceFcn='';
        end

        if~isfield(Rules,'PreDiscretizeFcn')
            Rules.PreDiscretizeFcn='';
        end
        if~isfield(Rules,'PostDiscretizeFcn')
            Rules.PostDiscretizeFcn='';
        end

        if~isfield(Rules,'PreSteadyStateFcn')
            Rules.PreSteadyStateFcn='';
        end
        if~isfield(Rules,'PostSteadyStateFcn')
            Rules.PostSteadyStateFcn='';
        end

        if~isfield(Rules,'PreEquivalentCircuitFcn')
            Rules.PreEquivalentCircuitFcn='';
        end
        if~isfield(Rules,'PostEquivalentCircuitFcn')
            Rules.PostEquivalentCircuitFcn='';
        end



        Rules.DoNotCompile=0;
        Rules.CalledByPowergui=isequal(varargin{3},'powergui');
        Rules.CreateNetList=isequal(varargin{3},'net');
        Rules.CreateSSobject=isequal(varargin{3},'ss');
        Rules.CalledByPowerAnalyze=any(strcmp({'detailed','structure','version3'},varargin{3}));
        Rules.StopAfterBlockAnalysisFcn=isequal(varargin{3},'sort');
        Rules.StopAfterLoadFlowDatas=isequal(varargin{3},'GetLoadFlowData');
        Rules.StopAfterUnbalancedLoadFlowDatas=isequal(varargin{3},'GetUnbalancedLoadFlowData');
        Rules.DisableBlockAnalysisFcn=0;
        Rules.DisableStateSpaceFcn=0;
        Rules.DisableDiscretizeFcn=0;
        Rules.DisableSteadyStateFcn=0;
        Rules.DisableEquivalentCircuitFcn=0;


        varargout{1}=Rules;


    case 'eval'

        Rule=varargin{2};
        RuleName=varargin{3};
        SPS=varargin{4};

        if~isempty(Rule)
            if SPS.PowerguiInfo.EchoMessage
                disp(['Execute ',RuleName,' external rule: "',Rule,'".'])
            end

            SPSpub=SPSrl('remove',SPS);
            try
                SPSpub=feval(Rule,SPSpub);
                SPS=SPSrl('merge',SPSpub,SPS);
            catch ME
                rethrow(ME);
            end
        end


        varargout{1}=SPS;


    case 'remove'

        SPS=varargin{2};
        PrivateFields=SPSrl('privatefields');
        for i=1:length(PrivateFields)
            if isfield(SPS,PrivateFields{i})
                SPS=rmfield(SPS,PrivateFields{i});
            end
        end


        varargout{1}=SPS;


    case 'merge'

        SPS=varargin{2};
        SPS_full=varargin{3};
        PrivateFields=SPSrl('privatefields');
        for i=1:length(PrivateFields)
            if isfield(SPS_full,PrivateFields{i})
                SPS.(PrivateFields{i})=SPS_full.(PrivateFields{i});
            end
        end


        varargout{1}=SPS;


    case 'userblock'

        MaskType=varargin{2};
        switch MaskType
        case 'IGBT/Diode'
            MaskType='IGBTDiode';
        end
        sys=varargin{3};
        WantBlockChoice=varargin{4};
        Parameters=varargin{5};

        if strcmp('stopped',get_param(sys,'SimulationStatus'))
            varargout{1}=WantBlockChoice;
            varargout{2}=Parameters;
            return
        end



        Rules=SPSrl('get',sys,'NoMessages');


        if isfield(Rules,MaskType)
            try
                [WantBlockChoice,Parameters]=feval(Rules.(MaskType),WantBlockChoice,Parameters);
            catch ME
                rethrow(ME);
            end
        end


        varargout{1}=WantBlockChoice;
        varargout{2}=Parameters;

    case 'privatefields'


        varargout{1}={...
        'NoErrorOnMaxIteration';
        'basicnonlinearmodels';
        'ForceLonToZero';
        'GotoSources';
        'SPIDresistors';
        'Status';
        'Gates';
        'VF';
        'ITAIL';
        'unit';
        'freq';
'liste_neu'
        'AdTr';
        'BdTr';
        'CdTr';
        'DdTr';
        'EdTr';
        'makecircuit';
        'MgNotRed';
        'MgColNamesNotRed';
        'Mg_nbNotRed';
        'Mg';
        'MgColNames';
        'Mg_nb';
        'MatStateDependency'};

    end
