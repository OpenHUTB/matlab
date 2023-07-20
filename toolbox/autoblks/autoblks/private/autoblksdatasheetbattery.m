function[varargout]=autoblksdatasheetbattery(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'Plot'
        Plot(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    end
end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='energy_battery_datasheet.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,1,80,125,'white');
end

function Initialization(Block)

    BatteryOptions=...
    {'autolibbatterycommon/Datasheet Battery Internal','Datasheet Battery Internal';
    'autolibbatterycommon/Datasheet Battery External','Datasheet Battery External';
    };

    FilterOptions=...
    {'autolibbatterycommon/Output Passthrough','Output Passthrough';
    'autolibbatterycommon/Output Filter','Output Filter';
    };

    CapacityCtrl=get_param(Block,'CapacityCtrl');
    OutputVlt=get_param(Block,'OutputVlt');
    switch CapacityCtrl
    case 'Parameter'
        autoblksreplaceblock(Block,BatteryOptions,1);
        autoblksenableparameters(Block,{'BattCapInit'},{});
        switch OutputVlt
        case 'Unfiltered'
            autoblksreplaceblock(Block,FilterOptions,1);
            autoblksenableparameters(Block,{},{'Tc','Vinit'});
        case 'Filtered'
            autoblksreplaceblock(Block,FilterOptions,2);
            autoblksenableparameters(Block,{'Tc','Vinit'},{});
        end
    case 'External Input'
        autoblksreplaceblock(Block,BatteryOptions,2);
        autoblksenableparameters(Block,{},{'BattCapInit'});
        switch OutputVlt
        case 'Unfiltered'
            autoblksreplaceblock(Block,FilterOptions,1);
            autoblksenableparameters(Block,{},{'Tc','Vinit'});
        case 'Filtered'
            autoblksreplaceblock(Block,FilterOptions,2);
            autoblksenableparameters(Block,{'Tc','Vinit'},{});
        end
    end

    ParamList={'BattChargeMax',[1,1],{'gt',0;};...
    'Ns',[1,1],{'gt',0};...
    'Np',[1,1],{'gt',0};...
    'Tc',[1,1],{'gt',0};...
    'Vinit',[1,1],{'gte',0};...
    };

    EmTblBpt={'CapLUTBp',{'gte',0;'lte',1}};
    RTblBpt={'BattTempBp',{'gt',0},'CapSOCBp',{'gte',0;'lte',1}};

    LookupTblList={EmTblBpt,'Em',{'gte',0};...
    RTblBpt,'RInt',{'gte',0};};

    autoblkscheckparams(Block,'Datasheet Battery',ParamList,LookupTblList);

end

function Plot()

end