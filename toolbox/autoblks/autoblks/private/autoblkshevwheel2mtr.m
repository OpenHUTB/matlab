function varargout=autoblkshevwheel2mtr(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'VariantInit'
        VariantInit(Block)
    case 'HevMtrLocCallback'
        HevMtrLocCallback(Block)
    case 'TransEffFactorsCallback'
        TransEffFactorsCallback(Block)
    end

end


function Initialization(Block)


    BlkOption={'autolibhevctrlrcommon/MotTrq2WhlMotTrq P0','MotTrq2WhlMotTrq P0';...
    'autolibhevctrlrcommon/MotTrq2WhlMotTrq P1_P2','MotTrq2WhlMotTrq P1_P2';...
    'autolibhevctrlrcommon/MotTrq2WhlMotTrq P3','MotTrq2WhlMotTrq P3';...
    'autolibhevctrlrcommon/MotTrq2WhlMotTrq P4','MotTrq2WhlMotTrq P4';...
    'autolibhevctrlrcommon/WhlTrq2MotTrq P0','WhlTrq2MotTrq P0';...
    'autolibhevctrlrcommon/WhlTrq2MotTrq P1_P2','WhlTrq2MotTrq P1_P2';...
    'autolibhevctrlrcommon/WhlTrq2MotTrq P3','WhlTrq2MotTrq P3';...
    'autolibhevctrlrcommon/WhlTrq2MotTrq P4','WhlTrq2MotTrq P4'};
    BlkNames=BlkOption(:,2);
    BlockIdx=1:length(BlkNames);
    switch get_param(Block,'ConvType')
    case 'Motor torque to wheel torque'
        BlkType='MotTrq2WhlMotTrq';
    case 'Wheel torque to motor torque'
        BlkType='WhlTrq2MotTrq';
    end
    switch get_param(Block,'HevMtrLoc')
    case 'P0'
        MotLocName='P0';
    case 'P1'
        MotLocName='P1_P2';
    case 'P2'
        MotLocName='P1_P2';
    case 'P3'
        MotLocName='P3';
    case 'P4'
        MotLocName='P4';
    end
    NewBlkName=[BlkType,' ',MotLocName];

    ChildBlkName=autoblksreplaceblock(Block,BlkOption,BlockIdx(strcmp(BlkNames,NewBlkName)));
    if strcmp(get_param(ChildBlkName,'Mask'),'on')
        set_param(ChildBlkName,'EffFactors',get_param(Block,'TransEffFactors'))
    end
end





























function HevMtrLocCallback(Block)
    switch get_param(Block,'HevMtrLoc')
    case 'P0'
        autoblksenableparameters(Block,'N_P0','N_diff_P4','TransGroup');
        TransEffFactorsCallback(Block)
    case 'P1'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'},'TransGroup');
        TransEffFactorsCallback(Block)
    case 'P2'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'},'TransGroup');
        TransEffFactorsCallback(Block)
    case 'P3'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'},[],'TransGroup');
    case 'P4'
        autoblksenableparameters(Block,'N_diff_P4','N_P0',[],'TransGroup');
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