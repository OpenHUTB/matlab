function[varargout]=autoblksmassfracbussetup(varargin)






    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'SetupInit'
        varargout{1}=SetupInit(Block);
    case 'SelectorInit'
        varargout{1}=SelectorInit(Block);
    case 'StopFcn'
        StopFcn(Block);
    end

end


function M=SetupInit(Block)

    AllMassFrac=autoblkssetupengflwmassfrac(Block,'GetAllMassFracs');
    if isempty(AllMassFrac)
        M=[];
        return;
    end
    NumMassFrac=length(AllMassFrac);
    autoblksgetmaskparms(Block,{'InputMassFracNames'},true);
    M.NumMassFracIn=length(InputMassFracNames);

    [~,M.FuelInputIdx]=intersect(InputMassFracNames,'UnbrndFuelMassFrac');
    [~,M.O2InputIdx]=intersect(InputMassFracNames,'O2MassFrac');
    [~,M.NOInputIdx]=intersect(InputMassFracNames,'NOMassFrac');
    [~,M.NO2InputIdx]=intersect(InputMassFracNames,'NO2MassFrac');

    AirObj=autoblkssetupengflwmassfrac(Block,'AirObj');
    if~isempty(AirObj)
        M.AirO2MassFrac=AirObj.MassFracStruct.O2MassFrac;
    end

    AirBurnCalcOptions={'autolibfundflwcommon/Derived Air and Burned Mass Fraction','Derived Air and Burned Mass Fraction';...
    'autolibfundflwcommon/Air and Burned Mass Fraction Not Derived','Air and Burned Mass Fraction Not Derived'};

    if~isempty(M.FuelInputIdx)&&~isempty(M.O2InputIdx)&&~any(strcmp(InputMassFracNames,'AirMassFrac'))
        autoblksreplaceblock(Block,AirBurnCalcOptions,1);
        InputMassFracNames=[InputMassFracNames,'AirMassFrac','BrndGasMassFrac'];
    else
        autoblksreplaceblock(Block,AirBurnCalcOptions,2);
    end


    NOxCalcBlkOptions={'autolibfundflwcommon/Derived NOx Mass Fraction','Derived NOx Mass Fraction';...
    'autolibfundflwcommon/NOx Mass Fraction Not Derived','NOx Mass Fraction Not Derived'};

    if~isempty(M.NOInputIdx)&&~isempty(M.NO2InputIdx)
        autoblksreplaceblock(Block,NOxCalcBlkOptions,1);
        InputMassFracNames=[InputMassFracNames,'NOxMassFrac'];
    else
        autoblksreplaceblock(Block,NOxCalcBlkOptions,2);
    end


    SelectorOptions={'autolibfundflwcommon/Mass Fraction Selector','Mass Fraction Selector';...
    'autolibfundflwcommon/No Mass Fractions Selected','No Mass Fractions Selected'};
    InputMassFracNames=unique(InputMassFracNames,'stable');

    [~,IInputMassFrac,IMassFrac]=intersect(InputMassFracNames,AllMassFrac,'stable');
    if~isempty(IMassFrac)
        autoblksreplaceblock(Block,SelectorOptions,1);
    else
        autoblksreplaceblock(Block,SelectorOptions,2);
    end
    M.MassFracIdx=(M.NumMassFracIn+4)*ones(1,NumMassFrac);
    M.MassFracIdx(IMassFrac)=IInputMassFrac;

end


function M=SelectorInit(Block)
    AllMassFrac=autoblkssetupengflwmassfrac(Block,'GetAllMassFracs');
    if isempty(AllMassFrac)
        M=[];
        return;
    end
    M.NumMassFracIn=length(AllMassFrac);
    autoblksgetmaskparms(Block,{'OutputMassFracNames'},true);
    [~,~,M.MassFracIdx]=intersect(OutputMassFracNames,AllMassFrac,'stable');

end


function StopFcn(Block)

    autoblkssetupengflwmassfrac(Block);
end
