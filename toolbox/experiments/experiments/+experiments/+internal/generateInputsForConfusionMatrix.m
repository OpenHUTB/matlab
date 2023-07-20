function[YPredicted,labels,scores,errorLabelConfusionMatrix,errorLabelROCCurve]=generateInputsForConfusionMatrix(trainedModel,data,responseName,trainingType)




    YPredicted=[];
    labels=[];
    errorLabelConfusionMatrix=[];
    errorLabelROCCurve=[];
    scores=[];
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
    if(isempty(data))
        errorLabelConfusionMatrix='experiments:results:ConfusionMatrixLabelNoData';
        errorLabelROCCurve='experiments:results:ROCCurveLabelNoData';
        return;
    end
    if(isa(data,'matlab.io.datastore.ImageDatastore'))
        labels=data.Labels;
    elseif isa(data,'matlab.io.Datastore')||isa(data,'matlab.io.datastore.Datastore')
        copyds=copy(data);
        reset(copyds);
        batch_data=read(copyds);
        labels=batch_data{:,end};
        while hasdata(copyds)
            batch_data=read(copyds);
            labels=[labels;batch_data{:,end}];%#ok<AGROW>
        end
    elseif(istable(data))
        if(isempty(responseName))


            labels=data{:,end};
            data=data(:,1:end-1);
        else
            labels=data.(responseName);


            data.(responseName)=[];
        end
    else
        labels=responseName;
    end

    try





        [YPredicted,scores]=classify(trainedModel,data);





        if iscell(YPredicted)&&iscell(labels)&&iscell(scores)
            YPredicted=[YPredicted{:}];
            scores=cellfun(@(score)score',scores,'UniformOutput',false);
            scores=cat(1,scores{:});
            labels=[labels{:}];
        end
    catch




        errorLabelConfusionMatrix='experiments:results:ConfusionMatrixLabelNoData';
        errorLabelROCCurve='experiments:results:ROCCurveLabelNoData';
    end
end

