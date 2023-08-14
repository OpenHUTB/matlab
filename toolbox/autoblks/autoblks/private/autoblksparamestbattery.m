function[varargout]=autoblksparamestbattery(varargin)



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


    IconInfo.ImageName='estimate-battery.png';
    [IconInfo.image,IconInfo.position]=iconImageUpdate(IconInfo.ImageName,0.9,60,150,'white');
end

function Initialization(Block)
    BatteryOptions=...
    {'autolibbatterycommon/PE 1RC','PE 1RC';
    'autolibbatterycommon/PE 2RC','PE 2RC';
    'autolibbatterycommon/PE 3RC','PE 3RC';
    'autolibbatterycommon/PE 4RC','PE 4RC';
    'autolibbatterycommon/PE 5RC','PE 5RC';
    };

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

    switch NumRC
    case 1
        autoblksreplaceblock(Block,BatteryOptions,1);
    case 2
        autoblksreplaceblock(Block,BatteryOptions,2);
    case 3
        autoblksreplaceblock(Block,BatteryOptions,3);
    case 4
        autoblksreplaceblock(Block,BatteryOptions,4);
    case 5
        autoblksreplaceblock(Block,BatteryOptions,5);
    end

    ParamList={'BattCap',[1,1],{'gt',0};...
    'BattCapInit',[1,1],{'gte',0;'lte','BattCap'};...
    'InitialCapVoltage',[1,NumRC],{};};

    LookupTblList0={{'SOC_BP',{'gte',0;'lte',1}},'Em',{'gt',0};...
    {'SOC_BP',{'gte',0;'lte',1}},'R0',{'gt',0};};
    LookupTblList1={{'SOC_BP',{'gte',0;'lte',1}},'R1',{'gt',0};...
    {'SOC_BP',{'gte',0;'lte',1}},'C1',{'gt',0};};
    LookupTblList2={{'SOC_BP',{'gte',0;'lte',1}},'R2',{'gt',0};...
    {'SOC_BP',{'gte',0;'lte',1}},'C2',{'gt',0};};
    LookupTblList3={{'SOC_BP',{'gte',0;'lte',1}},'R3',{'gt',0};...
    {'SOC_BP',{'gte',0;'lte',1}},'C3',{'gt',0};};
    LookupTblList4={{'SOC_BP',{'gte',0;'lte',1}},'R4',{'gt',0};...
    {'SOC_BP',{'gte',0;'lte',1}},'C4',{'gt',0};};
    LookupTblList5={{'SOC_BP',{'gte',0;'lte',1}},'R5',{'gt',0};...
    {'SOC_BP',{'gte',0;'lte',1}},'C5',{'gt',0};};

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