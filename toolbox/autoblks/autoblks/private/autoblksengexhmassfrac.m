function[varargout]=autoblksengexhmassfrac(varargin)






    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'Initialization'
        varargout{1}=Initialization(Block);
    end

end


function M=Initialization(Block)


    AllMassFracs=autoblkssetupengflwmassfrac(Block,'GetAllMassFracs');

    if isempty(AllMassFracs)
        M=[];
        return;
    end
    autoblksgetmaskparms(Block,{'DefinedProdSpecies'},true);
    DefinedProdSpecies=cellstr(DefinedProdSpecies);



    if isempty(DefinedProdSpecies)
        M.NumDefined=1;
        M.UnburnedFuelIdx=2;
        DefinedProdSpecies={'EmptyInput'};
    else
        M.NumDefined=length(DefinedProdSpecies);
        [~,M.UnburnedFuelIdx]=intersect(DefinedProdSpecies,'UnburnedFuel','stable');
        if isempty(M.UnburnedFuelIdx)
            M.UnburnedFuelIdx=M.NumDefined+1;
        end

    end


    BurnedGasCalcOptions={'autolibcoreengcommon/Derive Exhaust Burned Gas Fraction','Derive Exhaust Burned Gas Fraction';...
    'autolibcoreengcommon/Exhaust Burned Gas Fraction Direct Lookup','Exhaust Burned Gas Fraction Direct Lookup'};
    if~any(strcmp(DefinedProdSpecies,'BurnedGas'))
        autoblksreplaceblock(Block,BurnedGasCalcOptions,1);
        M.BurnedGasIdx=0;
        M.MassFracNames=[DefinedProdSpecies,'BrndGasMassFrac','AirMassFrac'];
    else
        autoblksreplaceblock(Block,BurnedGasCalcOptions,2);
        [~,M.BurnedGasIdx]=intersect(DefinedProdSpecies,'BrndGasMassFrac','stable');
        M.MassFracNames=[DefinedProdSpecies,'EmptyInput','AirMassFrac'];
    end

end
