function[X,Y,SwitchStates,InitialState,Ts,SwitchTimes]=ThreePhaseBreakerInit(block,InitialState,SwitchTimes,External,Rs,Cs)





    InitialState=InitialState-1;

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    if PowerguiInfo.SPID&&PowerguiInfo.DisableSnubbers

        [X,Y]=SwitchesIcon('Breaker',[],inf,0,[],InitialState,[],External);
    else
        [X,Y]=SwitchesIcon('Breaker',[],Rs,Cs,[],InitialState,[],External);
    end

    X.p1=0;
    X.p2=100;
    Y.p1=0;
    Y.p2=100;

    if~External

        n=length(SwitchTimes);
        vec_dt=[SwitchTimes,0]-[0,SwitchTimes];
        vec_dt=vec_dt(2:n);
        if any(vec_dt<=0)&&External==0
            message=['In mask of ''',block,''' block:',char(10),'Transition times must be defined in increasing order.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur.message,Erreur.identifier,'NoUIwait');
        end

        SwitchStates=ones(1,length(SwitchTimes))*~InitialState;
        SwitchStates(2:2:length(SwitchTimes))=InitialState;

        StartTime=eval(get_param(bdroot,'StartTime'),'0');

        if SwitchTimes(1)>StartTime
            SwitchTimes=[StartTime,SwitchTimes];
            SwitchStates=[InitialState,SwitchStates];
        end

    else


        SwitchTimes=1e6;
        SwitchStates=InitialState;

    end

    power_initmask();


    ports=get_param(block,'ports');
    External=(ports(1)==1);
    comext=get_param(block,'External');

    if strcmp(comext,'on')&&~External,
        replace_block(block,'Followlinks','on','Name','com','BlockType','Constant','Inport','noprompt');
    elseif strcmp(comext,'off')&&External,
        replace_block(block,'Followlinks','on','Name','com','BlockType','Inport','Constant','noprompt');
    end

    if strcmp('stopped',get_param(bdroot(block),'SimulationStatus'))==0
        mesure=get_param(block,'Measurements');
        mesure=strrep(mesure,'Breaker','Branch');
        mesure=strrep(mesure,'s','');

        try
            set_param([block,'/Breaker A'],'Measurements',mesure);
            set_param([block,'/Breaker B'],'Measurements',mesure);
            set_param([block,'/Breaker C'],'Measurements',mesure);
        catch ME %#ok
        end
    end