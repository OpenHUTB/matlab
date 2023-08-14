function[ssStatus]=vehdynSS(varargin)



    if nargin<2

    end


    block=varargin{1};
    SSmethod=varargin{2};


    transICOverwriteFlag=false;
    rotICOverwriteFlag=false;
    if nargin>=4
        trans0=[varargin{3},varargin{4},0];
        rot0=[];
        if~isempty(trans0)
            transICOverwriteFlag=true;
        end
    end
    if nargin>=5
        rot0=[0,0,varargin{5}];
        if~isempty(rot0)
            rotICOverwriteFlag=true;
        end
    end
    if nargin>=6
        simTimeOut=varargin{6};
    else
        simTimeOut=120;
    end
    if nargin>=7
        portName=varargin{7};
    else
        portName=[block,'/Bus Element In1'];
    end

    bdName=bdroot(block);

    simStopTime=get_param(bdName,'StopTime');

    simStopped=autoblkschecksimstopped(block,true);

    if~bdIsLibrary(bdName)&&simStopped


        portHandle=get_param(portName,'PortHandles');
        switch SSmethod
        case 'reset'
            set_param(bdName,'LoadInitialState','off','InitialState','','EnableSteadyStateSolver','off');
            set_param(bdName,'StartSimFromSteadyState','off');

            if isempty(get_param(block,'UserData'))
                set_param(block,'UserData',{simStopTime,false});
            else
                if~strcmp(get_param(bdName,'StopTime'),get_param(block,'ssMaxTime'))
                    configData={simStopTime,false};
                    set_param(block,'UserData',configData);
                    set_param(bdName,'StopTime',simStopTime);
                end
            end
        case 'setup'
            vehdynSS(block,'reset',[],[],[],[],[]);
            configData=get_param(block,'UserData');
            set_param(bdName,'StopTime',get_param(block,'ssMaxTime'));
            if~configData{2}
                set_param(bdName,'LoadInitialState','off','InitialState','','EnableSteadyStateSolver','on','SaveSteadyStateName',get_param(block,'ssWSName'),'SteadyStateSolverName',get_param(bdName,'SolverName'));
                paramstruct=autoblkscheckparams(block,block,{'xdot_r',[1,1],{}});
                xdotUnit=get_param(block,'xdotUnit');
                spec.target=autoblksunitconv(paramstruct.xdot_r,xdotUnit,'m/s');
                paramstruct=autoblkscheckparams(block,'block',{'ssTol',[1,1],{'gt',0}});
                spec.tolerance=autoblksunitconv(paramstruct.ssTol,xdotUnit,'m/s');
                set_param(portHandle.Outport,'SteadyStateSpec',spec);
            end
        case 'resume'
            spec.target=1;
            spec.tolerance=.5;


            set_param(portHandle.Outport,'SteadyStateSpec',spec);
            opVarName=get_param(block,'ssVar');
            if ismember(opVarName,evalin('base','who'))
                opVarValue=evalin('base',opVarName);
                set_param(bdName,'EnableSteadyStateSolver','off');
                if transICOverwriteFlag==true
                    [transInd,~]=findStateInds(opVarValue);
                    opVarValue.loggedStates{transInd}.Values.Data=trans0;
                end
                if rotICOverwriteFlag==true
                    [~,rotInd]=findStateInds(opVarValue);
                    opVarValue.loggedStates{rotInd}.Values.Data=rot0;
                end
                if transICOverwriteFlag==true||rotICOverwriteFlag==true
                    assignin('base',opVarName,opVarValue);
                end
                set_param(bdName,'LoadInitialState','on','InitialState',opVarName);
            else

            end



            configData=get_param(block,'UserData');
            set_param(bdName,'StopTime',configData{1});
            set_param(bdName,'StartSimFromSteadyState','on');
        case 'runSS'
            set_param(bdName,'LoadInitialState','off')

            aMaskObj=Simulink.Mask.get(block);
            aDlgHdl=aMaskObj.getDialogHandle();
            if~isempty(aDlgHdl)
                aDlgHdl.apply;
            end
            opVarName=get_param(block,'ssWSName');
            set_param(bdName,'InitialState',opVarName);

            simData=sim(bdName,'StopTime',get_param(block,'ssMaxTime'),'TimeOut',simTimeOut);
            if~isempty(simData.tout)
                opPoint=eval(['simData.',opVarName]);
                if transICOverwriteFlag==true
                    [transInd,~]=findStateInds(opPoint);
                    if length(opPoint.loggedStates{transInd}.Values.Data)<3
                        opPoint.loggedStates{transInd}.Values.Data=trans0(1:2);
                    else
                        opPoint.loggedStates{transInd}.Values.Data=trans0;
                    end
                end
                if rotICOverwriteFlag==true
                    [~,rotInd]=findStateInds(opPoint);
                    if length(opPoint.loggedStates{rotInd}.Values.Data)>3
                        opPoint.loggedStates{rotInd}.Values.Data(3)=rot0(3);
                    else
                        opPoint.loggedStates{rotInd}.Values.Data=rot0;
                    end
                end
                assignin('base',opVarName,opPoint);
            else
                warning(message('vdynblks:vehdynErrMsg:SSsolNotFound'));
            end
            vehdynSS(block,'reset',[],[],[],[],[]);
        case 'runTrans'
            ssMode=get_param(block,'ssMode');
            opVarName=get_param(block,'ssWSName');
            configData=get_param(block,'UserData');
            if strcmp(get_param(bdName,'LoadInitialState'),'off')&&ismember(opVarName,evalin('base','who'))&&strcmp(ssMode,'Solve using block parameters')&&strcmp(get_param(bdName,'InitialState'),'')
                if evalin('base',['isa(',opVarName,',''Simulink.op.ModelOperatingPoint'');'])
                    termTimer=timer('StartDelay',1,'Period',1,'ExecutionMode','fixedRate');
                    opVarValue=evalin('base',opVarName);
                    [transInd,rotInd]=findStateInds(opVarValue);
                    termTimer.TimerFcn={@checkSysStatus,bdName,opVarName,opVarValue,configData{1},transICOverwriteFlag,trans0,transInd,rotICOverwriteFlag,rot0,rotInd};

                    start(termTimer);
                else
                    error(message('vdynblks:vehdynErrMsg:SSparamNotValid'));
                end
            else

                termTimer=timer('StartDelay',1,'Period',1,'ExecutionMode','fixedRate');
                termTimer.TimerFcn={@setupSim,block,'setup',trans0(1),trans0(2),rot0(3),simTimeOut,portName};
                start(termTimer);
                if~ismember(opVarName,evalin('base','who'))&&strcmp(get_param(bdName,'InitialState'),'')
                    error(message('vdynblks:vehdynErrMsg:SSparamNotFound'));
                end
            end
        end
    end
    ssStatus=0;
end
function checkSysStatus(obj,~,bdName,opVarName,opVarValue,simTime,transICOverwriteFlag,trans0,transInd,rotICOverwriteFlag,rot0,rotInd)
    if strcmp(get_param(bdName,'SimulationStatus'),'stopped')&&~strcmp(get_param(bdName,'InitialState'),'xForce')
        set_param(bdName,'EnableSteadyStateSolver','off');
        if transICOverwriteFlag==true
            opVarValue.loggedStates{transInd}.Values.Data=trans0;
        end
        if rotICOverwriteFlag==true
            opVarValue.loggedStates{rotInd}.Values.Data=rot0;
        end
        if transICOverwriteFlag==true||rotICOverwriteFlag==true
            assignin('base',opVarName,opVarValue);
        end
        set_param(bdName,'LoadInitialState','on','InitialState',opVarName,'StopTime',simTime,'StartSimFromSteadyState','on');
        set_param(bdName,'SimulationCommand','start');
        stop(obj);
        delete(obj);


    else

    end
end
function setupSim(obj,~,block,mode,Xo,Yo,phio,simTimeOut,portName)
    vehdynSS(block,mode,Xo,Yo,phio,simTimeOut,portName);
    stop(obj);
    delete(obj);
end
function[transInd,rotInd]=findStateInds(opValue)
    if~isempty(opValue)
        xini=opValue.loggedStates;
        numStates=numElements(xini);
        for idx=1:numStates
            if~all(cellfun('isempty',regexp(convertToCell(xini{idx}.BlockPath),'phi theta psi','match')))
                rotInd=idx;

            elseif~all(cellfun('isempty',regexp(convertToCell(xini{idx}.BlockPath),'xdot int/Integrator','match')))
                rotInd=idx;
            end
            if~all(cellfun('isempty',regexp(convertToCell(xini{idx}.BlockPath),'xe,ye,ze','match')))
                transInd=idx;

            elseif~all(cellfun('isempty',regexp(convertToCell(xini{idx}.BlockPath),'state2bus/Integrator','match')))
                transInd=idx;
            end
        end
    end
end
