function[varargout]=autoblksfundflwfr(varargin)






    varargout{1}=0;

    Block=varargin{1};
    BlkHdl=get_param(Block,'Handle');
    context=varargin{2};




    if context==1
        FundFlwFrTypePopupCallback(BlkHdl);
        return;
    elseif context==2
        varargout{1}=DrawCommands(BlkHdl);
        return;
    end


    fundflwblk_names={'autolibfundflwcommon/Orifice Area Constant Input','Orifice Area Constant Input'
    'autolibfundflwcommon/Orifice Area External Input','Orifice Area External Input'
    'autolibfundflwcommon/Orifice Area with Throttle Effects','Orifice Area with Throttle Effects'};

    switch get_param(BlkHdl,'AreaPopup')
    case 'Constant'
        autoblksreplaceblock(BlkHdl,fundflwblk_names,1);
    case 'External input'
        autoblksreplaceblock(BlkHdl,fundflwblk_names,2);
    case 'Throttle body geometry'
        autoblksreplaceblock(BlkHdl,fundflwblk_names,3);
    end


    autoblkssetupengflwmassfrac(Block);



    ParamList={...
    'gamma',[1,1],{'gt',1;'lt',3};...
    'R',[1,1],{'gt',200;'lt',400};...
    'Plim',[1,1],{'gt',0.85;'lt',1};...
    'Aorf_cnst',[1,1],{'gte',0};...
    'Cd_cnst',[1,1],{'gte',0};...
    'Cd_ext',[1,1],{'gte',0};...
    'Dthr',[1,1],{'gte',0}};

    ThrAngBpt(1,1:2)={'ThrAngBpts',{'gte',0;'lte',90}};

    LookupTblList={...
    ThrAngBpt,'ThrCd',{'gte',0;'lt',500000};...
    };

    autoblkscheckparams(Block,ParamList,LookupTblList);
end


function FundFlwFrTypePopupCallback(BlkHdl)
    switch get_param(BlkHdl,'AreaPopup')
    case 'Constant'
        autoblksenableparameters(BlkHdl,[],[],'ConstAreaContainer',{'ExtAreaContainer','ThrottleBodyContainer'});
    case 'External input'
        autoblksenableparameters(BlkHdl,[],[],'ExtAreaContainer',{'ConstAreaContainer','ThrottleBodyContainer'});
    case 'Throttle body geometry'
        autoblksenableparameters(BlkHdl,[],[],'ThrottleBodyContainer',{'ConstAreaContainer','ExtAreaContainer'});
    end
end


function IconInfo=DrawCommands(BlkHdl)
    AliasNames={'Inlet','A';'Outlet','B'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

    switch get_param(BlkHdl,'AreaPopup')
    case 'Constant'
        switch get_param(BlkHdl,'ImageTypePopup')
        case 'Cold'
            IconInfo.ImageName='flow_restriction_cold.png';
        case 'Hot'
            IconInfo.ImageName='flow_restriction_hot.png';
        end
        IconInfo.input={};


    case 'External input'
        switch get_param(BlkHdl,'ImageTypePopup')
        case 'Cold'
            IconInfo.ImageName='flow_restriction_cold_valve.png';
        case 'Hot'
            IconInfo.ImageName='flow_restriction_hot_valve.png';
        end
        IconInfo.input={'Area'};

    case 'Throttle body geometry'
        switch get_param(BlkHdl,'ImageTypePopup')
        case 'Cold'
            IconInfo.ImageName='flow_restriction_cold_valve.png';
        case 'Hot'
            IconInfo.ImageName='flow_restriction_hot_valve.png';
        end
        IconInfo.input={'ThrPct'};
    end

    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,5,40,'white');
end