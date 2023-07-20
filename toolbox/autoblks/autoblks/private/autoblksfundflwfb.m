function varargout=autoblksfundflwfb(varargin)
    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        Initialization(Block);
    case 'PrsTempSrcPopupCallback'
        PrsTempSrcPopupCallback(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'MassFracSetup'
        MassFracSetup(Block,varargin{3});
    end

end


function Initialization(Block)

    SrcSelection=get_param(Block,'PrsTempSrcPopup');
    BoundOptions={'autolibfundflwcommon/Flow Boundary Constant Inputs','Flow Boundary Constant Inputs';...
    'autolibfundflwcommon/Flow Boundary External Inputs','Flow Boundary External Inputs'};

    if strcmp(SrcSelection,'Constant')
        autoblksreplaceblock(Block,BoundOptions,1);
    else
        autoblksreplaceblock(Block,BoundOptions,2);
    end


    autoblkssetupengflwmassfrac(Block);


    ParamList={'Pcnst',[1,1],{'gt',0};...
    'Tcnst',[1,1],{'gt',0};...
    'cp',[1,1],{'gt',0;'lt',5000}};

    autoblkscheckparams(Block,ParamList);

end


function PrsTempSrcPopupCallback(Block)
    SrcSelection=get_param(Block,'PrsTempSrcPopup');
    BoundParams={'Pcnst','Tcnst'};

    if strcmp(SrcSelection,'Constant')
        autoblksenableparameters(Block,BoundParams);
    else
        autoblksenableparameters(Block,[],BoundParams);
    end

end


function IconInfo=DrawCommands(BlkHdl)
    AliasNames={'Bound','C'};
    IconInfo=autoblksgetportlabels(BlkHdl,AliasNames);

    switch get_param(BlkHdl,'ImageTypePopup')
    case 'Cold'
        IconInfo.ImageName='flow_boundary_cold_flipped.png';
    case 'Hot'
        IconInfo.ImageName='flow_boundary_hot_flipped.png';
    end
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,5,80,'white');
end


function MassFracSetup(Block,EngFlwBlkObj)
    EngFlwBlkObj.MassFracSrc={'AirMassFrac'};
end
