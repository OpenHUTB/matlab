function varargout=autoblkshevecmstranseff(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'EffFactorsCallback'
        EffFactorsCallback(Block);
    end

end


function Initialization(Block)
    VarBlkHdl=[Block,'/Eta Lookup'];
    switch get_param(Block,'EffFactors')
    case 'Gear only'
        NewVariant='Eta1D';
    case 'Gear, input torque, input speed, and temperature'
        NewVariant='Eta4D';
    end
    OldVariant=get_param(VarBlkHdl,'LabelModeActiveChoice');
    if~strcmp(NewVariant,OldVariant)
        set_param(VarBlkHdl,'LabelModeActiveChoice',NewVariant)
    end

end



function EffFactorsCallback(Block)
    Params1D={'eta'};
    Params4D={'Trq_bpts','omega_bpts','Temp_bpts','eta_tbl'};
    switch get_param(Block,'EffFactors')
    case 'Gear only'
        autoblksenableparameters(Block,Params1D,Params4D);
    case 'Gear, input torque, input speed, and temperature'
        autoblksenableparameters(Block,Params4D,Params1D);
    end

end