function pkdatacompile(data,compiledModelMap,dimensionalAnalysis,unitConversion)



















    assert(isa(data,'PKData'));
    assert(isa(compiledModelMap,'struct'));

    if isempty(data.DependentVarLabel)
        error(message('SimBiology:PKDataCompile:INVALID_DEPENDENTVARLABEL'));
    end
    if numel(unique(data.DependentVarLabel))~=numel(data.DependentVarLabel)
        warning(message('SimBiology:PKDataCompile:DUPLICATE_DEPENDENTVARLABEL'));
    end
    if numel(compiledModelMap.Observed)~=numel(data.DependentVarLabel)
        error(message('SimBiology:PKDataCompile:INVALID_DEPENDENTVARLABEL2'));
    end

    if isempty(data.IndependentVarLabel)
        error(message('SimBiology:PKDataCompile:INVALID_INDEPENDENTVARLABEL'));
    end

    if~CheckSortedIVar(data)
        error(message('SimBiology:PKDataCompile:INDEPENDENT_VAR_NOT_SORTED'));
    end
    if~CheckUniqueDoses(data)
        error(message('SimBiology:PKDataCompile:DUPLICATE_DOSES'));
    end


    dosingTypes=compiledModelMap.DosingType;
    doseLabels=data.DoseLabel;
    rateLabels=data.RateLabel;



    if~isempty(rateLabels)&&(numel(doseLabels)~=numel(rateLabels))
        error(message('SimBiology:PKDataCompile:INVALID_RATELABELS'));
    end



    if~isempty(dosingTypes)&&(numel(dosingTypes)~=numel(doseLabels))
        error(message('SimBiology:PKDataCompile:INVALID_DOSELABELS'));
    end



    doseUnits=data.DoseUnits;
    if~isempty(doseUnits)&&(numel(doseUnits)~=numel(doseLabels))
        error(message('SimBiology:PKDataCompile:INVALID_DOSEUNITS'));
    end



    rateUnits=data.RateUnits;
    if~isempty(rateUnits)&&ischar(rateUnits)
        rateUnits={rateUnits};
    end
    if isempty(rateLabels)&&~isempty(rateUnits)
        error(message('SimBiology:PKDataCompile:INVALID_RATEUNITS'));
    end

    if~isempty(rateUnits)&&(numel(rateUnits)~=numel(rateLabels))
        error(message('SimBiology:PKDataCompile:INVALID_RATEUNITS'));
    end



    for i=1:length(dosingTypes)
        if strcmp(dosingTypes{i},'Infusion')
            if isempty(rateLabels)||isempty(rateLabels{i})
                error(message('SimBiology:PKDataCompile:EMPTYRATELABEL_WITH_INFUSION'));
            end
        end
    end


    if dimensionalAnalysis


        if unitConversion



            if isempty(data.IndependentVarUnits)
                error(message('SimBiology:PKDataCompile:INVALID_INDEPENDENTVARUNITS'));
            end

            if isempty(data.DependentVarUnits)
                error(message('SimBiology:PKDataCompile:INVALID_DEPENDENTVARUNITS'));
            end
        end

        dependentVarUnits=data.DependentVarUnits;
        if~unitConversion&&isempty(dependentVarUnits)



            dependentVarUnits=repmat({''},1,numel(data.DependentVarLabel));
        elseif numel(compiledModelMap.ObservedUnits)~=numel(dependentVarUnits)
            error(message('SimBiology:PKDataCompile:INVALID_OBSERVEDUNITS'));
        end

        match=false(1,numel(compiledModelMap.ObservedUnits));
        for i=1:numel(compiledModelMap.ObservedUnits)
            match(i)=verifyDependentVarUnitsMatch(compiledModelMap.ObservedUnits{i},dependentVarUnits{i},unitConversion);
        end
        if~all(match)
            badObsUnits=compiledModelMap.ObservedUnits(~match);
            badDepUnits=dependentVarUnits(~match);
            unitMessageCell=cell(size(badObsUnits));
            for j=1:numel(unitMessageCell)
                unitMessageCell{j}=getString(message('SimBiology:PKDataCompile:INVALID_DEPENDENTVARUNITS2_EXTRA',badObsUnits{j},badDepUnits{j}));
            end
            error(message('SimBiology:PKDataCompile:INVALID_DEPENDENTVARUNITS2',[unitMessageCell{:}]));
        end










        if~unitConversion&&isempty(doseUnits)



            doseUnits=repmat({''},1,numel(doseLabels));
        elseif numel(doseLabels)~=numel(doseUnits)
            error('SimBiology:PKDataCompile:INVALID_DOSEUNITS','OBSERVEDDATA.DoseUnits must be specified for each dose column when simulating a model with DimensionalAnalysis on.');
        end

        dosedObj=compiledModelMap.Dosed;
        for i=1:numel(doseUnits)

            if unitConversion&&isempty(doseUnits{i})
                error('SimBiology:PKDataCompile:INVALID_DOSEUNITS','OBSERVEDDATA.DoseUnits must be specified for each dose column when simulating a model with UnitConversion on.');
            end



            match=verifyDoseUnitsMatch(dosedObj(i).InitialAmountUnits,doseUnits{i},unitConversion);
            if~match
                error('SimBiology:PKDataCompile:INVALID_DOSEUNITS','OBSERVEDDATA.DoseUnits must be consistent with the units on MODELMAP.Dosed when simulating a model with DimensionalAnalysis on.');
            end
        end




        if~unitConversion&&isempty(rateUnits)



            rateUnits=repmat({''},1,numel(rateLabels));
        elseif(numel(rateLabels)~=numel(rateUnits))
            error('SimBiology:PKDataCompile:INVALID_RATEUNITS','OBSERVEDDATA.RateUnits must be specified for each rate column when simulating a model with DimensionalAnalysis on.');
        end

        for i=1:numel(rateLabels)
            if isempty(rateLabels{i})

                continue
            end



            if unitConversion&&isempty(rateUnits{i})
                error('SimBiology:PKDataCompile:INVALID_RATEUNITS','OBSERVEDDATA.RateUnits must be specified for each rate column when simulating a model with UnitConversion on.');
            end


            match=verifyDoseUnitsMatch(dosedObj(i).InitialAmountUnits,rateUnits{i},unitConversion);
            if~match
                error('SimBiology:PKDataCompile:INVALID_RATEUNITS','OBSERVEDDATA.RateUnits must be consistent with the units on MODELMAP.Dosed when simulating a model with DimensionalAnalysis on.');
            end
        end
    end
end

function match=verifyDoseUnitsMatch(unit1,unit2,unitConversion)
    if isempty(unit1)||isempty(unit2)


        match=~unitConversion;
        return
    end

    [~,qdObj1]=SimBiology.internal.getPhysicalQuantityFromComposition(unit1);
    [~,qdObj2]=SimBiology.internal.getPhysicalQuantityFromComposition(unit2);



    match=(qdObj1.Amount==qdObj2.Amount)&&(qdObj1.Mass==qdObj2.Mass);
end

function match=verifyDependentVarUnitsMatch(unit1,unit2,unitConversion)
    if isempty(unit1)||isempty(unit2)


        match=~unitConversion;
        return
    end
    match=SimBiology.internal.areUnitsValidAndConsistent(unit1,unit2);
end