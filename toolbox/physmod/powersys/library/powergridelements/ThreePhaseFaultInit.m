function[FaultIcon,FaultA,FaultB,FaultC,GroundResistance,initA,initB,initC,Ts,SwitchTimes,SwitchStates]=ThreePhaseFaultInit(block,GroundResistance,SwitchTimes,SwitchStatus,FaultA,FaultB,FaultC,GroundFault,InitialStates,External)





    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;
    powerlibroot=which('powersysdomain');
    FaultIcon=[powerlibroot(1:end-16),'Fault.bmp'];

    if GroundFault
        if GroundResistance<=0
            message=['In mask of ''',block,''' block:',char(10),'You must specify a ground resistance greater than zero.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur);
        end
    end

    if FaultA+FaultB+FaultC+GroundFault==1
        FaultA=0;
        FaultB=0;
        FaultC=0;
        GroundFault=0;
    end

    if~GroundFault
        GroundResistance=1e6;
    end



    initA=InitialStates(1);
    initB=InitialStates(1);
    initC=InitialStates(1);

    if External


        SwitchTimes=1e12;
        SwitchStates=InitialStates(1);

    else

        vec_dt=[SwitchTimes,0]-[0,SwitchTimes];
        vec_dt=vec_dt(2:length(SwitchTimes));
        if any(vec_dt<=0)
            message=['In mask of ''',block,''' block:',newline,'Transition times must be defined in increasing order.'];
            Erreur.message=message;
            Erreur.identifier='SpecializedPowerSystems:BlockParameterError';
            psberror(Erreur.message,Erreur.identifier,'NoUIwait');
        end

        if~isnan(SwitchStatus(1))
            initA=~(SwitchStatus(1));
            initB=~(SwitchStatus(1));
            initC=~(SwitchStatus(1));
            set_param(block,'SwitchStatus','NaN');
            set_param(block,'InitialStates',num2str(~(SwitchStatus(1))));
        end

        SwitchStates=ones(1,length(SwitchTimes))*~InitialStates(1);
        SwitchStates(2:2:length(SwitchTimes))=InitialStates(1);

        StartTime=eval(get_param(bdroot(block),'StartTime'),'0');
        if SwitchTimes(1)>StartTime
            SwitchTimes=[StartTime,SwitchTimes];
            SwitchStates=[InitialStates(1),SwitchStates];
        end

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
        mesure=strrep(mesure,'Fault','Branch');
        mesure=strrep(mesure,'s','');

        try
            set_param([block,'/Fault A'],'Measurements',mesure);
            set_param([block,'/Fault B'],'Measurements',mesure);
            set_param([block,'/Fault C'],'Measurements',mesure);
        catch ME %#ok
        end
    end