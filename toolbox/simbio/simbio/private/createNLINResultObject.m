function out=createNLINResultObject(results,pkModelMap,paramtransform)

    parameterNames=pkModelMap.Estimated;

    numResults=numel(results);

    if~isfield(results,'estimate')

        invParamTransform=SimBiology.internal.transformParameters(paramtransform,'inverse');
        for i=1:numResults
            results(i).estimate=invParamTransform(results(i).beta);
        end
    end

    if~isfield(results,'GroupName')

        for i=1:numResults
            results(i).GroupName=i;
        end
    end

    out(numResults)=NLINResults;
    for i=1:numResults
        out(i)=NLINResults;
        out(i).GroupName=results(i).GroupName;
        out(i).beta=results(i).beta;
        out(i).R=results(i).R;
        out(i).J=results(i).J;
        out(i).COVB=results(i).COVB;
        out(i).mse=results(i).mse;
        out(i).errorparam=results(i).errorparam;
        [standarderror,out(i).CovarianceMatrix]=SimBiology.internal.computeStandardErrors(results(i).beta,results(i).COVB,paramtransform);

        out(i).ParameterEstimates=dataset({parameterNames,'Name'},{results(i).estimate,'Estimate'},...
        {standarderror,'StandardError'});

    end

