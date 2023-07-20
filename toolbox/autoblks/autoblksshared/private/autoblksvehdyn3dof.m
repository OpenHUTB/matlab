function[varargout]=autoblksvehdyn3dof(varargin)



    block=varargin{1};
    callID=varargin{2};
    simStopped=autoblkschecksimstopped(block);
    if callID~=1
        groundType=get_param(block,'groundType');
    end







    if callID==0
        [~]=autoblksvehdyn3dof(block,2);
        TCOptions=...
        {'autolibsharedcommon/Vehicle Body 3dof','Vehicle Body 3dof';
        'autolibsharedcommon/Vehicle Body 3 DOF Grade Input','Vehicle Body 3 DOF Grade Input';
        'autolibsharedcommon/Vehicle Body 3 DOF External Force Input','Vehicle Body 3 DOF External Force Input'};


        switch groundType
        case 'Axle displacement, velocity'
            blkID=1;
        case 'Grade angle'
            blkID=2;
        case 'External suspension'
            blkID=3;
        end
        if simStopped
            autoblksreplaceblock(block,TCOptions,blkID);
            switch blkID
            case 1
                set_param([block,'/Vehicle Body 3dof/Bus Creation/Power/Longitudinal 3DOF/Transfered Suspension'],'LabelModeActiveChoice','Internal');
            case 2
                set_param([block,'/Vehicle Body 3 DOF Grade Input/Vehicle Body 3dof/Bus Creation/Power/Longitudinal 3DOF/Transfered Suspension'],'LabelModeActiveChoice','Internal');
            case 3
                set_param([block,'/Vehicle Body 3 DOF External Force Input/Bus Creation/Power/Longitudinal 3DOF/Transfered Suspension'],'LabelModeActiveChoice','External');
            end
        end

        ParamList={...
        'NF',[1,1],{'gt',0;'int',0};...
        'NR',[1,1],{'gt',0;'int',0};...
        'm',[1,1],{'gt',0};...
        'a',[1,1],{'gte',0};...
        'b',[1,1],{'gte',0};...
        'h',[1,1],{'gte',0};...
        'Cd',[1,1],{'gte',0};...
        'Af',[1,1],{'gte',0};...
        'x_o',[1,1],{};...
        'xdot_o',[1,1],{};...
        'Cl',[1,1],{};...
        'z_o',[1,1],{};...
        'zdot_o',[1,1],{};...
        'Iyy',[1,1],{'gt',0};...
        'Cpm',[1,1],{};...
        'theta_o',[1,1],{};...
        'q_o',[1,1],{};...
        'Pabs',[1,1],{'gte',0};...
        'T',[1,1],{'gte',0};...
        'g',[1,1],{'gte',0}...
        };

        LookupTblList={{'dzsF',{}},'FskF',{};...
        {'dzsR',{}},'FskR',{};...
        {'dzdotsF',{}},'FsbF',{};...
        {'dzdotsR',{}},'FsbR',{}};

        autoblkscheckparams(block,'Vehicle Body 3dof',ParamList,LookupTblList);
        if strcmp(get_param(block,'extTamb'),'on')
            SwitchInport(block,'AirTemp','Inport',[]);
        else
            SwitchInport(block,'AirTemp','Constant','T');
        end
        if strcmp(get_param(block,'extFMode'),'on')
            SwitchInport(block,'FExt','Inport',[]);
        else
            SwitchInport(block,'FExt','Constant','[0,0,0]');
        end
        if strcmp(get_param(block,'extMMode'),'on')
            SwitchInport(block,'MExt','Inport',[]);
        else
            SwitchInport(block,'MExt','Constant','[0,0,0]');
        end

        InportNames={'FExt';'MExt';'FwF';'FwR';'zF,R';'zdotF,R';'FsF';'FsR';'Grade';'WindXYZ';'Temp'};
        FoundNames=get_param(find_system(block,'LookUnderMasks','all','SearchDepth',1,'FollowLinks','on','BlockType','Inport'),'Name');
        [~,PortI]=intersect(InportNames,FoundNames);
        PortI=sort(PortI);
        for i=1:length(PortI)
            set_param([block,'/',InportNames{PortI(i)}],'Port',num2str(i));
        end
        varargout{1}={};
    end

    if callID==2
        if strcmp(groundType,'External suspension')
            autoblksenableparameters(block,[],[],[],{'SuspGroup'});
        else
            autoblksenableparameters(block,[],[],{'SuspGroup'});
        end
        varargout{1}={};
    end

    if callID==3
        MaskObject=get_param(block,'MaskObject');
        MaskVarNames={MaskObject.getWorkspaceVariables.Name};
        MaskVarValues={MaskObject.getWorkspaceVariables.Value};
        paramList={'dzsF';'FskF';'dzsR';'FskR';'dzdotsF';'FsbF';'dzdotsR';'FsbR'};
        for idx=1:length(paramList)
            [~,j]=intersect(MaskVarNames,paramList{idx});
            plotVar.(paramList{idx})=MaskVarValues{j};
        end
        subplot(2,1,1)
        plot(plotVar.dzsF,plotVar.FskF,plotVar.dzsR,plotVar.FskR)
        xlabel(getString(message('autoblks_shared:autoblkvehdyn3dofPlot:disp')))
        ylabel(getString(message('autoblks_shared:autoblkvehdyn3dofPlot:stiffF')))
        legend(getString(message('autoblks_shared:autoblkvehdyn3dofPlot:front')),...
        getString(message('autoblks_shared:autoblkvehdyn3dofPlot:rear')))
        box on
        subplot(2,1,2)
        plot(plotVar.dzdotsF,plotVar.FsbF,plotVar.dzdotsR,plotVar.FsbR)
        xlabel(getString(message('autoblks_shared:autoblkvehdyn3dofPlot:vel')))
        ylabel(getString(message('autoblks_shared:autoblkvehdyn3dofPlot:dampF')))
        box on
    end

    if callID==4
        if strcmp(get_param(block,'extTamb'),'on')
            autoblksenableparameters(block,[],{'T'},[],[],'true');
        else
            autoblksenableparameters(block,{'T'},[],[],[],'true');
        end
    end
    if callID<5
        varargout{1}={};
    end

    if callID==5
        varargout{1}=DrawCommands(block);
    end
end


function IconInfo=DrawCommands(BlkHdl)

    AliasNames={'Total Force','Force';'Total Power','Power'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='vehicle_dynamics_3dof.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,70,'white');
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