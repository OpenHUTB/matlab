function[varargout]=autoblksecms(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
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


function HevMtrLocCallback(Block)
    switch get_param(Block,'HevMtrLoc')
    case 'P0'
        autoblksenableparameters(Block,'N_P0','N_diff_P4');
    case 'P1'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'});
    case 'P2'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'});
    case 'P3'
        autoblksenableparameters(Block,[],{'N_P0','N_diff_P4'},[]);
    case 'P4'
        autoblksenableparameters(Block,'N_diff_P4','N_P0',[]);
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
    case 'Nonadaptive'
        autoblksenableparameters(Block,[],AdaptiveGains);
    end
end

function Initialization(Block)
    EcmsOptions=...
    {'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Adapt_P0','ECMS_With_Gear_Optim_Adapt_P0';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Adapt_P1','ECMS_With_Gear_Optim_Adapt_P1';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Adapt_P2','ECMS_With_Gear_Optim_Adapt_P2';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Adapt_P3','ECMS_With_Gear_Optim_Adapt_P3';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Adapt_P4','ECMS_With_Gear_Optim_Adapt_P4';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Nonadapt_P0','ECMS_With_Gear_Optim_Nonadapt_P0';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Nonadapt_P1','ECMS_With_Gear_Optim_Nonadapt_P1';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Nonadapt_P2','ECMS_With_Gear_Optim_Nonadapt_P2';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Nonadapt_P3','ECMS_With_Gear_Optim_Nonadapt_P3';
    'autolibhevctrlrcommon/ECMS_With_Gear_Optim_Nonadapt_P4','ECMS_With_Gear_Optim_Nonadapt_P4';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Adapt_P0','ECMS_Without_Gear_Optim_Adapt_P0';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Adapt_P1','ECMS_Without_Gear_Optim_Adapt_P1';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Adapt_P2','ECMS_Without_Gear_Optim_Adapt_P2';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Adapt_P3','ECMS_Without_Gear_Optim_Adapt_P3';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Adapt_P4','ECMS_Without_Gear_Optim_Adapt_P4';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Nonadapt_P0','ECMS_Without_Gear_Optim_Nonadapt_P0';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Nonadapt_P1','ECMS_Without_Gear_Optim_Nonadapt_P1';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Nonadapt_P2','ECMS_Without_Gear_Optim_Nonadapt_P2';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Nonadapt_P3','ECMS_Without_Gear_Optim_Nonadapt_P3';
    'autolibhevctrlrcommon/ECMS_Without_Gear_Optim_Nonadapt_P4','ECMS_Without_Gear_Optim_Nonadapt_P4';
    };

    EnableGearOptim=get_param(Block,'EnableGearOptim');
    HevMtrLoc=get_param(Block,'HevMtrLoc');
    EcmsMethod=get_param(Block,'EcmsMethod');

    switch HevMtrLoc
    case 'P0'
        switch EnableGearOptim
        case 'on'
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,1);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,6);
            end
        otherwise
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,11);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,16);
            end
        end
    case 'P1'
        switch EnableGearOptim
        case 'on'
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,2);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,7);
            end
        otherwise
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,12);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,17);
            end
        end
    case 'P2'
        switch EnableGearOptim
        case 'on'
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,3);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,8);
            end
        otherwise
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,13);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,18);
            end
        end
    case 'P3'
        switch EnableGearOptim
        case 'on'
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,4);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,9);
            end
        otherwise
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,14);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,19);
            end
        end
    otherwise
        switch EnableGearOptim
        case 'on'
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,5);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,10);
            end
        otherwise
            switch EcmsMethod
            case 'Adaptive'
                autoblksreplaceblock(Block,EcmsOptions,15);
            otherwise
                autoblksreplaceblock(Block,EcmsOptions,20);
            end
        end
    end















end
