function[varargout]=autoblksfluxpmsm(varargin)


    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'PortConfigPopup'
        PortConfigPopup(Block);
    case 'SimTypeConfigPopup'
        SimTypeConfigPopup(Block);
    case 'HDLTableTypePopup'
        HDLTableTypePopup(Block);
    case 'HDLExtrapolate'
        HDLExtrapolate(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end
end

function Initialization(Block)
    PmsmOptions=...
    {'autolibfluxpmsmcommon/PMSM Speed Input Continuous','PMSM Speed Input Continuous';
    'autolibfluxpmsmcommon/PMSM Torque Input Continuous','PMSM Torque Input Continuous';
    'autolibfluxpmsmcommon/PMSM Speed Input Discrete','PMSM Speed Input Discrete';
    'autolibfluxpmsmcommon/PMSM Torque Input Discrete','PMSM Torque Input Discrete';
    'autolibfluxpmsmcommon/PMSM Speed Input Discrete HDL','PMSM Speed Input Discrete HDL';
    'autolibfluxpmsmcommon/PMSM Torque Input Discrete HDL','PMSM Torque Input Discrete HDL';
    };

    port_config=get_param(Block,'port_config');
    sim_type=get_param(Block,'sim_type');
    enable_hdl=get_param(Block,'enable_hdl');

    if isequal(sim_type,'Continuous')&&isequal(port_config,'Torque')
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
        autoblksreplaceblock(Block,PmsmOptions,2);
    elseif isequal(sim_type,'Continuous')&&isequal(port_config,'Speed')
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
        autoblksreplaceblock(Block,PmsmOptions,1);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Torque')&&~isequal(enable_hdl,'on')
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
        autoblksreplaceblock(Block,PmsmOptions,4);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Speed')&&~isequal(enable_hdl,'on')
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
        autoblksreplaceblock(Block,PmsmOptions,3);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Torque')&&isequal(enable_hdl,'on')
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
        autoblksreplaceblock(Block,PmsmOptions,6);
    elseif isequal(sim_type,'Discrete')&&isequal(port_config,'Speed')&&isequal(enable_hdl,'on')
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
        autoblksreplaceblock(Block,PmsmOptions,5);
    else
        error(message('autoblks_shared:autoerrfluxpmsm:invalidMask'));
    end


    ParamList={'Rs',[1,1],{'gt',0};...
    'P',[1,1],{'gt',0};...
    'fluxdq0',[1,2],{};...
    'theta_init',[1,1],{};...
    'omega_init',[1,1],{};...
    'mechanical',[1,3],{'gte',0};...
    'Ts',[1,1],{'gt',0};...
    'intPrec',[1,1],{'gt',0};...
    'u1max',[1,1],{'gt','u1min'};...
    'u1min',[1,1],{'lt','u1max'};...
    'u2max',[1,1],{'gt','u2min'};...
    'u2min',[1,1],{'lt','u2max'};...
    };

    LookupTblList={{'flux_d',{},'flux_q',{}},'id',{};...
    {'flux_d',{},'flux_q',{}},'iq',{};...
    };

    autoblkscheckparams(Block,'Flux Based PMSM',ParamList,LookupTblList);
end

function IconInfo=DrawCommands(BlkHdl)

    AliasNames={};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);


    IconInfo.ImageName='electric_machine_interior_pmsm.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,20,200,'white');
end

function PortConfigPopup(Block)
    port_config=get_param(Block,'port_config');


    switch port_config
    case 'Torque'
        autoblksenableparameters(Block,{'omega_init','mechanical'},[],[],[]);
    case 'Speed'
        autoblksenableparameters(Block,[],{'omega_init','mechanical'},[],[]);
    end
end

function SimTypeConfigPopup(Block)
    sim_type=get_param(Block,'sim_type');


    switch sim_type
    case 'Continuous'
        autoblksenableparameters(Block,[],{'Ts'},[],[]);
    case 'Discrete'
        autoblksenableparameters(Block,{'Ts'},[],[],[]);
    end
end

function HDLTableTypePopup(Block)

    enable_hdl=get_param(Block,'enable_hdl');


    switch enable_hdl
    case 'on'
        autoblksenableparameters(Block,[],[],{'n1','n2','preExtrapFlag'},{});
        HDLExtrapolate(Block);
    case 'off'
        autoblksenableparameters(Block,[],[],{},{'n1','n2','preExtrapFlag','u1max','u1min','u2max','u2min'});
    otherwise
        error(message('autoblks_shared:autoerrfluxpmsm:invalidMask'));
    end

end

function HDLExtrapolate(Block)
    preExtrapFlag=get_param(Block,'preExtrapFlag');
    switch preExtrapFlag
    case 'on'
        autoblksenableparameters(Block,[],[],{'u1max','u1min','u2max','u2min'},[]);
    case 'off'
        autoblksenableparameters(Block,[],[],[],{'u1max','u1min','u2max','u2min'});
    otherwise
        error(message('autoblks_shared:autoerrfluxpmsm:invalidMask'));
    end
end