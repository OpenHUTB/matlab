function varargout=autoblkshevecms(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'HevMtrLocCallback'
        HevMtrLocCallback(Block)
    case 'TransEffFactorsCallback'
        TransEffFactorsCallback(Block)
    case 'EcmsMethodCallback'
        EcmsMethodCallback(Block)
    end

end


function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='ecms_controller.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,60,150,'white');
end



function Initialization(Block)

    ConvBlks=find_system(get_param(Block,'Handle'),'LookUnderMasks','on',...
    'FollowLinks','on','MatchFilter',@Simulink.match.allVariants,...
    'ReferenceBlock','autolibhevctrlrcommon/Wheel to HEV Motor Torque Conversion');
    ParamNames={'HevMtrLoc','TransEffFactors'};
    for i=1:length(ConvBlks)
        for j=1:length(ParamNames)
            set_param(ConvBlks(i),ParamNames{j},get_param(Block,ParamNames{j}))
        end
    end


    TransEtaBlks={[Block,'/Energy Management/Powertrain Constraints/Engine Constraint/Transmission/Trans Eta'];...
    [Block,'/Energy Management/Powertrain Constraints/Engine Constraint/Eng On/Whl2EngTrq/Trans Eta']};
    for i=1:length(TransEtaBlks)
        set_param(TransEtaBlks{i},'EffFactors',get_param(Block,'TransEffFactors'))
    end


    ECMSMethodVar=[Block,'/Energy Management/Hamiltonian computation and minimization/ECMS Method'];
    switch get_param(Block,'EcmsMethod')
    case 'Non-adaptive'
        set_param(ECMSMethodVar,'LabelModeActiveChoice','1')
    case 'Adaptive'
        set_param(ECMSMethodVar,'LabelModeActiveChoice','2')
    end


    MtrEfficicencyMethodVar=[Block,'/Energy Management/Powertrain Constraints/Motor Constraint/Tabular Power Loss Data/Motor Efficiency Map Variant'];
    switch get_param(Block,'MtrEffiMethod')
    case 'Positive speed and full torque range'
        set_param(MtrEfficicencyMethodVar,'LabelModeActiveChoice','1')
    case 'Positive speed and positive torque'
        set_param(MtrEfficicencyMethodVar,'LabelModeActiveChoice','2')
    end

    ParamList={'N_diff',[1,1],{'gte',1e-6;'lt',1e5};...
    'Re',[1,1],{'gt',0;'lte',1000};...
    'LHV',[1,1],{'gte',1;'lte',1e8};...
    'eta_diff',[1,1],{'gt',0;'lte',2};...
    'N_diff_P4',[1,1],{'gte',0;'lte',1e8};...
    'HEVEngTrq_min',[1,1],{'gt',0;'lte',1000};...
    'N_idle',[1,1],{'gte',1;'lte',1e3};...
    'BattCurrMax',[1,1],{'gt',0;'lte',1000};...
    'eta_dcdc',[1,1],{'gte',0;'lte',2};...
    'BattChrgPwrMax',[1,1],{'gt',-1e6;'lte',1e6};...
    'BattDischrgPwrMax',[1,1],{'gte',1;'lte',1e8};...
    'Ngrid',[1,1],{'gt',0;'lte',200000};...
    'N_diff_P4',[1,1],{'gte',1;'lte',1e8};...
    'N_P0',[1,1],{'gt',0;'lte',100};...
    'ECMS_s',[1,1],{'gte',-100;'lte',1e3};...
    'a',[1,1],{'gt',-10;'lte',100};...
    'ECMS_Kp',[1,1],{'gte',-10;'lte',1000};...
    'ECMS_Ki',[1,1],{'gte',-10;'lte',1000};...
    'PenaltyFctr',[1,1],{'gt',-1e6;'lte',1e8};...
    'SOCTrgt',[1,1],{'gte',0;'lte',100};...
    'SOCmin',[1,1],{'gt',0;'lte',100};...
    'SOCmax',[1,1],{'gte',0;'lte',100};...
    };

    LookupTblList={{'G_trans',{'gte',0;'lte',20}},'N_trans',{'gte',0;'lte',1e3};...
    {'Trq_trans_bpts',{'gte',0;'lte',1e6},'omega_trans_bpts',{'gte',0;'lte',1e6},'G_trans',{'gte',0;'lte',100},'Temp_trans_bpts',{'gte',0;'lte',1e4}},'eta_trans_tbl',{'gte',0;'lt',1e5};...
    {'G_trans',{'gte',0;'lte',20}},'eta_trans',{'gte',0;'lte',17e3};...
    {'f_tbrake_n_bpt',{'gte',0;'lte',1e6},'f_tbrake_t_bpt',{'gte',0;'lte',1e6}},'f_tbrake',{'gte',-4000;'lt',1e6};...
    {'f_tbrake_n_bpt',{'gte',0;'lte',1e6}},'f_tbrake_min',{'gte',0;'lte',17e6};...
    {'f_tbrake_n_bpt',{'gte',0;'lte',1e6}},'max(f_tbrake)',{'gte',0;'lte',17e6};...
    {'f_tbrake_t_bpt',{'gte',0;'lte',1e6},'f_tbrake_n_bpt',{'gte',0;'lte',1e6}},'f_fuel',{'gte',0;'lt',1e6};...
    {'SOC_bpt',{}},'DischrgLmt',{'gte',0;'lte',1e2};...
    {'SOC_bpt',{}},'ChrgLmt',{'gte',0;'lte',1e2};...
    {'f_mtr_w_bpt',{}},'f_tmtr_max',{'gte',0;'lte',1e6};...
    {'f_mtr_w_bpt',{},'f_mtr_t_bpt',{'gte',0;'lte',1e6}},'f_mtr_eta',{'gte',0;'lt',1e6};...
    };

    autoblkscheckparams(Block,ParamList,LookupTblList);


end


function HevMtrLocCallback(Block)
    ws=get_param(bdroot,'modelworkspace');
    nP0=0.001;
    if hasVariable(ws,'N_P0')
        N_P0=getVariable(ws,'N_P0');
    else
        N_P0=NaN;
    end
    switch get_param(Block,'HevMtrLoc')
    case 'P0'
        autoblksenableparameters(Block,'N_P0','N_diff_P4');
        nP0p=get_param(gcb,'N_P0');
        nP0n=str2double(nP0p);
        if~isnan(N_P0)&&strcmp(nP0p,'N_P0')
            nP0=N_P0;
        elseif isnumeric(nP0n)&&~isnan(nP0n)
            nP0=nP0n;
        end
        if~isequal(nP0,N_P0)
            assignin(ws,'N_P0',nP0);
        end
    case 'P1'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'});
        nP0=1;
        if~isequal(nP0,N_P0)
            assignin(ws,'N_P0',nP0);
        end
    case 'P2'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'});
        if~isequal(nP0,N_P0)
            assignin(ws,'N_P0',nP0);
        end
    case 'P3'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'},[]);
        if~isequal(nP0,N_P0)
            assignin(ws,'N_P0',nP0);
        end
    case 'P4'
        autoblksenableparameters(Block,'N_diff_P4','N_P0',[]);
        if~isequal(nP0,N_P0)
            assignin(ws,'N_P0',nP0);
        end
    end
end


function TransEffFactorsCallback(Block)
    Params1D={'eta_trans'};
    Params4D={'Trq_trans_bpts','omega_trans_bpts','Temp_trans_bpts','eta_trans_tbl'};
    switch get_param(Block,'TransEffFactors')
    case 'Gear only'
        autoblksenableparameters(Block,Params1D,Params4D);
    case 'Gear, input torque, input speed, and temperature'
        autoblksenableparameters(Block,Params4D,Params1D);
    end

end


function EcmsMethodCallback(Block)
    AdaptiveGains={'ECMS_Kp','ECMS_Ki'};
    switch get_param(Block,'EcmsMethod')
    case 'Adaptive'
        autoblksenableparameters(Block,AdaptiveGains);
    case 'Non-adaptive'
        autoblksenableparameters(Block,[],AdaptiveGains);
    end

end