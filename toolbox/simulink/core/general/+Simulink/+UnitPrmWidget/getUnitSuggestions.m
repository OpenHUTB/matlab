function suggestions=getUnitSuggestions(text,source,...
    includeDefaultSuggestions)

    if nargin<3||isempty(includeDefaultSuggestions)
        includeDefaultSuggestions=true;
    end
    if nargin<2
        source=[];
    end

    blockHandle=[];sourceIsUnitQueryClient=false;mdlName='';
    if~isempty(source)
        if~isa(source,'Simulink.UnitQueryClient')
            blockHandle=source;
            mdlName=get(bdroot(source),'Name');
        else
            sourceIsUnitQueryClient=true;
        end
    end

    if~sourceIsUnitQueryClient
        allUnitSys=Simulink.UnitUtils.getFullList(mdlName,'UnitSystems');
    else
        allUnitSys=source.getFullList('UnitSystems');
    end

    if~sourceIsUnitQueryClient
        try
            allowedUnitSys=Simulink.UnitConfiguratorBlockMgr.getUnitSystems(blockHandle);
        catch
            allowedUnitSys=allUnitSys;
        end
    else
        allowedUnitSys=allUnitSys;
    end
    allowedUnitSysStrArray={allowedUnitSys.Name};
    allUnitSysStrArray={allUnitSys.Name};

    try
        if~sourceIsUnitQueryClient
            [textPrefix,units]=Simulink.UnitUtils.getAutoCompleteList(mdlName,text);
        else
            [textPrefix,units]=source.getAutoCompleteList(text);
        end
    catch

        units='';
    end
    resultSet={};

    defaultSuggestions={'inherit'};
    if isempty(textPrefix)&&includeDefaultSuggestions




        result_idx=1;
        for idx=1:length(defaultSuggestions)
            if(strncmpi(defaultSuggestions{idx},text,length(text)))
                resultSet{result_idx}=' ';
                result_idx=result_idx+1;
                resultSet{result_idx}=defaultSuggestions{idx};
                result_idx=result_idx+1;
                resultSet{result_idx}=defaultSuggestions{idx};
                result_idx=result_idx+1;
            end
        end
    end



    if(isempty(setdiff(allUnitSysStrArray,allowedUnitSysStrArray)))
        for idx=1:numel(units)
            resultSet=addToResultList(resultSet,textPrefix,units(idx));
        end
    else

        for idx=1:numel(units)
            unitSystemStr=units(idx).UnitSystem;
            unitSystemArray=strsplit(unitSystemStr,',');

            if(isempty(unitSystemArray)||any(ismember(allowedUnitSysStrArray,unitSystemArray)))
                resultSet=addToResultList(resultSet,textPrefix,units(idx));
            end
        end
    end
    suggestions=resultSet;
    if~sourceIsUnitQueryClient
        possibleCorrection=Simulink.UnitUtils.getBestApproximation(mdlName,text);
    else
        possibleCorrection=source.getBestApproximation(text);
    end
    if(~strncmp(possibleCorrection,text,length(possibleCorrection)))
        suggestions={'toolbox/shared/dastudio/resources/yellow_star.svg',...
        possibleCorrection,'',suggestions{:}};
    end

end

function[resultSet]=addToResultList(resultSet,textPrefix,unitObj)
    result_idx=length(resultSet)+1;
    resultSet{result_idx}=' ';
    result_idx=result_idx+1;

    if isa(unitObj,'Simulink.Unit')
        resultSet{result_idx}=[textPrefix,unitObj.Symbol];
    elseif isa(unitObj,'Simulink.PhysicalQuantity')
        resultSet{result_idx}=[textPrefix,unitObj.Name];
    end
    result_idx=result_idx+1;
    resultSet{result_idx}=[textPrefix,unitObj.Name];
    if isa(unitObj,'Simulink.Unit')&&strcmp(unitObj.ASCIISymbol,unitObj.Symbol)==0
        result_idx=result_idx+1;
        resultSet{result_idx}=' ';
        result_idx=result_idx+1;
        resultSet{result_idx}=[' ',textPrefix,unitObj.ASCIISymbol];
        result_idx=result_idx+1;
        resultSet{result_idx}=[' ',textPrefix,unitObj.Name];
    end
end
