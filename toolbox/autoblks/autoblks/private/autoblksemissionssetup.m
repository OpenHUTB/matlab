function varargout=autoblksemissionssetup(varargin)




    SpeciesNames={'BurnedGas','CO2','CO','NOx','HC','PM','NO','NO2'};
    MassFracBusNames={'BrndGasMassFrac','CO2MassFrac','COMassFrac','NOxMassFrac','UnbrndFuelMassFrac','PmMassFrac','NOMassFrac','NO2MassFrac'};



    varargout{1}=0;
    Block=varargin{1};

    switch varargin{2}
    case 'CheckboxCallback'
        CheckboxCallback(Block,SpeciesNames);
    case 'ReturnSelectedSpecies'
        varargout{1}=ReturnSelectedSpecies(Block,SpeciesNames,MassFracBusNames);
    case 'CheckTables'
        CheckTables(Block,SpeciesNames);
    end

end

function[BlockSpecies,SpeciesOn,SpeciesOff]=FindSelectedSpecies(Block,SpeciesNames,ReturnTblName)


    DialogParams=get_param(Block,'DialogParameters');
    SpeciesOn={};
    SpeciesOff={};
    if nargin<3
        ReturnTblName=false;
    end


    for i=1:length(SpeciesNames)
        ParamName=[SpeciesNames{i},'EmissionsCheckbox'];
        if isfield(DialogParams,ParamName)
            if strcmp(get_param(Block,ParamName),'on')
                SpeciesOn=[SpeciesOn,SpeciesNames{i}];
            else
                SpeciesOff=[SpeciesOff,SpeciesNames{i}];
            end

        end
    end


    if ReturnTblName
        for i=1:length(SpeciesOn)
            SpeciesOn{i}=['f_',SpeciesOn{i},'_frac'];
        end
        for i=1:length(SpeciesOff)
            SpeciesOff{i}=['f_',SpeciesOff{i},'_frac'];
        end

    end


    BlockSpecies=[SpeciesOn,SpeciesOff];

end


function SelectedSpecies=ReturnSelectedSpecies(Block,SpeciesNames,MassFracBusNames)
    [~,SelectedSpecies]=FindSelectedSpecies(Block,SpeciesNames,false);
    [~,SelectedSpeciesIdx]=intersect(SpeciesNames,SelectedSpecies,'stable');
    SelectedSpecies=cellstr(MassFracBusNames(SelectedSpeciesIdx));
end


function CheckboxCallback(Block,SpeciesNames)
    [~,SpeciesOn,SpeciesOff]=FindSelectedSpecies(Block,SpeciesNames,true);

    if~isempty(SpeciesOn)
        autoblksenableparameters(Block,['f_exhfrac_n_bpt','f_exhfrac_trq_bpt',SpeciesOn],SpeciesOff);
    else
        autoblksenableparameters(Block,SpeciesOn,['f_exhfrac_n_bpt','f_exhfrac_trq_bpt',SpeciesOff]);
    end

end


function CheckTables(Block,SpeciesNames)

    [~,SelectedSpecies]=FindSelectedSpecies(Block,SpeciesNames,true);

    RowCheck={{'f_exhfrac_trq_bpt',{},'f_exhfrac_n_bpt',{'gte',0;'lte',17e3}},'',{'gte',0;'lte',1}};
    LookupTblList=repmat(RowCheck,length(SelectedSpecies),1);

    for i=1:size(LookupTblList,1)
        LookupTblList{i,2}=SelectedSpecies{i};
    end

    if~isempty(LookupTblList)
        autoblkscheckparams(Block,{},LookupTblList);
    end

end
