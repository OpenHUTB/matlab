function out=createNewResultObject(results,covariateModel,pkModelMap,pkData,REParamsSelect)







    parameterNames=pkModelMap.Estimated;
    out=NLMEResults;

    out.stats=results.stats;
    out.EstimatedParameterNames=parameterNames;


    out.covmodel=covariateModel;

    if isa(covariateModel,'CovariateModel')

        parsedCovariateModel=covariateModel.ParsedModel;
        out.CovariateNames=parsedCovariateModel.CovariateNames;


        fixedEffectNames=parsedCovariateModel.FixedEffectNames;











        theta=results.beta;

        out.FixedEffects=dataset({fixedEffectNames,'Name'},...
        {parsedCovariateModel.FixedEffectDescription,'Description'},...
        {reshape(theta,[],1),'Estimate',});
        if~isempty(results.stats.sebeta)
            sebeta=results.stats.sebeta;
            stdErrors=SimBiology.internal.computeStandardErrors(results.beta,diag(results.stats.sebeta.^2),parsedCovariateModel.ParamTransform);
            out.FixedEffects.StandardError=reshape(sebeta,[],1);
        end



        a2b=privateMapA2B(parsedCovariateModel.ParameterNames,parameterNames);



        validParamNames=genvarname(parameterNames);
        REParamsSelect=parsedCovariateModel.REParamsSelect(a2b);
        parametersWithRandomEffects=validParamNames(REParamsSelect);


        individualDS=dataset;
        populationDS=dataset;
        for i=1:numel(validParamNames)
            individualDS.(validParamNames{i})=results.phiI(i,:)';
            populationDS.(validParamNames{i})=results.phiP(i,:)';
        end
        out.IndividualParameterEstimates=individualDS;
        out.PopulationParameterEstimates=populationDS;


        randomEffectDS=dataset;
        for i=1:numel(parametersWithRandomEffects)
            randomEffectDS.(parametersWithRandomEffects{i})=results.b(i,:)';
        end
        out.RandomEffects=randomEffectDS;


        RECovMatrix=dataset;
        for i=1:numel(parametersWithRandomEffects)
            RECovMatrix.(parametersWithRandomEffects{i})=results.psi(:,i);
        end
        out.RandomEffectCovarianceMatrix=RECovMatrix;

    elseif isempty(covariateModel)






        if numel(results.beta)==numel(pkModelMap.Estimated)
            out.FixedEffects=dataset({pkModelMap.Estimated,'Description'},...
            {results.beta,'Estimate',});
        else
            out.FixedEffects=dataset({results.beta,'Estimate'});
        end

        if~isempty(results.stats.sebeta)
            out.FixedEffects.StandardError=reshape(results.stats.sebeta,[],1);
        end

        validParamNames=genvarname(parameterNames);
        parametersWithRE=validParamNames(REParamsSelect);
        individualDS=dataset;
        populationDS=dataset;
        for i=1:numel(validParamNames)
            individualDS.(validParamNames{i})=results.phiI(i,:)';
            populationDS.(validParamNames{i})=results.phiP(i,:)';
        end
        out.IndividualParameterEstimates=individualDS;
        out.PopulationParameterEstimates=populationDS;


        randomEffectDS=dataset;
        for i=1:numel(parametersWithRE)
            randomEffectDS.(parametersWithRE{i})=results.b(i,:)';
        end
        out.RandomEffects=randomEffectDS;


        RECovMatrix=dataset;
        for i=1:numel(parametersWithRE)
            RECovMatrix.(parametersWithRE{i})=results.psi(:,i);
        end
        out.RandomEffectCovarianceMatrix=RECovMatrix;
        out.CovariateNames=pkData.CovariateLabels;

    else
        error(message('SimBiology:CovariateModel:createNewResultInvalidCovariateModel'));
    end
end


