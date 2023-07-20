function[regFcnPreferred,regFcnOld,regFcnNew]=sbiomakeregressionfcn(modelObj,compiledModelMap,doseObjects,fitData,useParallel)




























    transaction=SimBiology.Transaction.create(modelObj);%#ok<NASGU>            


    allDoses=modelObj.getdose();
    isActive=vertcat(allDoses.Active);
    if any(isActive)
        warning(message('SimBiology:sbionlinfit:IgnoringActiveDoses'));
    end


    configset=createTemporaryConfigset(modelObj,compiledModelMap.Observed);



    timeUnique=cell(numel(fitData),1);
    for i=1:numel(fitData)
        timeUnique{i}=fitData(i).timeUnique;
    end

    [exportedModel,odedata]=compileModel(modelObj,doseObjects,compiledModelMap.Estimated);


    [isLinear,linearModel,~,compileData]=SimBiology.internal.LinearModel.compile(modelObj,configset,compiledModelMap,odedata,useParallel);


    if isLinear
        doseTable=[];
        if~isempty(doseObjects)
            doseTable=getDoseTable(doseObjects,compileData.Units.tf,compileData.Units);
        end



        doseTable=linearModel.createDoseTable(numel(fitData),doseTable);
        regFcnNew=@(phi,T,v)linearModel.regressionFcn(phi,timeUnique,doseTable,v);
        regFcnNew=@(phi,T,v)standardizeInputsAndOutputs(fitData,regFcnNew,phi,T,v);
        regFcnPreferred=regFcnNew;
        if nargout>1

            regFcnOld=makeODEBasedRegressionFcn(fitData,exportedModel,useParallel);
            regFcnOld=@(phi,T,v)standardizeInputsAndOutputs(fitData,regFcnOld,phi,T,v);
        end
    else
        regFcnNew=[];
        regFcnOld=makeODEBasedRegressionFcn(fitData,exportedModel,useParallel);
        regFcnOld=@(phi,T,v)standardizeInputsAndOutputs(fitData,regFcnOld,phi,T,v);
        regFcnPreferred=regFcnOld;
    end

end

function[y,t,simdata]=standardizeInputsAndOutputs(fitData,regFcn,phi,T,v)































    assert(size(phi,1)==size(v,1));
    if size(phi,1)==numel(T)









        iStart=1;
        while iStart<=numel(v)
            id=v(iStart);
            iEnd=iStart+numel(fitData(id).indexUniqueTimes)-1;



            assert(iEnd<=size(v,1)&&all(v(iStart)==v(iStart+1:iEnd)));
            phi(iStart+1:iEnd,:)=[];
            v(iStart+1:iEnd)=[];
            iStart=iStart+1;
        end
    end

    try
        if nargout==3

            [y,t,simdata]=regFcn(phi,T,v);
        else

            [y,t]=regFcn(phi,T,v);
        end

        for i=1:numel(v)

            id=v(i);

            y{i}=reshape(y{i}(fitData(id).indexUniqueTimes),[],1);
        end
        y=cat(1,y{:});
        if~all(isfinite(y))
            error(message('SimBiology:sbiofit:INVALID_RESULT'));
        end
    catch ME

        y=cell(1,numel(v));
        t=cell(1,numel(v));
        for i=1:numel(v)

            id=v(i);

            y{i}=inf(size(fitData(id).indexUniqueTimes));
            t{i}=nan(size(fitData(id).indexUniqueTimes));
        end
        y=cat(1,y{:});
        return
    end
end

function[exportedModel,odedata]=compileModel(modelObj,doseObjects,estimatedParameters)


    warningIds={'SimBiology:DOSE_INVALID_DURATIONPARAMETER_TIMEUNITS','SimBiology:DOSE_INVALID_LAGPARAMETER_TIMEUNITS'};
    originalWarningStatus=cellfun(@(wid)warning('off',wid),warningIds);
    cleanup=onCleanup(@()arrayfun(@(s)warning(s.state,s.identifier),originalWarningStatus));
    exportedModel=modelObj.export(estimatedParameters,doseObjects(:));
    odedata=modelObj.ODESimulationData;
end


function regFcn=makeODEBasedRegressionFcn(fitData,exportedModel,useParallel)

    if useParallel
        parfor i=1:1
            exportedModel(i)=accelerateModel(exportedModel(i));
        end
    else
        exportedModel=accelerateModel(exportedModel);
    end
    regFcn=localVectorizeRegressionFcn(fitData,useParallel,exportedModel);
end

function exportedModel=accelerateModel(exportedModel)


    if SimBiology.internal.isMexSetupInvalid
        warning(message('SimBiology:CodeGeneration:InvalidMexCompilerFitting'));
    else
        exportedModel.accelerate();
    end
end


function configset=createTemporaryConfigset(modelObj,observedObjects)
    activeConfigset=modelObj.getconfigset('active');

    configset=activeConfigset.copyobj(modelObj);

    configset.SensitivityAnalysisOptions.Inputs=activeConfigset.SensitivityAnalysisOptions.Inputs;
    configset.SensitivityAnalysisOptions.Outputs=activeConfigset.SensitivityAnalysisOptions.Outputs;

    configset.Name='DOSE_COMPONENT';
    configset.RuntimeOptions.StatesToLog=observedObjects;
    modelObj.setactiveconfigset(configset);
    if~isa(configset.SolverOptions,'SimBiology.ODESolverOptions')


        defaultConfigset=SimBiology.Configset;
        defaultSolver=defaultConfigset.SolverType;
        warning(message('SimBiology:sbionlinfit:SOLVERTYPE_CHANGED',defaultSolver));
        configset.SolverType=defaultSolver;
    end
end

function regFcn=localVectorizeRegressionFcn(fitData,useParallel,exportedModel)

    regFcn=@callFunction;
    timeUnique={fitData.timeUnique};
    numGroups=numel(fitData);

    function[y,t,simdata]=callFunction(phi,timeVec,v)%#ok<INUSL>
        nIndividual=numel(v);
        y=cell(nIndividual,1);
        t=cell(nIndividual,1);
        timeUniqueGroups=timeUnique(v);
        if nargout==3






            simdata(nIndividual,1)=SimData;

            invalidGroups=any(isnan(phi),2)';
            validGroups=find(~invalidGroups);
            invalidGroups=find(invalidGroups);
            nGroups=numel(v);
            y=cell(nGroups,1);
            if useParallel
                parfor i=validGroups
                    [y{i},t{i},simdata(i)]=sbioexportregressionfcn(phi(i,:),timeUniqueGroups{i},v(i),exportedModel,numGroups);
                end
            else
                for i=validGroups
                    [y{i},t{i},simdata(i)]=sbioexportregressionfcn(phi(i,:),timeUniqueGroups{i},v(i),exportedModel,numGroups);
                end
            end

            for i=invalidGroups
                simdata(i)=exportedModel.createNaNSimData(timeUniqueGroups{i});
                y{i}=simdata(i).Data;
                t{i}=simdata(i).Time;
            end
        else

            if useParallel
                parfor i=1:nIndividual
                    [y{i},t{i}]=sbioexportregressionfcn(phi(i,:),timeUniqueGroups{i},v(i),exportedModel,numGroups);
                end
            else
                for i=1:nIndividual
                    [y{i},t{i}]=sbioexportregressionfcn(phi(i,:),timeUniqueGroups{i},v(i),exportedModel,numGroups);
                end
            end
        end
    end
end
