function[varargout]=autoblksvehdynlnginplnmoto(varargin)



    block=varargin{1};
    callID=varargin{2};

    if callID==0

        simStopped=autoblkschecksimstopped(block);


        SuspType=get_param(block,'SuspType');

        if simStopped

            if strcmp(SuspType,'Simple')
                set_param([block,'/Suspension/Rear suspension'],'LabelModeActiveChoice','builtin');
                set_param([block,'/Suspension/Front suspension'],'LabelModeActiveChoice','builtin');
                SwitchInport(block,'FSuspF','Ground');
                SwitchInport(block,'MSuspR','Ground');
            else
                set_param([block,'/Suspension/Rear suspension'],'LabelModeActiveChoice','external');
                set_param([block,'/Suspension/Front suspension'],'LabelModeActiveChoice','external');
                SwitchInport(block,'FSuspF','Inport',[]);
                SwitchInport(block,'MSuspR','Inport',[]);
            end


            if strcmp(get_param(block,'extFMode'),'on')
                SwitchInport(block,'FExt','Inport',[]);
            else
                SwitchInport(block,'FExt','Ground');
            end

            if strcmp(get_param(block,'extWind'),'on')
                SwitchInport(block,'WindXYZ','Inport',[]);
            else
                SwitchInport(block,'WindXYZ','Ground');
            end

            if strcmp(get_param(block,'extGrade'),'on')
                SwitchInport(block,'Grade','Inport',[]);
            else
                SwitchInport(block,'Grade','Ground');
            end

            if strcmp(get_param(block,'extMMode'),'on')
                SwitchInport(block,'MExt','Inport',[]);
            else
                SwitchInport(block,'MExt','Ground');
            end

            if strcmp(get_param(block,'extMFrMode'),'on')
                SwitchInport(block,'MWhlF','Inport',[]);
            else
                SwitchInport(block,'MWhlF','Ground');
            end

            if strcmp(get_param(block,'extMRrMode'),'on')
                SwitchInport(block,'MWhlR','Inport',[]);
            else
                SwitchInport(block,'MWhlR','Ground');
            end


            InportNames={'FCpF';'FCpR';'MDrvArmR';'MDrvFrm';'FExt';'MExt';'MBrkF';'MBrkR';'MWhlF';'MWhlR';'FSuspF';'MSuspR';'Grade';'WindXYZ';'Temp'};
            FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
            [~,PortI]=intersect(InportNames,FoundNames);
            PortI=sort(PortI);
            for i=1:length(PortI)
                set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
            end

        end



        BaseParamList={...
        'FrmCmPxz',[1,2],{'gte',-10;'lte',10};...
        'RdrCmPxz',[1,2],{'gte',-10;'lte',10};...
        'ArmRrCmPxz',[1,2],{'gte',-10;'lte',10};...
        'FrkUpCmPxz',[1,2],{'gte',-10;'lte',10};...
        'FrkLwCmPxz',[1,2],{'gte',-10;'lte',10};...
        'FrmMass',[1,1],{'gt',0;'lte',3000};...
        'RdrMass',[1,1],{'gte',0;'lte',500};...
        'ArmRrMass',[1,1],{'gt',0;'lte',500};...
        'FrkUpMass',[1,1],{'gt',0;'lte',500};...
        'FrkLwMass',[1,1],{'gt',0;'lte',500};...
        'WhlRrMass',[1,1],{'gt',0;'lte',500};...
        'WhlFrMass',[1,1],{'gt',0;'lte',500};...
        'FrmIyy',[1,1],{'gt',0;'lte',500};...
        'RdrIyy',[1,1],{'gte',0;'lte',500};...
        'ArmRrIyy',[1,1],{'gt',0;'lte',50};...
        'FrkUpIyy',[1,1],{'gt',0;'lte',50};...
        'FrkLwIyy',[1,1],{'gt',0;'lte',50};...
        'ArmRrLen',[1,1],{'gt',0;'lte',50};...
        'FrmLen',[1,1],{'gt',0;'lte',50};...
        'FrkOfs',[1,1],{'gt',0;'lte',50};...
        'WhlFrR',[1,1],{'gt',0;'lte',10};...
        'WhlRrR',[1,1],{'gt',0;'lte',10};...
        'g',[1,1],{'gte',0;'lte',1000};...
        'CpRrX0',[1,1],{};...
        'CpRrZ0',[1,1],{};...
        'ArmRrAng0',[1,1],{'gte',-2*pi;'lte',2*pi};...
        'FrmAng0',[1,1],{'gte',-2*pi;'lte',2*pi};...
        'FrkFrL0',[1,1],{'gt',0;'lte',10};...
        'CpRrVx0',[1,1],{};...
        'CpRrVz0',[1,1],{};...
        'ArmRrAngV0',[1,1],{};...
        'FrmAngV0',[1,1],{};...
        'FrkLwV0',[1,1],{};...
        'Tair',[1,1],{'gt',0};...
        'Cd',[1,1],{'gte',0};...
        'Af',[1,1],{'gte',0};...
        'Cl',[1,1],{};...
        'Cpm',[1,1],{};...
        'Lcpm',[1,1],{};...
        'Pabs',[1,1],{'gt',0};...
        'longOff',[1,1],{'gte',-1e6;'lte',1e6};...
        'latOff',[1,1],{'gte',-1e6;'lte',1e6};...
        'vertOff',[1,1],{'gte',-1e6;'lte',1e6};...
        'rollOff',[1,1],{'gte',-2*pi;'lte',2*pi};...
        'pitchOff',[1,1],{'gte',-2*pi;'lte',2*pi};...
        'yawOff',[1,1],{'gte',-2*pi;'lte',2*pi};...
        };


        if strcmp(SuspType,'Simple')
            SuspParamList={...
            'SuspFrK',[1,1],{'gte',0;'lte',1e6};...
            'SuspFrC',[1,1],{'gte',0;'lte',1e6};...
            'FrkLwL0',[1,1],{'gte',0;'lte',10};...
            'SuspRrK',[1,1],{'gte',0;'lte',1e6};...
            'SuspRrC',[1,1],{'gte',0;'lte',1e6};...
            'ShkRrAng0',[1,1],{'gte',-2*pi;'lte',2*pi};...
            };
        else
            SuspParamList={};
        end

        autoblkscheckparams(block,'Longitudinal in-plane motorcycle',[BaseParamList;SuspParamList]);

        if strcmp(get_param(block,'extTamb'),'on')
            SwitchInport(block,'Temp','Inport',[]);
        else
            SwitchInport(block,'Temp','Constant','Tair');
        end

        varargout{1}={};


    elseif callID==1

        SuspType=get_param(block,'SuspType');

        if strcmp(SuspType,'Simple')
            autoblksenableparameters(block,[],[],{'SusParameterPanel'});
        else
            autoblksenableparameters(block,[],[],[],{'SusParameterPanel'});
        end

        varargout{1}={};

    elseif callID==5


        IconInfo=autoblksgetportlabels(block,{});
        IconInfo.ImageName='vehicle_dynamics_motoinplnlng.png';
        [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,70,'white');
        varargout{1}=IconInfo;

    elseif callID==6

        [ini,pCGxra,pCGzra,pCGxm,pCGzm,pCGxuf,pCGzuf,pCGxlf,pCGzlf,FrmEqMass,FrmEqIyy]=InitialConditionsInitialize(block);

        varargout{1}={ini,pCGxra,pCGzra,pCGxm,pCGzm,pCGxuf,pCGzuf,pCGxlf,pCGzlf,FrmEqMass,FrmEqIyy};

    elseif callID==7
        if strcmp(get_param(block,'extTamb'),'on')
            autoblksenableparameters(block,[],{'Tair'},[],[],'true');
        else
            autoblksenableparameters(block,{'Tair'},[],[],[],'true');
        end
        varargout{1}=0;

    else

        varargout{1}={};

    end



end


function[ini,pCGxra,pCGzra,pCGxm,pCGzm,pCGxuf,pCGzuf,pCGxlf,pCGzlf,FrmEqMass,FrmEqIyy]=InitialConditionsInitialize(Block)


    autoblksgetmaskparms(Block,{'ArmRrCmPxz','FrmCmPxz','RdrCmPxz','FrmMass','RdrMass','FrmIyy','RdrIyy','FrkUpCmPxz','FrkLwCmPxz','WhlFrR','FrkOfs','FrmLen','ArmRrLen','WhlRrR','CpRrX0','CpRrZ0','ArmRrAng0','FrmAng0','FrkFrL0','CpRrVx0','CpRrVz0','ArmRrAngV0','FrmAngV0','FrkLwV0'},true);

    ini.px=CpRrX0;
    ini.pz=CpRrZ0;
    ini.pmur=ArmRrAng0;
    ini.pmu=FrmAng0;
    ini.pdf=FrkFrL0;

    ini.rx=CpRrVx0;
    ini.rz=CpRrVz0;
    ini.rmur=ArmRrAngV0;
    ini.rmu=FrmAngV0;
    ini.rdf=FrkLwV0;

    ini.pxf=ini.px+sin(ini.pmur)*(cos(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))-sin(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)))+...
    cos(ini.pmur)*(ArmRrLen+sin(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))+cos(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)));

    ini.pzf=ini.pz-WhlRrR+cos(ini.pmur)*(cos(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))-sin(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)))-...
    sin(ini.pmur)*(ArmRrLen+sin(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))+cos(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)));


    ini.rxf=ini.rx+cos(ini.pmur)*(sin(ini.pmu)*(ini.rdf-WhlFrR*sin(ini.pmu+ini.pmur)*(ini.rmu+ini.rmur))-ini.rmu*sin(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur))+...
    ini.rmu*cos(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))-WhlFrR*cos(ini.pmu+ini.pmur)*cos(ini.pmu)*(ini.rmu+ini.rmur))+...
    sin(ini.pmur)*(cos(ini.pmu)*(ini.rdf-WhlFrR*sin(ini.pmu+ini.pmur)*(ini.rmu+ini.rmur))-ini.rmu*cos(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur))-...
    ini.rmu*sin(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))+WhlFrR*cos(ini.pmu+ini.pmur)*sin(ini.pmu)*(ini.rmu+ini.rmur))+...
    ini.rmur*cos(ini.pmur)*(cos(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))-sin(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)))-...
    ini.rmur*sin(ini.pmur)*(ArmRrLen+sin(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))+cos(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)));

    ini.rzf=ini.rz+cos(ini.pmur)*(cos(ini.pmu)*(ini.rdf-WhlFrR*sin(ini.pmu+ini.pmur)*(ini.rmu+ini.rmur))-ini.rmu*cos(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur))-...
    ini.rmu*sin(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))+WhlFrR*cos(ini.pmu+ini.pmur)*sin(ini.pmu)*(ini.rmu+ini.rmur))-...
    sin(ini.pmur)*(sin(ini.pmu)*(ini.rdf-WhlFrR*sin(ini.pmu+ini.pmur)*(ini.rmu+ini.rmur))-ini.rmu*sin(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur))+...
    ini.rmu*cos(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))-WhlFrR*cos(ini.pmu+ini.pmur)*cos(ini.pmu)*(ini.rmu+ini.rmur))-...
    ini.rmur*sin(ini.pmur)*(cos(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))-sin(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)))-...
    ini.rmur*cos(ini.pmur)*(ArmRrLen+sin(ini.pmu)*(ini.pdf+WhlFrR*cos(ini.pmu+ini.pmur))+cos(ini.pmu)*(FrkOfs+FrmLen-WhlFrR*sin(ini.pmu+ini.pmur)));




    FrmEqMass=FrmMass+RdrMass;

    Rbar(1)=(FrmCmPxz(1)*FrmMass+RdrCmPxz(1)*RdrMass)/FrmEqMass;
    Rbar(2)=(FrmCmPxz(2)*FrmMass+RdrCmPxz(2)*RdrMass)/FrmEqMass;

    FrmEqIyy=FrmIyy+FrmMass*((FrmCmPxz(1)-Rbar(1))^2+(FrmCmPxz(2)-Rbar(2))^2)+RdrIyy+RdrMass*((RdrCmPxz(1)-Rbar(1))^2+(RdrCmPxz(2)-Rbar(2))^2);





    pCGxra=ArmRrCmPxz(1);
    pCGzra=ArmRrCmPxz(2);

    pCGxm=Rbar(1);
    pCGzm=Rbar(2);

    pCGxuf=FrkUpCmPxz(1);
    pCGzuf=FrkUpCmPxz(2);

    pCGxlf=FrkLwCmPxz(1);
    pCGzlf=FrkLwCmPxz(2);



end

function SwitchInport(Block,PortName,UsePort,Param)

    InportOption={'built-in/Constant',[PortName,'Constant'];...
    'built-in/Inport',PortName;...
    'simulink/Sinks/Terminator',[PortName,'Terminator'];...
    'simulink/Sinks/Out1',PortName;...
    'built-in/Ground',[PortName,'Ground']};
    switch UsePort
    case 'Constant'
        NewBlkHdl=autoblksreplaceblock(Block,InportOption,1);
        set_param(NewBlkHdl,'Value',Param);
    case 'Terminator'
        autoblksreplaceblock(Block,InportOption,3);
    case 'Outport'
        autoblksreplaceblock(Block,InportOption,4);
    case 'Inport'
        autoblksreplaceblock(Block,InportOption,2);
    case 'Ground'
        autoblksreplaceblock(Block,InportOption,5);
    end

end