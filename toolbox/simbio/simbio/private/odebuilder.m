function odebuilder(caller,varargin)

    try
        switch lower(caller)
        case 'odecompile'
            localFullCompile(varargin{:});
        case 'initialconditions'
            localInitialConditionsCompile(varargin{:});
        otherwise
            error(message('SimBiology:odebuilder:INTERNAL_ERROR_UNKNOWNCALLER'));
        end
    catch ME
        rethrow(ME);
    end

end


function localInitialConditionsCompile(odedata,cdata,numSensitivityInputs)
    [X0,P]=localSetInitialValues(cdata.componentInitialValues,...
    odedata.X0Objects,odedata.PObjects,...
    odedata.XUCM,odedata.PUCM);

    odedata.PKCompileData.X0BeforeInitAsgns=X0;
    odedata.PKCompileData.PBeforeInitAsgns=P;

    [X0,P]=localEvaluateRulesAtTime0(...
    X0,P,odedata.Code.initialAssignRuleStr,...
    odedata.X0Objects,odedata.PObjects);

    if odedata.SensitivityAnalysis
        odedata.Sens0=updateSens0ForConcentrations(odedata,X0);
    end

    [X0,P]=SimBiology.internal.convertStateVector.toAmount(X0,P,...
    odedata.speciesIndexToConstantCompartment,...
    odedata.speciesIndexToVaryingCompartment);

    dU_dP=localSetInputSensitivityInitialValues(odedata.SensitivityAnalysis,numel(X0),numSensitivityInputs);
    odedata.X0=X0;
    U0=zeros(size(X0));
    odedata.U=[U0;dU_dP(:)];
    odedata.P=P;
end


function localFullCompile(modelIn,configset,doses,cdata,codeGenFlag)


    localPreCompileChecks(modelIn);
    [cmodel,cdata]=privatecompilemodelhierarchy(modelIn,cdata,doses);




    assert(~isempty([cmodel.rateX;cmodel.doseRateX;cmodel.speciesRateX;cmodel.reactionX;cmodel.constantX]),...
    message('SimBiology:odebuilder:NOTHING_TO_SIMULATE'));

    cmodel.cdata=cdata;
    cmodel=localBuildMaps(modelIn,cmodel);
    cmodel=localUnitConversionSetup(cmodel,cdata.unitConversion,modelIn,cdata.timeUnits,cdata.amountUnits,cdata.massUnits);
    localCheckVaryingVolumeConditions(cmodel);


    allRulesAtTime0=[cmodel.activeInitialAssignRules;cmodel.activeRepeatedAssignRules];
    allRuleVarsAtTime0=[cmodel.initialX;cmodel.repeatedX];


    assert(numel(unique(allRuleVarsAtTime0))==numel(allRuleVarsAtTime0));
    [~,cmodel.orderedInitializationRulesAndSpecies]=localCheckAndReorderAssignments(cmodel,allRulesAtTime0,allRuleVarsAtTime0);
    cmodel.initialX=allRuleVarsAtTime0;


    [cmodel.activeRepeatedAssignRules,~,cmodel.repeatedViaRepeated,cmodel.repeatedViaAllObj]=localCheckAndReorderAssignments(cmodel,cmodel.activeRepeatedAssignRules,cmodel.repeatedX);

    cmodel=localSetupDAEs(cmodel);
    [cmodel.JPatternStates,cmodel.JPatternParams]=localBuildJPattern(cmodel,modelIn);
    [cmodel,csverifyCode,rhsCode]=localGenCodeStrings(cmodel,cdata.observables);
    cmodel=localPkCompileData(cmodel);

    cmodel=localSetupSensitivityAnalysis(cmodel,csverifyCode,configset,modelIn);


    [cmodel.X0,cmodel.P]=localSetInitialValues(...
    cmodel.cdata.componentInitialValues,cmodel.X0Objects,cmodel.PObjects,...
    cmodel.XUCM,cmodel.PUCM);

    cmodel.PKCompileData.X0BeforeInitAsgns=cmodel.X0;
    cmodel.PKCompileData.PBeforeInitAsgns=cmodel.P;





    if privatemessagecalls('numerrors')==0
        localTestGeneratedRhsCode(cmodel,rhsCode);
    end

    if privatemessagecalls('numerrors')==0
        [cmodel.X0,cmodel.P]=localEvaluateRulesAtTime0(...
        cmodel.X0,cmodel.P,cmodel.Code.initialAssignRuleStr,...
        cmodel.X0Objects,cmodel.PObjects);
    end

    if(cmodel.SensitivityAnalysis)
        cmodel.Sens0=updateSens0ForConcentrations(cmodel,cmodel.X0);
    end

    cmodel.U0=zeros(size(cmodel.X0));

    [cmodel.X0,cmodel.P]=SimBiology.internal.convertStateVector.toAmount(cmodel.X0,cmodel.P,...
    cmodel.speciesIndexToConstantCompartment,...
    cmodel.speciesIndexToVaryingCompartment);

    cmodel.dU_dP=localSetInputSensitivityInitialValues(configset.SolverOptions.SensitivityAnalysis,numel(cmodel.X0),numel(cmodel.sensStateInputs)+numel(cmodel.sensParamInputs));

    if~isempty(cmodel.Sens0)

        cmodel.U0=[cmodel.U0;full(cmodel.dU_dP(:))];
    end



    odedata=localPrepareODESimulationData(cmodel);

    localAddRateDoseInfoToODESimulationData(modelIn,odedata,cmodel);


    modelIn.ODESimulationData=odedata;



    if privatemessagecalls('numerrors')~=0
        return
    end

    [fluxM,fluxCode,complexFluxCode,repeatedCode,initialCode]=genCode(odedata,codeGenFlag);
    modelIn.ODESimulationData.Code.fluxM=fluxM;
    modelIn.ODESimulationData.FluxCodeGenerator=fluxCode;
    modelIn.ODESimulationData.ComplexFluxCodeGenerator=complexFluxCode;
    modelIn.ODESimulationData.RepeatedCodeGenerator=repeatedCode;
    modelIn.ODESimulationData.InitialCodeGenerator=initialCode;




    if~isempty(modelIn.ODESimulationData.InitialCodeGenerator)


        f=createInitialAssignmentJacobianFcnHandle(modelIn.ODESimulationData.InitialCodeGenerator.mFunctionName);
        modelIn.ODESimulationData.InitialJacobianFcn=f;
    end

end

function sens0=updateSens0ForConcentrations(data,X0)













    sens0=data.Sens0;




    paramIndex=data.speciesIndexToConstantCompartment(:,2);



    [tfSpeciesNeedsUpdates,sensParamInputLoc]=ismember(paramIndex,data.sensParamInputs);

    for iter=1:numel(tfSpeciesNeedsUpdates)


        if tfSpeciesNeedsUpdates(iter)==0


            continue
        end
        compartmentIndexInSensParamInputs=sensParamInputLoc(iter);

        sens0Row=data.speciesIndexToConstantCompartment(iter,1);
        sens0Col=compartmentIndexInSensParamInputs+numel(data.sensStateInputs);




        tfSpeciesIsInStateVector=sens0Row<=numel(X0);




        if tfSpeciesIsInStateVector
            sens0(sens0Row,sens0Col)=X0(sens0Row);
        end
    end

end


function localPreCompileChecks(modelIn)

    if~isa(modelIn,'SimBiology.Model')
        error(message('SimBiology:odebuilder:INTERNAL_ERROR_INVALID_INPUT'));
    end
end







function cmodel=localBuildMaps(model,cmodel)

    [cmodel.species,cmodel.parameterArray,cmodel.compartmentArray]=...
    model.findSpeciesAndParametersInCompileOrder();


    if isempty(cmodel.species)

        cmodel.speciesMap=containers.Map('KeyType','char','ValueType','double');
    else
        cmodel.speciesMap=containers.Map(get(cmodel.species,{'UUID'}),1:numel(cmodel.species));
    end


    speciesWithoutRepeatedX=cmodel.species;
    typeRepeatedX=get(cmodel.repeatedX,{'Type'});
    for i=1:numel(typeRepeatedX)
        switch typeRepeatedX{i}
        case 'species'
            speciesWithoutRepeatedX(cmodel.repeatedX(i)==speciesWithoutRepeatedX)=[];
        case 'parameter'
            cmodel.parameterArray(cmodel.repeatedX(i)==cmodel.parameterArray)=[];
        case 'compartment'
            cmodel.compartmentArray(cmodel.repeatedX(i)==cmodel.compartmentArray)=[];
        otherwise
            error(message('SimBiology:Internal:InternalError'));
        end
    end


    nonReactionStates=[cmodel.rateX;cmodel.doseRateX;cmodel.speciesRateX;cmodel.algebraicX;cmodel.constantX];
    cmodel.X0Objects=[cmodel.reactionX;nonReactionStates];
    cmodel.statesMap=SimBiology.internal.ComponentMap;
    localInsert(cmodel.statesMap,cmodel.X0Objects);

    cmodel.XNames=get(cmodel.X0Objects,{'FullyQualifiedName'});
    cmodel.XUuids=get(cmodel.X0Objects,{'UUID'});


    parameterTypes=get(cmodel.parameters,{'Type'});
    cmodel.tfConstantParameters=strcmp('parameter',parameterTypes);
    cmodel.PObjects=[cmodel.parameters(cmodel.tfConstantParameters);...
    cmodel.parameters(~cmodel.tfConstantParameters);cmodel.repeatedX];
    cmodel.parameterMap=SimBiology.internal.ComponentMap;
    localInsert(cmodel.parameterMap,cmodel.PObjects);

    cmodel.PUuids=get(cmodel.PObjects,{'UUID'});

    if numel(cmodel.PObjects)~=numel(cmodel.parameters)+numel(cmodel.repeatedX)
        error(message('SimBiology:odebuilder:INTERNAL_ERROR_COMPONENTS_NOT_FOUND'));
    end



    cmodel.PNames=get(cmodel.parameters(cmodel.tfConstantParameters),{'FullyQualifiedName'});


    cmodel.allObjects=[cmodel.X0Objects;cmodel.PObjects];
    cmodel.allObjectsMap=SimBiology.internal.ComponentMap;
    localInsert(cmodel.allObjectsMap,cmodel.allObjects);


    [A,B]=localBuildVolumeIndexArrays(cmodel);
    cmodel.speciesIndexToVaryingCompartment=A;
    cmodel.speciesIndexToConstantCompartment=B;
end




function list=localInsert(map,objects,list)
    if~isempty(objects)
        map.insert(objects,double(map.getNumElements)+(1:numel(objects)));
    end
    if nargin>=3
        list{end+1}=objects;
    else
        list={objects};
    end
end








function localCheckVaryingVolumeConditions(cmodel)

    tfSpeciesInConcentration=localIsSpeciesInConcentration(cmodel.speciesRateX,cmodel);
    speciesInConcentration=cmodel.speciesRateX(tfSpeciesInConcentration);
    parentCompartments=get(speciesInConcentration,{'Parent'});
    compartmentsInNonRateRules=localFind([cmodel.algebraicX;cmodel.repeatedX],'compartment');

    for i=1:numel(parentCompartments)
        if any(parentCompartments{i}==compartmentsInNonRateRules)
            error(message('SimBiology:odebuilder:INVALID_RATERULE_CONC',speciesInConcentration(i).Name,speciesInConcentration(i).Name));
        end
    end
end














function[reorderedRules,rules,ruleViaRule,ruleViaAllObj]=localCheckAndReorderAssignments(cmodel,rules,ruleVars)
    [ruleViaRule,ruleViaAllObj,ruleViaRuleSelf]=...
    localBuildAssignmentRuleJPattern(rules,ruleVars,cmodel);


    containsSelfAssignments=nnz(ruleViaRuleSelf);
    if containsSelfAssignments
        [invalidRuleIndex,~]=find(ruleViaRuleSelf);
        ruleText=get(rules(invalidRuleIndex),{'Rule'});
        invalidRuleStrings=sprintf('  ''%s''\n',ruleText{:});
        error(message('SimBiology:odebuilder:INVALID_ASSIGNMENT_RULE',invalidRuleStrings));
    end


    [validOrder,evalOrder,circularRulesGroups]=SimBiology.internal.determineEvalOrderFromDependencies(ruleViaRule);
    if~validOrder


        ruleText=cell(1,numel(circularRulesGroups));
        for i=1:numel(circularRulesGroups)
            msg=message('SimBiology:sbservices:AlgebraicLoop',i,strjoin({rules(circularRulesGroups{i}).Rule},', '));
            ruleText{i}=getString(msg);
        end
        circularRulesString=sprintf('  %s\n',ruleText{:});
        error(message('SimBiology:odebuilder:INVALID_ASSIGNMENT_RULES',circularRulesString));
    end





    rules=rules(evalOrder);
    reorderedRules=rules(evalOrder<=numel(rules));
end


function[ruleViaRule,ruleViaAllObj,ruleViaRuleSelf]=...
    localBuildAssignmentRuleJPattern(rules,ruleVars,cmodel)
    nRules=numel(rules);
    assert(numel(ruleVars)==numel(rules));


    ruleViaRule=speye(nRules);

    ruleViaRuleSelf=sparse(nRules,1);
    ruleViaAllObj=spalloc(nRules,numel(cmodel.allObjects),...
    ceil(.1*nRules*numel(cmodel.X0Objects)));

    for i=1:nRules
        ruleObj=rules(i);


        [lhs,rhs]=ruleObj.parserule;
        lhsObj=ruleObj.resolveobject(lhs{1});
        lhsIndex=find(lhsObj==ruleVars,1);





        if localIsSpeciesInConcentration(lhsObj,cmodel)
            compartmentObj=lhsObj.Parent;
            compartmentIndex=find(compartmentObj==ruleVars,1);
            if~isempty(compartmentIndex)

                ruleViaRule(lhsIndex,compartmentIndex)=1;%#ok<SPRIX>
            end
        end





        rhs=SimBiology.internal.removeReservedTokens(rhs);
        for j=1:numel(rhs)
            rhsObj=ruleObj.resolveobject(rhs{j});

            rhsIndex=find(rhsObj==ruleVars,1);
            if~isempty(rhsIndex)
                if lhsIndex==rhsIndex

                    ruleViaRuleSelf(lhsIndex)=1;%#ok<SPRIX>
                else
                    ruleViaRule(lhsIndex,rhsIndex)=1;%#ok<SPRIX>
                end
            else
                rhsIndex=cmodel.allObjectsMap.find(rhsObj);
                ruleViaAllObj(lhsIndex,rhsIndex)=1;%#ok<SPRIX>
            end




            if localIsSpeciesInConcentration(rhsObj,cmodel)
                compartmentObj=rhsObj.Parent;
                compartmentIndex=find(compartmentObj==ruleVars,1);
                if~isempty(compartmentIndex)

                    if lhsIndex==compartmentIndex
                        ruleViaRuleSelf(lhsIndex)=1;%#ok<SPRIX>
                    else
                        ruleViaRule(lhsIndex,compartmentIndex)=1;%#ok<SPRIX>
                    end
                end
            end
        end
    end







    ruleViaRule=ruleViaRule^(size(ruleViaRule,1)-1);
    ruleViaRule=spones(ruleViaRule);
end







function[depMat,lhsIndex]=localBuildDepMat(rulesAndSpecies,cmodel)
    nRulesAndSpecies=numel(rulesAndSpecies);

    depMat=speye(numel(cmodel.allObjects),numel(cmodel.allObjects));

    lhsIndex=NaN(numel(rulesAndSpecies),1);
    for i=1:nRulesAndSpecies
        obj=rulesAndSpecies(i);

        if isa(obj,'SimBiology.Species')



            objIndex=cmodel.allObjectsMap.find(obj);
            compartment=obj.Parent;
            compartmentIndex=cmodel.allObjectsMap.find(compartment);
            depMat(objIndex,compartmentIndex)=1;%#ok<SPRIX>
        else
            assert(isa(obj,'SimBiology.Rule'));

            [lhs,rhs]=obj.parserule;
            lhsObj=obj.resolveobject(lhs{1});
            lhsIndex(i)=cmodel.allObjectsMap.find(lhsObj);
            rhs=SimBiology.internal.removeReservedTokens(rhs);




            depMat(lhsIndex(i),lhsIndex(i))=0;%#ok<SPRIX>

            for j=1:numel(rhs)
                rhsObj=obj.resolveobject(rhs{j});
                rhsIndex=cmodel.allObjectsMap.find(rhsObj);
                depMat(lhsIndex(i),rhsIndex)=1;%#ok<SPRIX>
            end
        end
    end

    depMat=depMat^(size(depMat,1)-1);
    depMat=spones(depMat);
end


function cmodel=localSetupDAEs(cmodel)

    if isempty(cmodel.activeAlgRules)
        cmodel.DAE=false;
    else
        cmodel.DAE=true;
        cmodel.Mass=speye(numel(cmodel.X0Objects));
        algebraicIndexes=cmodel.statesMap.find(cmodel.algebraicX);
        cmodel.Mass(algebraicIndexes,:)=0;
    end
end


function[X0,P]=localSetInitialValues(initialValueStruct,X0Objects,PObjects,XUCM,PUCM)











    if isempty(initialValueStruct.componentUuids)

        initialValueMap=containers.Map('KeyType','char','ValueType','double');
    else
        initialValueMap=containers.Map(initialValueStruct.componentUuids,initialValueStruct.value);
    end
    X0=cell2mat(initialValueMap.values(get(X0Objects,{'UUID'})));
    X0=reshape(X0,[],1);



    P=cell2mat(initialValueMap.values(get(PObjects,{'UUID'})));
    P=reshape(P,[],1);


    if~isempty(XUCM)
        X0=X0.*XUCM';
        P=P.*PUCM';
    end
end


function dU_dP=localSetInputSensitivityInitialValues(tfSensitivityAnalysis,numStates,numSensitivityInputs)
    if tfSensitivityAnalysis

        dU_dP=zeros(numStates,numSensitivityInputs);
    else
        dU_dP=[];
    end
end





function cmodel=localUnitConversionSetup(cmodel,unitConversion,modelIn,timeUnits,amountUnits,massUnits)
    cmodel.UnitMultipliers=zeros(1,0);
    cmodel.XUCM=zeros(1,0);
    cmodel.PUCM=zeros(1,0);
    if~unitConversion
        return
    end


    [unitOrderedObjs,unitDivisors]=modelIn.getODEUnitMultipliers(timeUnits,amountUnits,massUnits);
    cmodel.UnitMultipliers=1./unitDivisors;


    tfIsState=cmodel.statesMap.isKey(unitOrderedObjs);
    ind=cmodel.statesMap.find(unitOrderedObjs(tfIsState));
    cmodel.XUCM(ind)=unitDivisors(tfIsState);

    tfIsParam=cmodel.parameterMap.isKey(unitOrderedObjs);
    ind=cmodel.parameterMap.find(unitOrderedObjs(tfIsParam));
    cmodel.PUCM(ind)=unitDivisors(tfIsParam);
end











function[jacobianStates,jacobianParams]=localBuildJPattern(cmodel,modelIn)

    nAllObj=numel(cmodel.allObjects);
    j_allObj_rules=localBuildRuleJPattern(cmodel);


    j_reactions_reactions=modelIn.getJpattern(cmodel.activeReactions,cmodel.allObjects);




    [speciesIndex,compartmentIndex]=localGetIndicesForSpeciesInConcentration(cmodel);
    [affectedReaction,usedSpecies]=find(j_reactions_reactions(:,speciesIndex));
    for i=1:numel(affectedReaction)
        j_reactions_reactions(affectedReaction(i),compartmentIndex(usedSpecies(i)))=1;
    end





    for i=1:numel(cmodel.activeReactions)
        reactionRateInConcentration=~isempty(cmodel.cdata)&&cmodel.cdata.reactionIsPerUnitLengthX(i);
        if reactionRateInConcentration
            [~,fVol,rVol]=localMultiCompartmentReactionCheck(cmodel.activeReactions(i));
            reactionCompartmentIndex=cmodel.allObjectsMap.find([fVol;rVol]);
            j_reactions_reactions(i,reactionCompartmentIndex)=1;
        end
    end

    j_reactionX_reactions=spones(spones(cmodel.Stoich)*j_reactions_reactions);
    [i1,j]=find(j_reactionX_reactions);
    reactionXIndices=cmodel.allObjectsMap.find(cmodel.reactionX);
    i2=reactionXIndices(i1);
    j_allObj_reactions=sparse(double(i2),j,1,nAllObj,nAllObj);



    j_allObj_compartments=sparse(double(speciesIndex),double(compartmentIndex),1,nAllObj,nAllObj);


    jacobian=spones(j_allObj_rules+j_allObj_reactions+j_allObj_compartments);


    repeatedXIndices=cmodel.allObjectsMap.find(cmodel.repeatedX);
    jacobian=jacobian+jacobian(:,repeatedXIndices)*cmodel.repeatedViaRepeated*cmodel.repeatedViaAllObj;
    jacobian=spones(jacobian);




    for i=1:numel(cmodel.activeDoses)
        thisDose=cmodel.activeDoses(i);
        durationParameterName=thisDose.DurationParameterName;
        if isempty(durationParameterName)
            continue
        end
        durationParameterObject=thisDose.resolveparameter(modelIn,durationParameterName);
        doseTargetObject=thisDose.resolvetarget(modelIn);
        durationParameterIndex=cmodel.allObjectsMap.find(durationParameterObject);
        doseTargetIndex=cmodel.allObjectsMap.find(doseTargetObject);
        jacobian(doseTargetIndex,durationParameterIndex)=1;%#ok<SPRIX>
    end


    stateIndices=cmodel.allObjectsMap.find(cmodel.X0Objects);
    paramIndices=cmodel.allObjectsMap.find(cmodel.PObjects);
    jacobianStates=jacobian(stateIndices,stateIndices);
    jacobianParams=jacobian(stateIndices,paramIndices);

end


function jpattern=localBuildRuleJPattern(cmodel)
    numAllObjs=numel(cmodel.allObjects);
    jpattern=spalloc(numAllObjs,numAllObjs,ceil(0.1*numAllObjs^2));


    for i=1:numel(cmodel.activeRateRules)
        ruleObj=cmodel.activeRateRules(i);


        [lhs,rhs]=ruleObj.parserule;
        lhsObj=ruleObj.resolveobject(lhs{1});
        lhsIndex=cmodel.allObjectsMap.find(lhsObj);







        if strcmp(lhsObj.Type,'species')&&...
            localIsSpeciesInConcentration(lhsObj,cmodel)



            jpattern(lhsIndex,lhsIndex)=1;%#ok<SPRIX>
            compartmentIndex=cmodel.allObjectsMap.find(lhsObj.Parent);
            jpattern(lhsIndex,compartmentIndex)=1;%#ok<SPRIX>
        end


        rhs=SimBiology.internal.removeReservedTokens(rhs);
        for j=1:numel(rhs)
            rhsObj=ruleObj.resolveobject(rhs{j});
            rhsIndex=cmodel.allObjectsMap.find(rhsObj);
            jpattern(lhsIndex,rhsIndex)=1;%#ok<SPRIX>



            if~isempty(rhsIndex)&&strcmp(rhsObj.Type,'species')&&...
                localIsSpeciesInConcentration(rhsObj,cmodel)
                compartmentIndex=cmodel.allObjectsMap.find(rhsObj.Parent);
                jpattern(lhsIndex,compartmentIndex)=1;%#ok<SPRIX>
            end
        end
    end





    for i=1:numel(cmodel.activeAlgRules)
        ruleObj=cmodel.activeAlgRules(i);



        dependentVarObj=cmodel.algebraicX(i);
        dependentVarIndex=cmodel.allObjectsMap.find(dependentVarObj);





        allRuleObjs=ruleObj.parserule;
        allRuleObjs=SimBiology.internal.removeReservedTokens(allRuleObjs);


        for j=1:numel(allRuleObjs)
            ruleVarObj=ruleObj.resolveobject(allRuleObjs{j});
            ruleVarIndex=cmodel.allObjectsMap.find(ruleVarObj);
            jpattern(dependentVarIndex,ruleVarIndex)=1;%#ok<SPRIX>



            if strcmp(ruleVarObj.Type,'species')&&...
                localIsSpeciesInConcentration(ruleVarObj,cmodel)
                compartmentIndex=cmodel.allObjectsMap.find(ruleVarObj.Parent);
                jpattern(dependentVarIndex,compartmentIndex)=1;%#ok<SPRIX>
            end
        end
    end
end



































function cmodel=localPkCompileData(cmodel)
    pkCompileData.unsupportedconstructs=...
    struct('RateRules',~isempty(cmodel.activeRateRules),...
    'AlgRules',~isempty(cmodel.activeAlgRules),...
    'RptAsgns',~isempty(cmodel.activeRepeatedAssignRules),...
    'Events',~isempty(cmodel.activeEvents));
    pkCompileData.reactionDimsExplicitlySpcfd=cmodel.cdata.reactionDimExplicitlySpecifiedAndValid;
    pkCompileData.reactionIsPerUnitLengthX=cmodel.cdata.reactionIsPerUnitLengthX;
    pkCompileData.InitAsgns=cmodel.activeInitialAssignRules;
    pkCompileData.spCvsAInfo.speciesMap=cmodel.speciesMap;
    pkCompileData.spCvsAInfo.SpeciesInConcentration=cmodel.cdata.SpeciesInConcentration;


    pkCompileData.X0BeforeInitAsgns=[];
    pkCompileData.PBeforeInitAsgns=[];
    pkCompileData.reactions=cmodel.activeReactions;
    cmodel.PKCompileData=pkCompileData;
end


function[cmodel,csverifyCode,rhsCode]=localGenCodeStrings(cmodel,observables)

    quantityNames=get([cmodel.species;cmodel.parameterArray;cmodel.compartmentArray],{'Name'});
    duplicateNameMap=containers.Map('KeyType','char','ValueType','logical');
    for i=1:numel(quantityNames)
        key=quantityNames{i};
        if~isKey(duplicateNameMap,key)
            duplicateNameMap(key)=false;
        elseif~duplicateNameMap(key)
            duplicateNameMap(key)=true;
        end
    end
    allKeys=keys(duplicateNameMap);
    tfDuplicate=cell2mat(values(duplicateNameMap,allKeys));
    remove(duplicateNameMap,allKeys(~tfDuplicate));



    [reactionCode,reactionRateEquations,reactionNames]=localReactionsToCode(...
    cmodel.activeReactions,cmodel.statesMap,cmodel.parameterMap,cmodel.cdata,duplicateNameMap);
    [rateRuleCode,speciesRateRuleCode,rateRuleNames,speciesRateRuleNames,rateRuleEquations,speciesRateRuleEquations]=localRateRuleToCode(...
    cmodel.activeRateRules,cmodel.statesMap,cmodel.parameterMap,cmodel,duplicateNameMap);
    [algRuleCode,algRuleEquations]=localAlgebraicRuleToCode(...
    cmodel.activeAlgRules,cmodel.statesMap,cmodel.parameterMap,duplicateNameMap);
    [initialAssignRuleLhsCode,initialAssignRuleRhsCode,initialAssignmentEquations]=...
    localAssignRuleToCode(cmodel.orderedInitializationRulesAndSpecies,cmodel.statesMap,cmodel.parameterMap,...
    'initialAssignment',cmodel,duplicateNameMap);
    [repeatedAssignRuleLhsCode,repeatedAssignRuleRhsCode,repeatedAssignRuleEquations]=...
    localAssignRuleToCode(cmodel.activeRepeatedAssignRules,cmodel.statesMap,cmodel.parameterMap,...
    'repeatedAssignment',cmodel,duplicateNameMap);


    repeatedAssignRuleUUIDs=get(cmodel.activeRepeatedAssignRules,{'UUID'});




    cmodel.assignmentVarIndex=cmodel.parameterMap.find(cmodel.repeatedX);



    code.repeatedAssignRuleEquations=repeatedAssignRuleEquations;
    code.repeatedAssignRuleUUIDs=repeatedAssignRuleUUIDs;
    code.repeatedAssignRuleStr=localAssignRuleCodeCellToStr(repeatedAssignRuleLhsCode,repeatedAssignRuleRhsCode);
    code.vStr=localCodeCellsToStr(reactionCode);
    code.rRuleStr=localCodeCellsToStr(rateRuleCode);
    code.speciesrRuleStr=localCodeCellsToStr(speciesRateRuleCode);
    code.aRuleStr=localCodeCellsToStr(algRuleCode);
    code.constStr=zeros(numel(cmodel.constantX),1);
    code.initialAssignRuleStr=localAssignRuleCodeCellToStr(initialAssignRuleLhsCode,initialAssignRuleRhsCode);
    code.rhsM=[];

    eqData=SimBiology.internal.Equations.EquationView;
    eqData.RepeatedAssignments=repeatedAssignRuleEquations;
    eqData.RepeatedAssignmentRuleUUIDs=repeatedAssignRuleUUIDs;
    eqData.SpeciesRateRules=speciesRateRuleEquations;
    eqData.RateRules=rateRuleEquations;
    eqData.AlgebraicRules=algRuleEquations;
    eqData.RawReactionCode=reactionRateEquations;
    eqData.ReactionNames=reactionNames;
    eqData.ActiveEvents=cmodel.activeEvents;


    eqData.SpeciesInConcentrationInVaryingCompartments=localGetSpeciesInConcentrationInVaryingCompartments(cmodel);
    if isempty(observables)
        eqData.ObservableEvaluationOrder=[];
    else
        eqData.ObservableEvaluationOrder=observables.EvaluationOrder;
    end

    cmodel.EquationViewData=eqData;


    csverifyCode.rawReactionCode=reactionRateEquations;
    csverifyCode.reactionCodeStr=localCodeCellsToStr(reactionCode);
    csverifyCode.repeatedRuleCodeStr=localCodeCellsToStr(repeatedAssignRuleRhsCode);
    csverifyCode.initialRuleCodeStr=localCodeCellsToStr(initialAssignRuleRhsCode);
    csverifyCode.speciesrRuleStr=code.speciesrRuleStr;

    csverifyCode.rawSpeciesRateRuleCode=localRateRuleToCellStr(speciesRateRuleEquations);
    csverifyCode.rawRepeatedAssignRuleCode=localRateRuleToCellStr(repeatedAssignRuleEquations);
    csverifyCode.rawInitialAssignmentRuleCode=localRateRuleToCellStr(initialAssignmentEquations);

    cmodel.Code=code;


    rhsCode.repeatedAssignRuleRhsCode=repeatedAssignRuleRhsCode;
    rhsCode.reactionCode=reactionCode;
    rhsCode.rateRuleCode=rateRuleCode;
    rhsCode.rateRuleNames=rateRuleNames;
    rhsCode.speciesRateRuleCode=speciesRateRuleCode;
    rhsCode.speciesRateRuleNames=speciesRateRuleNames;
    rhsCode.algRuleCode=algRuleCode;
    rhsCode.initialAssignRuleStr=initialAssignRuleRhsCode;
end




function[code,reactionRateEquations,reactionNames]=localReactionsToCode(reactionObjs,statesMap,parameterMap,cdata,duplicateNameMap)
    nReaction=numel(reactionObjs);
    code=cell(nReaction,1);
    reactionRateEquations=cell(nReaction,1);
    volumeObjs=SimBiology.ModelComponent.empty;
    reactionNames=get(reactionObjs,{'Name'});

    for j=1:nReaction
        reaction=reactionObjs(j);
        expr=reaction.ReactionRate;
        parsevars=reaction.parserate;






        reactionRateInConcentration=~isempty(cdata)&&cdata.reactionIsPerUnitLengthX(j);
        if reactionRateInConcentration
            [reactionOK,fVol,rVol,isMassAction]=localMultiCompartmentReactionCheck(reaction);
            if reactionOK
                if reaction.reversible&&isMassAction


                    expr=localCorrectExpressionForReversibleMassAction(...
                    reaction,fVol,rVol);
                    volumeObjs=[fVol;rVol];
                elseif~isempty(fVol)
                    expr=sprintf('(%s)*[%s]',expr,fVol.UUID);
                    volumeObjs(1)=fVol;
                else


                end
            else
                error(message('SimBiology:odebuilder:ReactantsInMultipleCompartments',localReactionID(reaction)));
            end
        end

        parsevars=unique(parsevars);
        parsevars=SimBiology.internal.removeReservedTokens(parsevars(:));
        [code{j},objArray]=localExprToCode(reaction,expr,parsevars,statesMap,parameterMap,volumeObjs);
        reactionRateEquations{j}=localExprToEquation(expr,getAllParseVars(parsevars,volumeObjs),objArray,duplicateNameMap);
    end
end



function cellStrCode=localRateRuleToCellStr(ruleCode)
    cellStrCode=cell(size(ruleCode));
    for iter=1:numel(ruleCode)
        cellStrCode{iter}=ruleCode(iter).toString();
    end

end





function[reactionOK,fVol,rVol,isMassAction]=localMultiCompartmentReactionCheck(reactionObj)
    fVol=[];
    rVol=[];
    isMassAction=false;

    species=reactionObj.reactants;
    if isempty(species)


        species=reactionObj.products;
    end
    reactionOK=localAreAllSpeciesInOneCompartment(species);
    if reactionOK
        fVol=species(1).Parent;
    end
    if~isempty(reactionObj.KineticLaw)&&strcmp(reactionObj.KineticLaw.KineticLawName,'MassAction')
        isMassAction=true;

        if reactionObj.reversible
            productsOK=localAreAllSpeciesInOneCompartment(reactionObj.products);
            if productsOK
                rVol=reactionObj.products(1).Parent;
            end
            reactionOK=reactionOK&&productsOK;
        end
    end
end


function reactionOK=localAreAllSpeciesInOneCompartment(reactants)
    if isempty(reactants)
        reactionOK=false;
    else
        reactantCompartments=vertcat(reactants.Parent);
        reactionOK=all(reactantCompartments(1)==reactantCompartments);
    end
end





function expr=localCorrectExpressionForReversibleMassAction(...
    reactionObj,fVol,rVol)

    [forwardTerm,reverseTerm]=reactionObj.KineticLaw.getMassActionRateExpressionTerms();
    assert(~isempty(forwardTerm)&&~isempty(reverseTerm),message('SimBiology:Internal:InternalError'));
    expr=sprintf('(%s)*[%s] - (%s)*[%s]',forwardTerm,fVol.UUID,reverseTerm,rVol.UUID);
end


function[code,objArray]=localExprToCode(exprObj,expr,parsevars,statesMap,parameterMap,volumeObjs)
    if~exist('volumeObjs','var')
        volumeObjs=SimBiology.ModelComponent.empty;
    end
    speciesCodeStr='Y0_(%d)';
    parameterCodeStr='P0_(%d)';
    nvar=numel(parsevars);
    nvol=numel(volumeObjs);
    replvars=cell(nvar+nvol,1);

    objArray=getParseVarObjs(exprObj,parsevars,volumeObjs);


    for i=nvol:-1:1
        parsevars{nvar+i}=['[',volumeObjs(i).UUID,']'];
    end


    tfIsState=statesMap.isKey(objArray);
    speciesIndex=statesMap.find(objArray(tfIsState));
    tfIsParam=parameterMap.isKey(objArray);
    parameterIndex=parameterMap.find(objArray(tfIsParam));
    assert(all(tfIsState|tfIsParam),...
    message('SimBiology:Internal:InternalError'));
    replvars(tfIsState)=arrayfun(@(i)sprintf(speciesCodeStr,i),...
    speciesIndex,'UniformOutput',0);
    replvars(tfIsParam)=arrayfun(@(i)sprintf(parameterCodeStr,i),...
    parameterIndex,'UniformOutput',0);
    code=SimBiology.internal.Utils.Parser.traverseSubstitute(expr,parsevars,replvars);
end




function rhs=localExprToEquation(expr,parsevars,parseVarObjs,duplicateNameMap)

    replvars={parseVarObjs.Name};
    tfIsKey=isKey(duplicateNameMap,replvars);
    for i=1:numel(parseVarObjs)
        if tfIsKey(i)
            replvars{i}=parseVarObjs(i).PartiallyQualifiedName;
        elseif~isvarname(replvars{i})
            replvars{i}=['[',replvars{i},']'];
        end
    end
    rhs=SimBiology.internal.Utils.Parser.traverseSubstitute(expr,parsevars,replvars);
end


function objArray=getParseVarObjs(exprObj,parsevars,volumeObjs)

    nvar=numel(parsevars);

    objCell=cell(1,nvar);
    for i=1:nvar
        objCell{i}=exprObj.resolveobject(parsevars{i});
    end
    objArray=vertcat(SimBiology.ModelComponent.empty(0,1),objCell{:},volumeObjs(:));
end

function out=getAllParseVars(parsevars,volumeObjs)
    nvar=numel(parsevars);
    nvol=numel(volumeObjs);
    for i=nvol:-1:1
        parsevars{nvar+i}=['[',volumeObjs(i).UUID,']'];
    end
    out=parsevars;
end





function[rateRuleCode,speciesRateRuleCode,rateRuleNames,speciesRateRuleNames,rateRuleEquations,speciesRateRuleEquations]=localRateRuleToCode(rateRules,spMap,paMap,cmodel,duplicateNameMap)
    nobj=numel(rateRules);

    rateRuleCode=cell(nobj,1);
    if(nobj>0)
        rateRuleEquations(nobj,1)=SimBiology.internal.Equations.Equation;
    else
        rateRuleEquations=SimBiology.internal.Equations.Equation.empty;
    end
    rateRuleNames=cell(nobj,1);
    speciesRateRuleCode=cell(nobj,1);
    if(nobj>0)
        speciesRateRuleEquations(nobj,1)=SimBiology.internal.Equations.Equation;
    else
        speciesRateRuleEquations=SimBiology.internal.Equations.Equation.empty;
    end
    speciesRateRuleNames=cell(nobj,1);
    speciesCounter=0;
    otherCounter=0;


    for j=1:nobj
        ruleObj=rateRules(j);
        [ruleVar,parsevars,~,expr]=ruleObj.parserule;
        assert(numel(ruleVar)==1,message('SimBiology:Internal:InternalError'));
        ruleVarObj=ruleObj.resolveobject(ruleVar{1});


        if strcmp(ruleVarObj.Type,'species')




            exprForEquation=expr;

            speciesCounter=speciesCounter+1;
            if localIsSpeciesInConcentration(ruleVarObj,cmodel)
                compartmentObj=ruleVarObj.Parent;
                expr=sprintf('(%s)*[%s]',expr,compartmentObj.UUID);




                rRuleIndex=find(compartmentObj==cmodel.rateX,1);
                if~isempty(rRuleIndex)
                    expr=sprintf('%s + %s*rrule(%d)',expr,...
                    ruleVarObj.PartiallyQualifiedName,rRuleIndex);
                    parsevars{end+1}=get(ruleVarObj,'PartiallyQualifiedName');%#ok<AGROW> should be small
                elseif~compartmentObj.ConstantCapacity&&...
                    isempty(find(compartmentObj==cmodel.constantX,1))
                    error(message('SimBiology:odebuilder:CannotEvaluateRateRule'));
                end
            else
                compartmentObj=SimBiology.ModelComponent.empty;
            end
            parsevars=unique(parsevars);
            parsevars=SimBiology.internal.removeReservedTokens(parsevars(:));

            speciesRateRuleCode{speciesCounter}=localExprToCode(ruleObj,...
            expr,parsevars,spMap,paMap,compartmentObj);
            speciesRateRuleNames{speciesCounter}=localRuleID(ruleObj);
            temp=SimBiology.internal.Equations.Equation;
            temp.lhs=sprintf('d(%s)/dt',localExprToEquation(ruleVar{1},ruleVar(1),ruleVarObj,duplicateNameMap));
            temp.rhs=localExprToEquation(exprForEquation,parsevars,getParseVarObjs(ruleObj,parsevars,SimBiology.ModelComponent.empty),duplicateNameMap);
            speciesRateRuleEquations(speciesCounter)=temp;


        else
            otherCounter=otherCounter+1;
            parsevars=unique(parsevars);
            parsevars=SimBiology.internal.removeReservedTokens(parsevars(:));

            rateRuleCode{otherCounter}=localExprToCode(ruleObj,...
            expr,parsevars,spMap,paMap);
            rateRuleNames{otherCounter}=localRuleID(ruleObj);

            temp=SimBiology.internal.Equations.Equation;
            temp.lhs=sprintf('d(%s)/dt',ruleVar{1});
            temp.rhs=localExprToEquation(expr,parsevars,getParseVarObjs(ruleObj,parsevars,SimBiology.ModelComponent.empty),duplicateNameMap);
            rateRuleEquations(otherCounter)=temp;
        end
    end

    speciesRateRuleCode=speciesRateRuleCode(1:speciesCounter);
    rateRuleCode=rateRuleCode(1:otherCounter);
    speciesRateRuleNames=speciesRateRuleNames(1:speciesCounter);
    rateRuleNames=rateRuleNames(1:otherCounter);
    rateRuleEquations=rateRuleEquations(1:otherCounter);
    speciesRateRuleEquations=speciesRateRuleEquations(1:speciesCounter);

end


function[code,algRuleEquations]=localAlgebraicRuleToCode(objarray,spMap,paMap,duplicateNameMap)
    nobj=numel(objarray);
    code=cell(nobj,1);
    if(nobj>0)
        algRuleEquations(nobj)=SimBiology.internal.Equations.Equation;
    else
        algRuleEquations=SimBiology.internal.Equations.Equation.empty;
    end

    for j=1:nobj
        obj=objarray(j);
        expr=obj.rule;
        parsevars=obj.parserule;
        parsevars=unique(parsevars);
        parsevars=SimBiology.internal.removeReservedTokens(parsevars(:));
        code{j}=localExprToCode(obj,expr,parsevars,spMap,paMap);
        temp=SimBiology.internal.Equations.Equation;
        temp.lhs=localExprToEquation(expr,parsevars,getParseVarObjs(obj,parsevars,SimBiology.ModelComponent.empty),duplicateNameMap);
        temp.rhs='0';
        algRuleEquations(j)=temp;
    end
end



function[lhsCode,rhsCode,equations]=localAssignRuleToCode(...
    objarray,spMap,paMap,assignmentType,cmodel,duplicateNameMap)

    nobj=numel(objarray);
    lhsCode=cell(nobj,1);
    rhsCode=cell(nobj,1);
    equationsCell=cell(nobj,1);

    isRepeatedAssignment=strcmp('repeatedAssignment',assignmentType);

    for j=1:nobj
        obj=objarray(j);
        [lhspvars,rhspvars,lhsexpr,rhsexpr]=obj.parserule;
        rhspvars=SimBiology.internal.removeReservedTokens(rhspvars(:));
        assert(numel(lhspvars)==1,message('SimBiology:Internal:InternalError'));
        lhsVarObj=obj.resolveobject(lhspvars{1});
        if isRepeatedAssignment&&localIsConstant(lhsVarObj)
            error(message('SimBiology:odebuilder:INVALID_REPEATED_ASSIGNMENT_RULE_CONSTANT_LHS'));
        end


        tempEquation=SimBiology.internal.Equations.Equation;
        tempEquation.lhs=localExprToEquation(lhsexpr,lhspvars,getParseVarObjs(obj,lhspvars,SimBiology.ModelComponent.empty),duplicateNameMap);
        tempEquation.rhs=localExprToEquation(rhsexpr,rhspvars,getParseVarObjs(obj,rhspvars,SimBiology.ModelComponent.empty),duplicateNameMap);
        equationsCell{j}=tempEquation;
        if isRepeatedAssignment



            [replacepvars,volumeObjs]=localScaleTokens(rhspvars,obj,cmodel);
            rhsexpr=SimBiology.internal.Utils.Parser.traverseSubstitute(rhsexpr,rhspvars,replacepvars);
            if strcmp(lhsVarObj.Type,'species')&&localIsSpeciesInConcentration(lhsVarObj,cmodel)

                rhsexpr=sprintf('(%s)*[%s]',rhsexpr,lhsVarObj.Parent.UUID);
                volumeObjs(end+1)=lhsVarObj.Parent;%#ok<AGROW>
            end
        else
            volumeObjs=SimBiology.ModelComponent.empty;
        end
        rhsCode{j}=localExprToCode(obj,rhsexpr,rhspvars,spMap,paMap,volumeObjs);
        lhsCode{j}=localExprToCode(obj,lhsexpr,lhspvars,spMap,paMap);
    end
    equations=vertcat(equationsCell{:});
end


function retval=localIsSpeciesInConcentration(speciesObj,cmodel)

    retval=false(size(speciesObj));
    uuid=get(speciesObj,{'UUID'});
    validIndex=cmodel.speciesMap.isKey(uuid);
    if any(validIndex)
        validSpeciesIndex=cell2mat(cmodel.speciesMap.values(uuid(validIndex)));
        retval(validIndex)=cmodel.cdata.SpeciesInConcentration(validSpeciesIndex);
    end
end




function[ret,mask]=localFind(objs,type)
    if~isempty(objs)
        mask=strcmp(type,get(objs,{'Type'}));
        ret=objs(mask);
    else
        ret=[];
        mask=logical([]);
    end
end


function reactionID=localReactionID(reactionObj)
    reactionID=reactionObj.Name;
    if isempty(reactionID)
        reactionID=reactionObj.Reaction;
    end
end


function ruleID=localRuleID(ruleObj)
    ruleID=ruleObj.Name;
    if isempty(ruleID)
        ruleID=ruleObj.Rule;
    end
end


function retval=localIsConstant(object)
    switch(object.Type)
    case 'species'
        retval=object.ConstantAmount;
    case 'parameter'
        retval=object.ConstantValue;
    case 'compartment'
        retval=object.ConstantCapacity;
    otherwise
        error(message('SimBiology:odebuilder:INTERNAL_COMPILER_ERROR'));
    end
end






function[replaceTokens,volumeObj]=localScaleTokens(tokens,obj,cmodel)
    replaceTokens=tokens;
    volumeObj=SimBiology.ModelComponent.empty;
    for i=1:numel(tokens)
        tokenObj=obj.resolveobject(tokens{i});
        if strcmp(tokenObj.Type,'species')&&localIsSpeciesInConcentration(tokenObj,cmodel)
            compartmentObj=tokenObj.Parent;
            replaceTokens{i}=sprintf('(%s/[%s])',tokens{i},compartmentObj.UUID);
            volumeObj(end+1)=compartmentObj;%#ok<AGROW> should be small
        end
    end
end


function str=localAssignRuleCodeCellToStr(lhsCode,rhsCode)
    endLine=sprintf(';\n');
    if isempty(lhsCode)
        str={};
    else
        str=strcat(lhsCode,{' = '},rhsCode,{endLine});
    end
end


function str=localCodeCellsToStr(code)
    if isempty(code)
        str='[];';
    elseif numel(code)==1
        str=['[',code{:},'];'];
    else
        str=strcat(code(1:end-1),{'; ...'},{newline});
        str=['[',str{:},code{end},'];'];
    end
end


function data=localPrepareODESimulationData(cmodel)
    data=SimBiology.internal.ODESimulationData;


    data.X0Objects=SimBiology.export.ValueInfo.export(cmodel.X0Objects);
    data.PObjects=SimBiology.export.ValueInfo.export(cmodel.PObjects);
    data.XUuids=cmodel.XUuids;
    data.PUuids=cmodel.PUuids;
    data.repeatedXUuids=get(cmodel.repeatedX,{'UUID'});
    data.constantXUuids=get(cmodel.constantX,{'UUID'});
    data.algebraicXUuids=get(cmodel.algebraicX,{'UUID'});

    data.XUCM=cmodel.XUCM;
    data.PUCM=cmodel.PUCM;


    data.XNames=cmodel.XNames;


    data.PNames=cmodel.PNames;



    if cmodel.UnitMultipliers
        data.UnitMultipliers=cmodel.UnitMultipliers;
    end

    if isfield(cmodel,'JPatternStates')
        data.JPatternStates=cmodel.JPatternStates;
        data.JPatternParams=cmodel.JPatternParams;
    end


    data.Stoich=cmodel.Stoich;



    data.DAE=cmodel.DAE;


    if data.DAE,data.Mass=cmodel.Mass;end


    data.X0=cmodel.X0;


    data.P=cmodel.P;

    data.numNonReactingSpeciesWithRateDoses=numel(cmodel.doseRateX);


    data.U=cmodel.U0;




    cmodel.Code.rateDoseObjects=cmodel.rateDoseObjects;

    data.Code=cmodel.Code;
    data.EquationViewData=cmodel.EquationViewData;



    if isfield(cmodel,'nonMAvSpaPat')
        data.nonMAvSpaPat=cmodel.nonMAvSpaPat;
    end

    data.speciesIndexToVaryingCompartment=cmodel.speciesIndexToVaryingCompartment;
    data.speciesIndexToConstantCompartment=cmodel.speciesIndexToConstantCompartment;

    data.assignmentVarIndex=cmodel.assignmentVarIndex;

    data.PKCompileData=cmodel.PKCompileData;


    data.SensitivityAnalysis=cmodel.SensitivityAnalysis;
    if cmodel.SensitivityAnalysis
        data.Sens0=cmodel.Sens0;
        data.sensStateInputs=cmodel.sensStateInputs;
        data.sensParamInputs=cmodel.sensParamInputs;
        data.sensOutputs=cmodel.sensOutputs;
        data.UserSuppliedSensStateInputs=cmodel.UserSuppliedSensStateInputs;
        data.UserSuppliedSensParamInputs=cmodel.UserSuppliedSensParamInputs;
        numSensInputs=length(data.sensStateInputs)+length(data.sensParamInputs);
        data.JPatternSens=sparse(length(data.X0),numSensInputs);
        sensParamCol=length(data.sensStateInputs)+1;
        data.JPatternSens(:,sensParamCol:end)=data.JPatternParams(:,data.sensParamInputs);
        if~isempty(cmodel.Code.initialAssignRuleStr)
            data.IARDependencyMatrix=cmodel.IARDependencyMatrix;
        end
    end


    data.Units.TimeUnits=cmodel.cdata.timeUnits;
    data.Units.AmountUnits=cmodel.cdata.amountUnits;
    data.Units.MassUnits=cmodel.cdata.massUnits;
end


function out=localGetSpeciesInConcentrationInVaryingCompartments(cmodel)
    out=intersect(cmodel.constantX(strcmp('species',get(cmodel.constantX,'type'))),cmodel.species(cmodel.cdata.SpeciesInConcentration));
    if isempty(out)
        return
    end
    idx=cmodel.statesMap.isKey([out.Parent])>0;
    out=out(idx);
end








function[A,B]=localBuildVolumeIndexArrays(cmodel)
    index=cmodel.cdata.SpeciesInConcentration;
    species=cmodel.species(index);
    speciesIndex=cmodel.allObjectsMap.find(species);
    compartments=vertcat(species.Parent);

    tfIsState=cmodel.statesMap.isKey(compartments);
    compartmentsStatesIndex=cmodel.statesMap.find(compartments(tfIsState));

    A=[zeros(0,2);speciesIndex(tfIsState),compartmentsStatesIndex];

    tfIsParam=cmodel.parameterMap.isKey(compartments);
    compartmentsParameterIndex=cmodel.parameterMap.find(compartments(tfIsParam));

    B=[zeros(0,2);speciesIndex(tfIsParam),compartmentsParameterIndex];
end


function[Y0_,P0_]=localEvaluateRulesAtTime0(Y0_,P0_,rulesToEvaluate,X0Objects,PObjects)















    time=0;

    [Y0_,P0_]=evalRuleHelper(Y0_,P0_,time,strjoin(rulesToEvaluate));

    tfComplex=(0~=imag([Y0_;P0_]));
    if any(tfComplex)

        Y0_=real(Y0_);
        P0_=real(P0_);
        allObjects=[X0Objects;PObjects];
        if isa(allObjects,'SimBiology.export.ValueInfo')
            allNames={allObjects.QualifiedName};
        else
            allNames=get(allObjects,{'PartiallyQualifiedName'});
        end
        complexNames=strjoin(allNames(tfComplex),', ');
        warning(message('SimBiology:odebuilder:complexInitialValue',complexNames));
    end
end


function[Y0_,P0_]=evalRuleHelper(Y0_,P0_,time,rulesToEvaluate)%#ok<INUSD> 
    eval(rulesToEvaluate);
end








function cmodel=localSetupSensitivityAnalysis(cmodel,csverifyCode,configset,modelIn)


    assert(~any(strcmp(configset.SolverType,{'ssa';'expltau';'impltau'})),...
    message('SimBiology:Internal:InternalError'));


    sensOff=~configset.SolverOptions.SensitivityAnalysis;



    if~sensOff




        if~isempty(cmodel.orderedInitializationRulesAndSpecies)
            depMatrix=localBuildDepMat(cmodel.orderedInitializationRulesAndSpecies,cmodel);
            cmodel.IARDependencyMatrix=depMatrix;
        end

        fatalError=localSensitivityGeneralErrorCheck(cmodel,configset,modelIn);







        fatalReactionRate=~senscsverify(csverifyCode.reactionCodeStr,csverifyCode.rawReactionCode);

        if feature('SimBioSensitivityWithRules')
            fatalRateRule=~senscsverify(csverifyCode.speciesrRuleStr,csverifyCode.rawSpeciesRateRuleCode);
            fatalAssignRule=~senscsverify(csverifyCode.repeatedRuleCodeStr,csverifyCode.rawRepeatedAssignRuleCode);
            fatalInitialAssignRule=~senscsverify(csverifyCode.initialRuleCodeStr,csverifyCode.rawInitialAssignmentRuleCode);
        else


            fatalRateRule=false;
            fatalAssignRule=false;
            fatalInitialAssignRule=false;
        end


        sensOff=(fatalError||fatalReactionRate||fatalRateRule||fatalAssignRule||fatalInitialAssignRule);
    end

    if sensOff


        cmodel.SensitivityAnalysis=false;
        cmodel.Sens0=[];
        cmodel.dU_dP=[];
        cmodel.sensStateInputs=[];
        cmodel.sensParamInputs=[];
        return
    end

    cmodel.SensitivityAnalysis=true;
    [cmodel.UserSuppliedSensStateInputs,cmodel.UserSuppliedSensParamInputs,cmodel.sensOutputs]...
    =localGenerateSensitivitySpeciesAndParameters(cmodel,configset);

    if isfield(cmodel,'IARDependencyMatrix')&&~isempty(cmodel.IARDependencyMatrix)


        [cmodel.sensStateInputs,cmodel.sensParamInputs]=localUpdateSensInputFactorBasedOnDependencyMatrix(cmodel);
    else


        cmodel.sensStateInputs=cmodel.UserSuppliedSensStateInputs;
        cmodel.sensParamInputs=cmodel.UserSuppliedSensParamInputs;
    end


    cmodel=localSensitivityAuxiliarySetup(cmodel);
end

function[sensStateInputs,sensParamInputs]=localUpdateSensInputFactorBasedOnDependencyMatrix(cmodel)


    depMatrix=cmodel.IARDependencyMatrix;



    depMatrix=depMatrix(:,[cmodel.UserSuppliedSensStateInputs;cmodel.UserSuppliedSensParamInputs+numel(cmodel.X0Objects)]);





    inputidx=any(depMatrix~=0,2);



    sensStateInputs=find(inputidx(1:numel(cmodel.X0Objects)));
    sensParamInputs=find(inputidx(numel(cmodel.X0Objects)+1:end));
end









function fatalFlag=localSensitivityGeneralErrorCheck(cmodel,configset,modelIn)
    fatalFlag=false;

    sensitivityComputationMessage=getString(message('SimBiology:odebuilder:NO_SENSITIVITIES_COMPUTED'));


    if feature('SimBioSensitivityWithRules')

        if~isempty(cmodel.activeAlgRules)
            localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_ALGEBRAIC_RULES',sensitivityComputationMessage));
            fatalFlag=true;
        end
    else

        if~isempty(cmodel.activeRateRules)||~isempty(cmodel.activeAlgRules)||~isempty(cmodel.activeRepeatedAssignRules)
            localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_RULES',sensitivityComputationMessage));
            fatalFlag=true;
        end



        if~isempty(localFind(cmodel.constantX,'parameter'))
            localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_NONCONSTANTPARAMS',sensitivityComputationMessage));
            fatalFlag=true;
        end
    end

    if~isempty(cmodel.activeEvents)
        localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_EVENTS',sensitivityComputationMessage));
        fatalFlag=true;
    end

    if~isempty(localFind(cmodel.X0Objects,'compartment'))
        localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_VARYING_COMPARTMENT_VOLUMES',sensitivityComputationMessage));
        fatalFlag=true;
    end

    sensitivityOpts=configset.SensitivityAnalysisOptions;

    if isempty(sensitivityOpts.Inputs)
        localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_NO_INPUT_FACTORS',sensitivityComputationMessage));
        fatalFlag=true;
    end


    invalidSensOutputs=ismember(sensitivityOpts.Outputs,cmodel.repeatedX);
    if any(invalidSensOutputs)
        fatalFlag=true;
        localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_OUTPUTS_WITH_REPEATED_ASSIGNMENT_VARIABLES',sensitivityComputationMessage));
    end
    sensInputs=sensitivityOpts.Inputs;
    invalidSensInputs=ismember(sensInputs,cmodel.repeatedX);
    if any(invalidSensInputs)
        fatalFlag=true;
        localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_INPUTS_WITH_REPEATED_ASSIGNMENT_VARIABLES',sensitivityComputationMessage));
    end




    if isempty(sensitivityOpts.Outputs)
        localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_NO_OUTPUTS'));




        defaultSensOutputs=setdiff(configset.RuntimeOptions.StatesToLog,cmodel.repeatedX);

        if~isempty(defaultSensOutputs)
            defaultSensOutputs=defaultSensOutputs.findobj('-not','ConstantValue',true);
        end
        if isempty(defaultSensOutputs)
            localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_NO_SPECIES_STATESTOLOG',sensitivityComputationMessage));
            fatalFlag=true;
        end
    else

        constantParameterOutputs=sensitivityOpts.Outputs.findobj('Type','parameter','ConstantValue',true);
        if~isempty(constantParameterOutputs)
            localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_CONSTANT_PARAMETER_OUTPUTS',sensitivityComputationMessage));
            fatalFlag=true;
        end
        constantCompartmentOutputs=sensitivityOpts.Outputs.findobj('Type','compartment','ConstantCapacity',true);
        if~isempty(constantCompartmentOutputs)


            localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_CONSTANT_COMPARTMENT_OUTPUTS',sensitivityComputationMessage));
            fatalFlag=true;
        end
    end

    if~isempty(cmodel.activeDoses)
        for i=1:numel(cmodel.activeDoses)
            thisDose=cmodel.activeDoses(i);
            fatalFlag=fatalFlag|checkForDoseParametersInSensInputs(thisDose,modelIn,sensInputs);
        end
    end
end

function fatalFlag=checkForDoseParametersInSensInputs(doseObj,modelIn,sensInputs)
    fatalFlag=false;
    lagAndDuration={'LagParameterName','DurationParameterName'};
    if isa(doseObj,'SimBiology.ScheduleDose')
        propsToCheck=lagAndDuration;
    else
        propsToCheck=[{'Amount','Rate','StartTime','Interval','RepeatCount'},lagAndDuration];
    end
    for i=1:numel(propsToCheck)
        propName=propsToCheck{i};
        paramValue=doseObj.(propName);
        if isempty(paramValue)||isnumeric(paramValue)
            continue
        end
        paramObj=doseObj.resolveparameter(modelIn,paramValue);
        if~isempty(sensInputs)&&any(sensInputs==paramObj)
            if ismember(propName,lagAndDuration)
                if~paramObj.ConstantValue

                    localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_NONCONSTANT_DOSE_PARAMETER',paramObj.Name,doseObj.Name,propName));
                    fatalFlag=true;
                end
            else


                localStackedWarning(message('SimBiology:odebuilder:SENSITIVITY_WITH_DOSE_PARAMETER',paramObj.Name,doseObj.Name,propName));
                fatalFlag=true;
            end
        end
    end
end


function localStackedWarning(messageObj)
    privatemessagecalls('addwarning',...
    {getString(messageObj),...
    messageObj.Identifier,...
    'ODE Compilation',...
    [],...
    });
end


function localStackedError(id,message)
    privatemessagecalls('adderror',...
    {message,...
    id,...
    'ODE Compilation',...
    [],...
    });
end





function[indexStateInputs,indexParamInputs,indexOutputs]=...
    localGenerateSensitivitySpeciesAndParameters(cmodel,configset)

    sensitivityOpts=configset.SensitivityAnalysisOptions;


    sensInputs=sensitivityOpts.Inputs;

    if~isempty(sensitivityOpts.Outputs)
        sensOutputs=sensitivityOpts.Outputs;
    else



        [sensOutputs,newOrder]=setdiff(configset.RuntimeOptions.StatesToLog,cmodel.repeatedX);
        [~,oldOrder]=sort(newOrder);
        sensOutputs=sensOutputs(oldOrder);
        sensOutputs=sensOutputs.findobj('-not','ConstantValue',true);
    end



    tfIsState=cmodel.statesMap.isKey(sensInputs);
    indexStateInputs=[zeros(0,1);cmodel.statesMap.find(sensInputs(tfIsState))];
    tfIsParam=cmodel.parameterMap.isKey(sensInputs);
    indexParamInputs=[zeros(0,1);cmodel.parameterMap.find(sensInputs(tfIsParam))];
    indexOutputs=[zeros(0,1);cmodel.allObjectsMap.find(sensOutputs)];

    assert((~isempty(indexStateInputs)||~isempty(indexParamInputs))...
    &&~isempty(indexOutputs),...
    message('SimBiology:Internal:InternalError'));
end



function cmodel=localSensitivityAuxiliarySetup(cmodel)
    nStates=numel(cmodel.X0Objects);
    nSensStateInputs=numel(cmodel.sensStateInputs);
    nSensInputs=nSensStateInputs+numel(cmodel.sensParamInputs);





    cmodel.Sens0=sparse(cmodel.sensStateInputs,1:nSensStateInputs,1,nStates,nSensInputs);
end







function localTestGeneratedRhsCode(cmodel,rhsCode)
    Y0_=cmodel.X0;%#ok<NASGU> 
    P0_=cmodel.P;%#ok<NASGU> 
    time=0.0;%#ok<NASGU> 
    workspace=matlab.internal.lang.Workspace('time','Y0_','P0_');

    localTestRhsCode(rhsCode.reactionCode,'BADREACTIONCODE','reaction rate',@(i)['from reaction ',localReactionID(cmodel.activeReactions(i))],workspace);
    localTestRhsCode(rhsCode.algRuleCode,'BADALGRULECODE','algebraic rule',@(i)['rule ',localRuleID(cmodel.activeAlgRules(i))],workspace);


    localTestRhsCode(rhsCode.initialAssignRuleStr,'BADRULECODE','initialAssignment or repeatedAssignment rule',@(i)['rule ',localRuleID(cmodel.orderedInitializationRulesAndSpecies(i))],workspace);




    rrule=localTestRhsCode(rhsCode.rateRuleCode,'BADRATERULECODE','rate rule',@(i)['rule ',rhsCode.rateRuleNames{i}],workspace);
    assignVariable(workspace,'rrule',rrule);
    localTestRhsCode(rhsCode.speciesRateRuleCode,'BADRATERULECODE','rate rule',@(i)['rule ',rhsCode.speciesRateRuleNames{i}],workspace);

end



function result=localTestRhsCode(codeCell,errorIdSuffix,codeType,functionIndexToName,workspace)


    errorId=['SimBiology:odebuilder:',errorIdSuffix];
    result=zeros(size(codeCell));
    for i=1:numel(codeCell)
        try
            result(i)=evaluateIn(workspace,codeCell{i});
        catch ME
            matlabError=MException(message('SimBiology:odebuilder:BadEvalAtTime0',codeType,functionIndexToName(i)));
            matlabError=addCause(matlabError,ME);
            report=matlabError.getReport;
            localStackedError(errorId,report);
        end
    end
end


function[speciesIndex,compartmentIndex]=localGetIndicesForSpeciesInConcentration(cmodel)
    speciesIndex=[
    cmodel.speciesIndexToVaryingCompartment(:,1);
    cmodel.speciesIndexToConstantCompartment(:,1);
    ];
    numStates=numel(cmodel.X0Objects);
    compartmentIndex=[
    cmodel.speciesIndexToVaryingCompartment(:,2);
    cmodel.speciesIndexToConstantCompartment(:,2)+numStates;
    ];
end


function localAddRateDoseInfoToODESimulationData(modelIn,odedata,cmodel)
    nStates=numel(cmodel.X0);
    odedata.EquationViewData.HasRateDoseX=false(nStates,1);
    odedata.EquationViewData.RateDoseNameX=cell(nStates,1);
    rateDoses=odedata.Code.rateDoseObjects;
    for i=1:numel(rateDoses)
        target=rateDoses(i).resolvetarget(modelIn);
        odedata.EquationViewData.HasRateDoseX=odedata.EquationViewData.HasRateDoseX|cmodel.X0Objects==target;
        odedata.EquationViewData.RateDoseNameX{cmodel.X0Objects==target}=rateDoses(i).Name;
    end
end

function di_dp=createInitialAssignmentJacobianFcnHandle(mFunctionName)
    di_dp=@callprivatecsjac;
    f=[];

    function Z0=evalInitialAssignments(Z0,t)
        Z0=feval(mFunctionName,Z0,t);
    end

    function out=callprivatecsjac(t,Y0)

        if exist('f','var')&&~isempty(f)


            out=privatecsjac(f,Y0,numel(Y0),[],[],1e-60,t);
        else
            out=privatecsjac(@evalInitialAssignments,Y0,numel(Y0),[],[],1e-60,t);
        end
    end

end
