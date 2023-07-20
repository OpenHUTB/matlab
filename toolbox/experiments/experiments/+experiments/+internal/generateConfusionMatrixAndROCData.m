function[matrixData,truePredictedLabels,xArray,yArray,tArray,aucArray,errorLabelConfusionMatrix,errorLabelROCCurve]=generateConfusionMatrixAndROCData(trainedModel,X,T,trainingType,errorFromSdk)
















    matrixData=[];
    truePredictedLabels=[];
    xArray=[];
    yArray=[];
    tArray=[];
    aucArray=[];
    if(isempty(X)||isempty(T))




        if(isempty(errorFromSdk))
            errorLabelConfusionMatrix='experiments:results:ConfusionMatrixLabelNoData';
            errorLabelROCCurve='experiments:results:ROCCurveLabelNoData';
        else
            errorLabelConfusionMatrix{1}='experiments:results:CMErrorFromSDK';
            errorLabelConfusionMatrix{2}=errorFromSdk;
            errorLabelROCCurve{1}='experiments:results:CMErrorFromSDK';
            errorLabelROCCurve{2}=errorFromSdk;
        end
        return;
    end

    if(isempty(trainedModel))
        errorLabelConfusionMatrix='experiments:results:NoTrainedModelAvailableForConfusionMatrix';
        errorLabelROCCurve='experiments:results:NoTrainedModelAvailableForROCCurve';
        return;
    end
    if strcmp(trainingType,'regression')
        errorLabelConfusionMatrix='experiments:results:NoConfusionMatrixForRegression';
        errorLabelROCCurve='experiments:results:NoROCCurveForRegression';
        return;
    end


    try
        [Y,scores]=classify(trainedModel,X);




        if iscell(Y)&&iscell(T)&&iscell(scores)
            Y=[Y{:}];
            scores=cellfun(@(score)score',scores,'UniformOutput',false);
            scores=cat(1,scores{:});
            T=[T{:}];
        end
    catch ME


        errorLabelConfusionMatrix{1}='experiments:results:CMErrorOnClassify';
        errorLabelConfusionMatrix{2}=char(ME.identifier);
        errorLabelROCCurve{1}='experiments:results:CMErrorOnClassify';
        errorLabelROCCurve{2}=char(ME.identifier);
        return;
    end

    try
        [matrixData,truePredictedLabels]=confusionmat(T,Y);
        errorLabelConfusionMatrix='';
    catch ME


        errorLabelConfusionMatrix{1}='experiments:results:CMErrorOnConfusionmat';
        errorLabelConfusionMatrix{2}=char(ME.identifier);
    end

    try

        [xArray,yArray,tArray,aucArray]=experiments.internal.computeROCMetrics(T,...
        scores,...
        truePredictedLabels,...
        this.feature.showROCCurve);
        errorLabelROCCurve='';
    catch ME


        errorLabelROCCurve{1}='experiments:results:CMErrorOnGenerateROC';
        errorLabelROCCurve{2}=char(ME.identifier);
    end
end

