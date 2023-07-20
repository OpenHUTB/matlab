function[varargout]=autoblksboostshaft(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'ShaftConfigPopupCallback'
        ShaftConfigPopupCallback(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end

end


function Initialization(Block)



    ShaftConfigs={'autolibboostcommon/Turbocharger','Turbocharger';...
    'autolibboostcommon/Turbine Only','Turbine Only';...
    'autolibboostcommon/Compressor Only','Compressor Only'};
    ExtTrqOptions={'autolibboostcommon/No External Torque','No External Torque'
    'autolibboostcommon/External Torque','External Torque'};
    switch get_param(Block,'ShaftConfigPopup')
    case 'Turbocharger'
        autoblksreplaceblock(Block,ShaftConfigs,1);

        switch get_param(Block,'AddTrqTypePopup')
        case 'No external torque'
            autoblksreplaceblock(Block,ExtTrqOptions,1);
        case 'External torque input'
            autoblksreplaceblock(Block,ExtTrqOptions,2);
        end
    case 'Turbine only'
        autoblksreplaceblock(Block,ShaftConfigs,2);
        autoblksreplaceblock(Block,ExtTrqOptions,2);
    case 'Compressor only'
        autoblksreplaceblock(Block,ShaftConfigs,3);
        autoblksreplaceblock(Block,ExtTrqOptions,2);
    end




    ParamList={'J_shaft',[1,1],{'gt',0};...
    'w_0',[1,1],{'gte','w_min';'lte','w_max'};...
    'w_max',[1,1],{'gt','w_min'};...
    'eta_mech',[1,1],{'gt',0;'lte',1};...
    'w_min',[1,1],{'lt','w_max'}};


    autoblkscheckparams(Block,ParamList);

end


function ShaftConfigPopupCallback(Block)
    switch get_param(Block,'ShaftConfigPopup')
    case 'Compressor only'
        autoblksenableparameters(Block,[],{'eta_mech','AddTrqTypePopup'});
    case 'Turbine only'
        autoblksenableparameters(Block,'eta_mech','AddTrqTypePopup');
    case 'Turbocharger'
        autoblksenableparameters(Block,{'eta_mech','AddTrqTypePopup'},[]);
    end
end


function IconInfo=DrawCommands(Block)


    IconInfo=autoblksgetportlabels(Block);


    IconInfo.ImageName='boost_turbo_shaft.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,10,80,'white');
end