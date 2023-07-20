






































function[modifiedComponents,modifiedValues,doseTargets,doseModifications,algebraicComponents]=getModifiedInitialValues(model,configset,variants,doses)
    if isempty(configset)
        configset=model.getconfigset('active');
    end

    if~isa(configset.SolverOptions,'SimBiology.ODESolverOptions')
        error(message('SimBiology:getModifiedInitialValues:DeterministicSolverRequired'));
    end
    try
        SimBiology.internal.verifyHelper(model,configset,variants,doses,"RequireObservableDependencies",false);
    catch cause
        exceptionEnvelope=MException(message('SimBiology:getModifiedInitialValues:CompilationError'));
        exceptionEnvelope=addCause(exceptionEnvelope,cause);
        throw(exceptionEnvelope);
    end
    odedata=model.ODESimulationData;
    [initialStateValues,parameterValues]=SimBiology.internal.getInitialValues(odedata);
    initialConditions=[initialStateValues(:);parameterValues(:)];
    allStateUuids=[odedata.XUuids;odedata.PUuids];
    components=SimBiology.internal.getModelObjectsForUuids(model,allStateUuids);
    componentValues=vertcat(components.Value);
    [doseTargets,doseModifications]=getDoseModifications(model,configset,doses,components,initialConditions,odedata.PKCompileData.spCvsAInfo);


    initialConditionsUpdated=applyRepeatedAssignments(odedata,initialConditions,doseTargets,doseModifications);
    tfModified=initialConditionsUpdated~=componentValues;
    modifiedComponents=components(tfModified);
    modifiedValues=initialConditionsUpdated(tfModified);
    algebraicComponents=SimBiology.internal.getModelObjectsForUuids(model,odedata.algebraicXUuids);
end

function[doseTargets,doseModifications]=getDoseModifications(model,configset,doses,components,componentValues,spCvsAInfo)
    targetMap=containers.Map('KeyType','char','ValueType','any');
    modificationMap=containers.Map('KeyType','char','ValueType','double');

    valueMap=containers.Map({components.UUID},componentValues);
    unitConversion=configset.CompileOptions.UnitConversion;
    for i=1:numel(doses)
        dose=doses(i);
        target=resolvetarget(dose,model);
        assert(~isempty(target),'Dose target should have resolved if model compiled successfully.')








        if isa(dose,'SimBiology.RepeatDose')
            startTimeValue=getRepeatDosePropertyValueAndUnits(dose,model,valueMap,'StartTime');
            rateValue=getRepeatDosePropertyValueAndUnits(dose,model,valueMap,'Rate');
            if startTimeValue>0

                continue
            end
            if rateValue>0

                continue
            end


            [amount,amountUnits]=getRepeatDosePropertyValueAndUnits(dose,model,valueMap,'Amount','AmountUnits');
        elseif isa(dose,'SimBiology.ScheduleDose')



            index=(dose.Time==0);
            if isempty(index)

                continue
            end
            if~isempty(dose.Rate)

                index=index&(dose.Rate==0);
            end
            amount=sum(dose.Amount(index));
            amountUnits=dose.AmountUnits;
        end


        if amount==0
            continue
        end


        if~isempty(dose.DurationParameterName)
            continue
        end


        if~isempty(dose.LagParameterName)
            lag=resolveparameter(dose,model,dose.LagParameterName);
            lagValue=valueMap(lag.UUID);
            if lagValue>0
                continue
            end
        end



        if spCvsAInfo.SpeciesInConcentration(spCvsAInfo.speciesMap(target.UUID))

            compartment=target.Parent;
            volume=valueMap(compartment.UUID);
            change=amount/volume;
            changeUnits=[amountUnits,'/',compartment.CapacityUnits];
        else
            change=amount;
            changeUnits=amountUnits;
        end
        if unitConversion

            change=sbiounitcalculator(changeUnits,target.InitialAmountUnits,change);
        end


        if modificationMap.isKey(target.UUID)


            change=modificationMap(target.UUID)+change;
        else


            targetMap(target.UUID)=target;
        end
        modificationMap(target.UUID)=change;
    end


    doseTargets=targetMap.values;
    doseTargets=[doseTargets{:}];
    doseModifications=modificationMap.values(get(doseTargets,{'UUID'}));
    doseModifications=[doseModifications{:}];
end



function[value,units]=getRepeatDosePropertyValueAndUnits(dose,model,valueMap,propertyName,unitsPropertyName)
    if isnumeric(dose.(propertyName))
        value=dose.(propertyName);
        if nargout>1
            units=dose.(unitsPropertyName);
        end
    else
        param=dose.resolveparameter(model,dose.(propertyName));
        value=valueMap(param.UUID);
        if nargout>1
            units=param.ValueUnits;
        end
    end
end

function initialConditions=applyRepeatedAssignments(odedata,initialConditions,doseTargets,doseModifications)

    repeatedCode=odedata.RepeatedCodeGenerator;
    if isempty(repeatedCode)||isempty(doseModifications)

        return
    end

    [~,doseTargetIndex]=ismember(get(doseTargets,{'UUID'}),odedata.XUuids);
    numStates=numel(odedata.XUuids);
    initialStatesAfterDoses=initialConditions(1:numStates);
    initialStatesAfterDoses(doseTargetIndex)=initialStatesAfterDoses(doseTargetIndex)+doseModifications(:);


    if~isempty(odedata.XUCM)
        xAfterDoses=initialStatesAfterDoses.*odedata.XUCM(:);
    else
        xAfterDoses=initialStatesAfterDoses;
    end



    xAfterDoses=SimBiology.internal.convertStateVector.toAmount(xAfterDoses,...
    odedata.P,odedata.speciesIndexToConstantCompartment,...
    odedata.speciesIndexToVaryingCompartment);

    pAfterRepeatedAssignments=feval(repeatedCode.mFunctionName,0,xAfterDoses,odedata.P);
    if~isempty(odedata.PUCM)
        paramValuesAfterRepeatedAssignments=pAfterRepeatedAssignments./odedata.PUCM(:);
    else
        paramValuesAfterRepeatedAssignments=pAfterRepeatedAssignments;
    end
    initialConditions(numStates+1:end)=paramValuesAfterRepeatedAssignments;
end