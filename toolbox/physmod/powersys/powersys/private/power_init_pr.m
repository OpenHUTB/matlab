function varargout=power_init_pr(sys,action,Parameter1,Parameter2)








    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_init'));
    end



    if exist(sys,'file')~=4
        Erreur.identifier='SpecializedPowerSystems:PowerInit:ModelNotFound';
        Erreur.message=['There is no system named ''',sys,''' to open.'];
        psberror(Erreur);
    end
    if~exist('action','var')
        action='CommandLine';
    end

    switch action

    case 'states'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)


        [StateVariables,x0,LoadInitialStates]=AnalyzeAndUpdateSystem(sys);
        disp(' ');
        disp(['Current values of the ',mat2str(length(x0)),' initial states of your model:']);
        disp(' ');
        for i=1:length(x0)
            disp([num2str(i,5),': ',StateVariables(i,:),' = ',num2str(x0(i))]);
        end
        disp(' ');
        if strcmp('on',LoadInitialStates)
            disp('Note: the initial state vector is imposed by the "Data inport/export initial state"')
            disp('option of the Simulink "Configuration Parameters" menu');
            disp(' ');
        end

    case 'ForceToZero'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)



        StateVariables=AnalyzeAndUpdateSystem(sys);
        NumberOfStates=size(StateVariables,1);

        UserSetting=get_param(sys,'InitialState');
        i_on=findstr(UserSetting,'%SPSon%');
        i_off=findstr(UserSetting,'%SPSoff%');
        if i_on

            UserSetting=UserSetting(i_on+7:end);
            InitialUserSetting='on';
        end
        if i_off

            UserSetting=UserSetting(i_off+8:end);
            InitialUserSetting='off';
        end
        if isempty(i_on)&&isempty(i_off)
            InitialUserSetting=get_param(sys,'LoadInitialState');
        end

        SPSidTAG=['%SPS',InitialUserSetting,'%'];
        InitialState=['zeros(1,',mat2str(NumberOfStates),');',SPSidTAG];
        set_param(sys,'LoadInitialState','on');
        set_param(sys,'InitialState',[InitialState,UserSetting]);

    case 'UseBlockStates'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)



        set_param(sys,'LoadInitialState','off');

    case 'ResetToDefault'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)





        UserSetting=get_param(sys,'InitialState');
        i_on=findstr(UserSetting,'%SPSon%');
        i_off=findstr(UserSetting,'%SPSoff%');
        if i_on

            UserSetting=UserSetting(i_on+7:end);
            InitialUserSetting='on';
        end
        if i_off

            UserSetting=UserSetting(i_off+8:end);
            InitialUserSetting='off';
        end
        if isempty(i_on)&&isempty(i_off)
            InitialUserSetting=get_param(sys,'LoadInitialState');
        end
        set_param(sys,'LoadInitialState',InitialUserSetting);
        set_param(sys,'InitialState',UserSetting);

    case 'x0'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)





        UserSetting=get_param(sys,'InitialState');
        i_on=findstr(UserSetting,'%SPSon%');
        i_off=findstr(UserSetting,'%SPSoff%');
        if i_on

            UserSetting=UserSetting(i_on+7:end);
            InitialUserSetting='on';
        end
        if i_off

            UserSetting=UserSetting(i_off+8:end);
            InitialUserSetting='off';
        end
        if isempty(i_on)&&isempty(i_off)
            InitialUserSetting=get_param(sys,'LoadInitialState');
        end

        SPSidTAG=['%SPS',InitialUserSetting,'%'];
        InitialState=[mat2str(Parameter1),SPSidTAG];
        set_param(sys,'LoadInitialState','on');
        set_param(sys,'InitialState',[InitialState,UserSetting]);

    case 'getSPSstructure'

        LOW=1;
        HIGH=1;
        nargoutchk(LOW,HIGH)

        powersysdomain_netlist('clear',2);

        set_param(sys,'SimulationCommand','update');
        PowerguiInfo=getPowerguiInfo(sys,[]);
        try
            sps=get_param([PowerguiInfo.BlockName,'/EquivalentModel1'],'UserData');
        catch ME %#ok mlint
            sps=[];
        end
        varargout{1}=sps;

    case 'look'

        LOW=0;
        HIGH=2;
        nargoutchk(LOW,HIGH)



        [StateVariables,x0,LoadInitialStates,StateSpaceStates]=AnalyzeAndUpdateSystem(sys);%#ok
        if nargout==0
            disp(' ');
            disp(['Current values of the ',mat2str(length(StateSpaceStates)),' electrical initial states of your model.']);
            disp(['Note that your model has a total of ',mat2str(length(x0)),' Simulink states']);
            disp(' ');
            for i=StateSpaceStates'
                disp([num2str(i,5),': ',StateVariables(i,:),' = ',num2str(x0(i))]);
            end
            disp(' ');
        elseif nargout==1
            varargout{1}=x0(StateSpaceStates');
        elseif nargout==2
            varargout{1}=x0(StateSpaceStates');
            varargout{2}=StateVariables(StateSpaceStates',:);
        end

    case 'reset'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)




        powergui(sys);


        PowerguiBlockName=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','PSB option menu block');
        set_param(PowerguiBlockName{1},'x0status','zero');



    case 'steady'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)





        powergui(sys);


        PowerguiBlockName=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','PSB option menu block');
        set_param(PowerguiBlockName{1},'x0status','steady');



    case 'blocks'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)






        powergui(sys);


        PowerguiBlockName=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','PSB option menu block');
        set_param(PowerguiBlockName{1},'x0status','blocks');



    case 'set'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)

    case 'setx'

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)





        powergui(sys);



        PowerguiBlockName=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','PSB option menu block');
        AnalyzeAndUpdateSystem(sys);
        SPS=get_param([PowerguiBlockName{1},'/EquivalentModel1'],'userdata');
        StateVariable=SPS.states(Parameter1);
        StateVariableName=StateVariable{1};

        power_init_pr(sys,'setbb',StateVariableName,Parameter2);

    case{'setb','setbb'}

        LOW=0;
        HIGH=0;
        nargoutchk(LOW,HIGH)





        powergui(sys);


        PowerguiBlockName=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'MaskType','PSB option menu block');

        StateVariable=Parameter1;

        if strcmp(action,'setb')

            AnalyzeAndUpdateSystem(sys);
        end
        SPS=get_param([PowerguiBlockName{1},'/EquivalentModel1'],'userdata');
        ST=1;

        for i=1:length(SPS.BlockInitialState.state)
            if strcmp(StateVariable,SPS.BlockInitialState.state{i})
                MaskType=get_param(SPS.BlockInitialState.block{i},'MaskType');
                switch MaskType
                case{'Parallel RLC Branch','Parallel RLC Load','Series RLC Branch','Series RLC Load'}
                    if isequal('Initial voltage',SPS.BlockInitialState.type{i})
                        set_param(SPS.BlockInitialState.block{i},'Setx0','on','InitialVoltage',mat2str(Parameter2));


                    else
                        set_param(SPS.BlockInitialState.block{i},'SetiL0','on','InitialCurrent',mat2str(Parameter2));


                    end
                    ST=0;
                end
            end
        end
        if ST



            PowerguiUserData=get_param(PowerguiBlockName{1},'userdata');
            if isfield(PowerguiUserData,'SpecifyInitialStates');
                PowerguiUserData.SpecifyInitialStates{end+1,1}=StateVariable;
                PowerguiUserData.SpecifyInitialStates{end,2}=Parameter2;
            else
                PowerguiUserData.SpecifyInitialStates{1,1}=StateVariable;
                PowerguiUserData.SpecifyInitialStates{1,2}=Parameter2;
            end
            set_param(PowerguiBlockName{1},'userdata',PowerguiUserData);
        end

    case 'CommandLine'

        LOW=1;
        HIGH=2;
        nargoutchk(LOW,HIGH)


        [StateVariables,x0]=AnalyzeAndUpdateSystem(sys);
        varargout{1}=x0;
        if nargout==2
            varargout{2}=StateVariables;
        end

    end



    function[StateVariables,x0,LoadInitialStates,StateSpaceStates]=AnalyzeAndUpdateSystem(sys)


        [syst,x0,str]=feval(sys,[],[],[],0);%#ok

        TypeOfState=get_param(str,'BlockType');
        SFunctions=strmatch('S-Function',TypeOfState);


        StateSpaceBlocks=strmatch('StateSpace',TypeOfState);



        SFunctionNames=get_param(str(SFunctions),'FunctionName');
        ikss=[strmatch('sfun_spssw_contc',SFunctionNames),strmatch('sfun_spssw_discc',SFunctionNames),strmatch('sfun_dqc',SFunctionNames)];
        StateSpaceStates=SFunctions(ikss);
        if isempty(StateSpaceStates)

            Parents=get_param(str(StateSpaceBlocks),'Parent');
            ParentsNames=get_param(Parents,'Name');
            ikss=strmatch('EquivalentModel',ParentsNames);
            StateSpaceStates=StateSpaceBlocks(ikss);
        end




        LoadInitialStates=get_param(sys,'LoadInitialState');
        if strcmp('on',LoadInitialStates)

            x0=eval(get_param(sys,'InitialState'),'[]');
            x0=x0';
        end




        PowerguiInfo=getPowerguiInfo(sys,[]);
        SPS=get_param([PowerguiInfo.BlockName,'/EquivalentModel1'],'UserData');











        for i=1:min(length(SPS.states),length(StateSpaceStates))
            str{StateSpaceStates(i)}=[sys,'/',SPS.states{i}];
        end


        syslength=length(sys)+2;
        StateVariables='';
        NumberOfStates=length(str);
        for i=1:NumberOfStates
            NewState=strrep(str{i},char(10),' ');
            NewState=NewState(syslength:end);
            StateVariables=strvcat(StateVariables,NewState);%#ok
        end