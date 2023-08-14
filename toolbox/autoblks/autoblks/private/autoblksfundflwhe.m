function[varargout]=autoblksfundflwhe(varargin)





    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'EffctModelPopupCallback'
        EffctModelPopupCallback(Block);
    case 'CoolTempPopupCallback'
        CoolTempPopupCallback(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end

end


function Initialization(Block)



    EffctOptions={'autolibfundflwcommon/Constant Effectiveness','Constant Effectiveness';...
    'autolibfundflwcommon/Effectiveness Input','Effectiveness Input'};
    InportNum=1;
    switch get_param(Block,'EffctModelPopup')
    case 'Constant'
        autoblksreplaceblock(Block,EffctOptions,1);
    case 'External input'
        autoblksreplaceblock(Block,EffctOptions,2);
        InportNum=InportNum+1;
    end


    CoolTempOptions={'autolibfundflwcommon/Constant Coolant Temperature','Constant Coolant Temperature';...
    'autolibfundflwcommon/Input Coolant Temperature','Input Coolant Temperature'};
    switch get_param(Block,'CoolTempInputPopup')
    case 'Constant'
        autoblksreplaceblock(Block,CoolTempOptions,1);
    case 'External input'
        autoblksreplaceblock(Block,CoolTempOptions,2);
        set_param([Block,'/CoolTemp'],'Port',num2str(InportNum))
    end


    autoblkssetupengflwmassfrac(Block);


    ParamList={'ep_cnst',[1,1],{'gte',0;'lte',1};...
    'T_cool_cnst',[1,1],{'gt',0};...
    'cp',[1,1],{'gt',0;'lt',5000}};

    autoblkscheckparams(Block,ParamList);

end


function EffctModelPopupCallback(Block)
    switch get_param(Block,'EffctModelPopup')
    case 'Constant'
        autoblksenableparameters(Block,'ep_cnst')
    case 'External input'
        autoblksenableparameters(Block,[],'ep_cnst')
    end
end


function CoolTempPopupCallback(Block)
    switch get_param(Block,'CoolTempInputPopup')
    case 'Constant'
        autoblksenableparameters(Block,'T_cool_cnst')
    case 'External input'
        autoblksenableparameters(Block,[],'T_cool_cnst')
    end
end


function IconInfo=DrawCommands(BlkHdl)


    AliasNames={'InletFlw','C';'OutletVol','B'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

    switch get_param(BlkHdl,'EffctModelPopup')
    case 'Constant'
        IconInfo.input={};
    case 'External input'
        IconInfo.input={'Effct'};
    end
    switch get_param(BlkHdl,'CoolTempInputPopup')
    case 'External input'
        IconInfo.input=[IconInfo.input,'CoolTemp'];
    end

    switch get_param(BlkHdl,'ImageTypePopup')
    case 'Intercooler'
        IconInfo.ImageName='heat_exchanger_colder_cold.png';
    case 'EGR cooler hot to cold'
        IconInfo.ImageName='heat_exchanger_hot_cold.png';
    case 'EGR cooler cold to hot'
        IconInfo.ImageName='heat_exchanger_cold_hot.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,5,40,'white');
end