function varargout=sdl_classic_callback(h)





    out={};

    params=local_getmaskdata(h);
    name=getfullname(h);
    spsName={};

    switch get_param(h,'MaskType')

    case 'Driveline Environment'

        if params.ModeIteration
            solverBlock=sprintf([name,'/Solver\nConfiguration']);
            set_param(solverBlock,'DoFixedCost','on');
            set_param(solverBlock,'MaxModeIter','1');
        end

    case 'Housing'

        Icon.LowerLeftx=-1.0;
        Icon.LowerLefty=-1.0;
        Icon.UpperRightx=1.0;
        Icon.UpperRighty=1.0;
        Icon.x1=[-0.5,0.5];Icon.y1=[-0.4,-0.4];
        Icon.x2=[-0.4,0.4];Icon.y2=[-0.5,-0.5];
        Icon.x3=[-0.3,0.3];Icon.y3=[-0.6,-0.6];
        Orientation=get_param(name,'Orientation');
        switch lower(Orientation),
        case 'right'
            Icon.x4=[0,0];Icon.y4=[-0.4,0];
            Icon.x5=[0,1.2];Icon.y5=[0,0];
        case 'left'
            Icon.x4=[0,0];Icon.y4=[-0.4,0];
            Icon.x5=[0,-1.2];Icon.y5=[0,0];
        case 'up'
            Icon.y1=Icon.y1+0.4;
            Icon.y2=Icon.y2+0.4;
            Icon.y3=Icon.y3+0.4;
            Icon.x4=[0,0];Icon.y4=[0,0.8];
            Icon.x5=[];Icon.y5=[];
        case 'down'
            Icon.y1=Icon.y1+0.4;
            Icon.y2=Icon.y2+0.6;
            Icon.y3=Icon.y3+0.8;
            Icon.x4=[0,0];Icon.y4=[0,-0.8];
            Icon.x5=[];Icon.y5=[];
        end
        out={Icon};

    case 'Inertia'

        pm_assert(params.ShowRight==~params.ShowLeft);
        if params.ShowLeft
            set_param([name,'/Conn2'],'Side','Left');
        else
            set_param([name,'/Conn2'],'Side','Right');
        end

    case 'Shared Environment'

    case 'Simple Gear'

        or='1';
        if params.Reversing
            or='2';
        end
        set_param([name,'/Simple Gear'],'rotation_direction',or);

    case 'Variable Ratio Gear'

        or='1';
        if params.Reversing
            or='2';
        end
        set_param([name,'/Variable Ratio Gear'],'rotation_direction',or);

        spsName={[name,'/Simulink-PS Converter']};

    case 'Planet-Planet'

    case 'Planetary Gear'

        local_adjust_pmport(name,params.Show,'P','Planet-Planet/RConn1');

    case 'Ring-Planet'

    case 'Dual-Ratio Planetary'

        local_adjust_pmport(name,params.Show,'P','Ring-Planet/LConn1');

    case 'Differential'

    case 'Ravigneaux'

        local_adjust_pmport(name,params.Show,'P','Ring-Planet/LConn1');

    case 'Controllable Friction Clutch'

        if params.Sign==1
            oneWay='0';
        else
            pm_assert(params.Sign==2);
            oneWay='1';
        end
        set_param(sprintf([name,'/Controllable\nFriction Clutch']),'unidirectional',oneWay);
        set_param(sprintf([name,'/Controllable\nFriction Clutch']),'initial_state_locked',num2str(params.Lock))

        portInfo={'S','Slip'
        'L','EnergyLoss'
        'M','Mode'};
        local_adjust_outports(name,portInfo,params);

        Icon.LowerLeftx=-1.0;Icon.LowerLefty=-1.0;
        Icon.UpperRightx=1.0;Icon.UpperRighty=1.0;
        Icon.x1=[-0.5,-0.3,-0.3,0.2,-0.3,-0.3,0.2];Icon.y1=[0,0,0.5,0.5,0.5,-0.5,-0.5];
        Icon.x2=[-0.2,-0.2];Icon.y2=[0.2,0.5];
        Icon.x3=[-0.2,-0.2];Icon.y3=[-0.2,-0.5];
        Icon.x4=[0.0,0.0];Icon.y4=[0.2,0.5];
        Icon.x5=[0,0];Icon.y5=[-0.2,-0.5];
        Icon.x6=[0.2,0.2];Icon.y6=[0.2,0.5];
        Icon.x7=[0.2,0.2];Icon.y7=[-0.2,-0.5];
        Icon.x8=[-0.1,-0.1,-0.1,0.1,0.1,0.1,0.1,0.35];Icon.y8=[0.4,-0.4,0,0,0.4,-0.4,0,0];
        Icon.x9=[0.8,0.9]-0.15;Icon.y9=[0,0];
        Icon.x10=[-0.9,-0.8];Icon.y10=[0,0];
        Icon.x11=[-0.80,-0.80,-0.50,-0.50,-0.35,-0.95];Icon.y11=[-0.20,0.15,0.15,-0.20,-0.20,-0.20];
        Icon.x12=[-0.85,-0.45];Icon.y12=[-0.26,-0.26];
        Icon.x13=[-0.75,-0.55];Icon.y13=[-0.32,-0.32];
        Icon.x14=[0.50,0.50,0.80,0.80,0.95,0.35]-0.15;Icon.y14=[-0.20,0.15,0.15,-0.20,-0.20,-0.20];
        Icon.x15=[0.45,0.85]-0.15;Icon.y15=[-0.26,-0.26];
        Icon.x16=[0.55,0.75]-0.15;Icon.y16=[-0.32,-0.32];
        Affordance.x=[];
        Affordance.y=[];




        out={Icon,Affordance};

        spsName={[name,'/Simulink-PS Converter']};

    case 'Fundamental Friction Clutch'

        if params.Sign==1
            oneWay='0';
        else
            pm_assert(params.Sign==2);
            oneWay='1';
        end
        set_param([name,'/Fundamental Clutch'],'unidirectional',oneWay);
        set_param([name,'/Fundamental Clutch'],'initial_state_locked',num2str(params.Lock));

        portInfo={'S','Slip'
        'M','Mode'};
        local_adjust_outports(name,portInfo,params);
        local_adjust_labels(name,portInfo,params);

        Icon.LowerLeftx=-1.0;Icon.LowerLefty=-1.0;
        Icon.UpperRightx=1.0;Icon.UpperRighty=1.0;
        Icon.x1=([-0.5,-0.3,-0.3,-0.05,-0.3,-0.3,-0.05]+0.25)*0.8;Icon.y1=[0,0,0.5,0.5,0.5,-0.5,-0.5]*0.8;
        Icon.x2=([-0.05,-0.05]+0.25)*0.8;Icon.y2=[0.2,0.5]*0.8;
        Icon.x3=([-0.05,-0.05]+0.25)*0.8;Icon.y3=[-0.2,-0.5]*0.8;
        Icon.x4=([-0.15,-0.15,-0.15,0.2]+0.2)*0.8;Icon.y4=[0.3,-0.3,0,0]*0.8;
        Icon.x5=([0.8,0.9]-0.1)*0.8;Icon.y5=[0,0]*0.8;
        Icon.x6=([-0.9,-0.8]+0.25)*0.8;Icon.y6=[0,0]*0.8;
        Icon.x7=([-0.80,-0.80,-0.50,-0.50,-0.35,-0.95]+0.25)*0.8;Icon.y7=[-0.20,0.15,0.15,-0.20,-0.20,-0.20]*0.8;
        Icon.x8=([-0.85,-0.45]+0.25)*0.8;Icon.y8=[-0.26,-0.26]*0.8;
        Icon.x9=([-0.75,-0.55]+0.25)*0.8;Icon.y9=[-0.32,-0.32]*0.8;
        Icon.x10=([0.50,0.50,0.80,0.80,0.95,0.35]-0.1)*0.8;Icon.y10=[-0.20,0.15,0.15,-0.20,-0.20,-0.20]*0.8;
        Icon.x11=([0.45,0.85]-0.1)*0.8;Icon.y11=[-0.26,-0.26]*0.8;
        Icon.x12=([0.55,0.75]-0.1)*0.8;Icon.y12=[-0.32,-0.32]*0.8;
        Affordance.x=[];
        Affordance.y=[];
        if get_param(h,'Sign')==2
            Affordance.x=[-0.3,-0.1,-0.1,-0.1,0.1,0.3,0.1,-0.1]*1.4;
            Affordance.y=([0.2,0.2,0.1,0.3,0.2,0.2,0.2,0.1]*1.4+0.4);
        end
        out={Icon,Affordance};

        spsName={[name,'/Simulink-PS Converter'];
        [name,'/Simulink-PS Converter1'];
        [name,'/Simulink-PS Converter2']};

    case 'Torque Converter'

    case 'Hard Stop'

    case 'Torsional Spring-Damper'

    case 'Torque Sensor'

    case 'Torque Actuator'

        spsName={[name,'/Simulink-PS Converter']};

    case 'Motion Sensor'

        portInfo={'p','Angle'
        'v','Velocity'
        'a','Acceleration'};
        local_adjust_outports(name,portInfo,params);
        local_adjust_labels(name,portInfo,params);

    case 'Motion Actuator'

        spsName={[name,'/Simulink-PS Converter']};

    case 'Initial Condition'

    case 'Rotational Coupling'

    case 'Diesel Engine'

        spsName={[name,'/Simulink-PS Converter']};

    case 'Gasoline Engine'

        spsName={[name,'/Simulink-PS Converter']};

    case 'Longitudinal Vehicle Dynamics'

    case 'Tire'

        spsName={[name,'/Simulink-PS Converter1'];
        [name,'/Simulink-PS Converter2']};

    otherwise

        pm_abort('Unrecognized MaskType');

    end

    if~isempty(spsName)
        adjust_input_filtering(name,spsName);
    end

    varargout=out;

end

function t=local_getmaskdata(h)
    t=get_param(h,'MaskWsVariables');
    t=cell2struct({t.Value},{t.Name},2);
end

function local_adjust_outports(name,portInfo,params)
    portInfo=portInfo';
    portMap=struct(portInfo{:});
    numPorts=0;
    for port=portInfo(1,:)
        portName=port{1};
        selected=params.(portMap.(portName));
        if selected
            type='Outport';
        else
            type='Terminator';
        end
        blk=[name,'/',portName];
        if~strcmp(get_param(blk,'BlockType'),type)
            position=get_param(blk,'Position');
            delete_block(blk);
            add_block(['built-in/',type],blk,...
            'Position',position);
        end
        if selected
            numPorts=numPorts+1;
            set_param(blk,'Port',int2str(numPorts));
        end
    end
end

function local_adjust_pmport(name,show,portName,target)
    old=find_system(name,...
    'SearchDepth',1,...
    'LookUnderMasks','all',...
    'FollowLinks','on',...
    'Name',portName);
    if show
        if isempty(old)


            ports=get_param(name,'ports');
            side='Left';
            if ports(6)>ports(7)
                side='Right';
            end
            newBlock=add_block('built-in/PMIOPort',[name,'/',portName],'Side',side);
            set_param(newBlock,'ForegroundColor','Magenta');
            add_line(name,[portName,'/RConn1'],target,'autorouting','on');
        end
    else
        if~isempty(old)
            port=get_param([name,'/',portName],'PortHandles');
            delete_line(get_param(port.RConn,'Line'));
            delete_block([name,'/',portName]);
        end
    end
end

function local_adjust_labels(name,portInfo,params)
    portInfo=portInfo';
    portMap=struct(portInfo{:});
    for port=portInfo(1,:)
        portName=port{1};
        selected=params.(portMap.(portName));
        maskDisp=get_param(name,'MaskDisplay');



        searchStr=['[\s]*port_label\(''output'',\s*[0-9]+,\s*''',portName,'''[\s\w'',]*\);*'];
        matchStr=regexp(maskDisp,searchStr,'match');
        for i=1:length(matchStr)
            maskDisp=strrep(maskDisp,matchStr{i},'');
        end

        if selected
            portH=get_param([name,'/',portName],'Handle');
            portNum=str2double(get_param(portH,'Port'));
            labelStr=sprintf(['port_label(''output'',%d,''',portName,''')'],portNum);
            maskDisp=sprintf('%s\n%s',maskDisp,labelStr);
        end
        set_param(name,'MaskDisplay',maskDisp);
    end
end

function adjust_input_filtering(name,spsName)

    if strcmp(get_param(name,'InputFiltering'),'Use input as is')
        filtering=0;
    else
        filtering=1;
        if strcmp(get_param(name,'SimscapeFilterOrder'),'First-order filtering')
            filterOrder='1';
        else
            filterOrder='2';
        end
        timeConstant=num2str(get_param(name,'InputFilterTimeConstant'));
    end


    for i=1:length(spsName)
        if filtering
            set_param(spsName{i},'FilteringAndDerivatives','filter');
            set_param(spsName{i},'SimscapeFilterOrder',filterOrder);
            set_param(spsName{i},'InputFilterTimeConstant',timeConstant);
        else
            set_param(spsName{i},'FilteringAndDerivatives','zero');
        end
    end

end



