function[varargout]=autoblksrcbattery(varargin)



    varargout{1}={};

    Block=varargin{1};
    Context=varargin{2};
    switch Context
    case 'Initialization'
        Initialization(Block);
    case 'DrawCommands'
        varargout{1}=DrawCommands(Block);
    case 'NumRCPopup'
        NumRCPopup(Block);
    end
end

function IconInfo=DrawCommands(Block)

    AliasNames={};
    IconInfo=autoblksgetportlabels(Block,AliasNames);


    IconInfo.ImageName='energy_battery_rc.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,0.9,60,150,'white');
end

function Initialization(Block)
    BattOptions=...
    {'autolibbatterycommon/1RC Internal','1RC Internal';
    'autolibbatterycommon/2RC Internal','2RC Internal';
    'autolibbatterycommon/3RC Internal','3RC Internal';
    'autolibbatterycommon/4RC Internal','4RC Internal';
    'autolibbatterycommon/5RC Internal','5RC Internal';
    'autolibbatterycommon/1RC External','1RC External';
    'autolibbatterycommon/2RC External','2RC External';
    'autolibbatterycommon/3RC External','3RC External';
    'autolibbatterycommon/4RC External','4RC External';
    'autolibbatterycommon/5RC External','5RC External';
    };

    FilterOptions=...
    {'autolibbatterycommon/Output Passthrough','Output Passthrough';
    'autolibbatterycommon/Output Filter','Output Filter';
    };

    CapacityCtrl=get_param(Block,'CapacityCtrl');
    OutputVlt=get_param(Block,'OutputVlt');

    NumRC=str2double(get_param(Block,'NumRC'));

    switch NumRC
    case '1'
        autoblksenableparameters(Block,{'R1','C1'},{'R2','C2','R3','C3','R4','C4','R5','C5'});
    case '2'
        autoblksenableparameters(Block,{'R1','C1','R2','C2'},{'R3','C3','R4','C4','R5','C5'});
    case '3'
        autoblksenableparameters(Block,{'R1','C1','R2','C2','R3','C3'},{'R4','C4','R5','C5'});
    case '4'
        autoblksenableparameters(Block,{'R1','C1','R2','C2','R3','C3','R4','C4'},{'R5','C5'});
    case '5'
        autoblksenableparameters(Block,{'R1','C1','R2','C2','R3','C3','R4','C4','R5','C5'},[]);
    end

    switch CapacityCtrl
    case 'Parameter'
        autoblksenableparameters(Block,{'BattCapInit'},{});
        switch NumRC
        case 1
            autoblksreplaceblock(Block,BattOptions,1);
        case 2
            autoblksreplaceblock(Block,BattOptions,2);
        case 3
            autoblksreplaceblock(Block,BattOptions,3);
        case 4
            autoblksreplaceblock(Block,BattOptions,4);
        case 5
            autoblksreplaceblock(Block,BattOptions,5);
        end
    case 'External Input'
        autoblksenableparameters(Block,{},{'BattCapInit'});
        switch NumRC
        case 1
            autoblksreplaceblock(Block,BattOptions,6);
        case 2
            autoblksreplaceblock(Block,BattOptions,7);
        case 3
            autoblksreplaceblock(Block,BattOptions,8);
        case 4
            autoblksreplaceblock(Block,BattOptions,9);
        case 5
            autoblksreplaceblock(Block,BattOptions,10);
        end
    end

    switch OutputVlt
    case 'Unfiltered'
        autoblksreplaceblock(Block,FilterOptions,1);
        autoblksenableparameters(Block,{},{'Tc','Vinit'});
    case 'Filtered'
        autoblksreplaceblock(Block,FilterOptions,2);
        autoblksenableparameters(Block,{'Tc','Vinit'},{});
    end


    MaskObject=get_param(Block,'MaskObject');
    WsVars=MaskObject.getWorkspaceVariables;
    BattCap=WsVars(1).Value;

    BattCapMax=max(BattCap);

    ParamList={'BattCapInit',[1,1],{'gte',0;'lte',BattCapMax};...
    'InitialCapVoltage',[1,NumRC],{};
    'Tc',[1,1],{'gt',0};
    'Vinit',[1,1],{'gte',0};};

    LookupTblList0={{'SOC_BP',{'gte',0;'lte',1},'Temperature_BP',{'gte',0}},'Em',{'gt',0};...
    {'SOC_BP',{},'Temperature_BP',{}},'R0',{'gt',0};...
    {'Temperature_BP',{}},'BattCap',{'gt',0}};
    LookupTblList1={{'SOC_BP',{},'Temperature_BP',{}},'R1',{'gt',0};...
    {'SOC_BP',{},'Temperature_BP',{}},'C1',{'gt',0}};
    LookupTblList2={{'SOC_BP',{},'Temperature_BP',{}},'R2',{'gt',0};...
    {'SOC_BP',{},'Temperature_BP',{}},'C2',{'gt',0};};
    LookupTblList3={{'SOC_BP',{},'Temperature_BP',{}},'R3',{'gt',0};...
    {'SOC_BP',{},'Temperature_BP',{}},'C3',{'gt',0};};
    LookupTblList4={{'SOC_BP',{},'Temperature_BP',{}},'R4',{'gt',0};...
    {'SOC_BP',{},'Temperature_BP',{}},'C4',{'gt',0};};
    LookupTblList5={{'SOC_BP',{},'Temperature_BP',{}},'R5',{'gt',0};...
    {'SOC_BP',{},'Temperature_BP',{}},'C5',{'gt',0};};

    switch NumRC
    case 1
        LookupTblList=cat(1,LookupTblList0,LookupTblList1);
    case 2
        LookupTblList=cat(1,LookupTblList0,LookupTblList1,LookupTblList2);
    case 3
        LookupTblList=cat(1,LookupTblList0,LookupTblList1,LookupTblList2,LookupTblList3);
    case 4
        LookupTblList=cat(1,LookupTblList0,LookupTblList1,LookupTblList2,LookupTblList3,LookupTblList4);
    case 5
        LookupTblList=cat(1,LookupTblList0,LookupTblList1,LookupTblList2,LookupTblList3,LookupTblList4,LookupTblList5);
    otherwise
        LookupTblList=[];
    end

    autoblkscheckparams(Block,'Estimation Equivalent Circuit Battery',ParamList,LookupTblList);

end

function NumRCPopup(Block)

    NumRC=get_param(Block,'NumRC');

    switch NumRC
    case '1'
        autoblksenableparameters(Block,{'R1','C1'},{'R2','C2','R3','C3','R4','C4','R5','C5'});
    case '2'
        autoblksenableparameters(Block,{'R1','C1','R2','C2'},{'R3','C3','R4','C4','R5','C5'});
    case '3'
        autoblksenableparameters(Block,{'R1','C1','R2','C2','R3','C3'},{'R4','C4','R5','C5'});
    case '4'
        autoblksenableparameters(Block,{'R1','C1','R2','C2','R3','C3','R4','C4'},{'R5','C5'});
    case '5'
        autoblksenableparameters(Block,{'R1','C1','R2','C2','R3','C3','R4','C4','R5','C5'},[]);
    end


    NumRC_val=str2double(NumRC);
    InitialCapVoltage=zeros(1,NumRC_val);
    autolibseteditparamval(Block,'InitialCapVoltage',InitialCapVoltage);

end