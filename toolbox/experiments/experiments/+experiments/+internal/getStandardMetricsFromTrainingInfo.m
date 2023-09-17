function metrics=getStandardMetricsFromTrainingInfo(trInfo,trainingType,usesValidation)

    if strcmp(trainingType,'classification')
        trainingAccuracyOrRMSE=trInfo.TrainingAccuracy(trInfo.OutputNetworkIteration);
    else
        trainingAccuracyOrRMSE=trInfo.TrainingRMSE(trInfo.OutputNetworkIteration);
    end
    trainingLoss=trInfo.TrainingLoss(trInfo.OutputNetworkIteration);
    metrics(1:2)={trainingAccuracyOrRMSE,trainingLoss};

    if usesValidation
        if strcmp(trainingType,'classification')
            validationAccuracyOrRMSE=trInfo.FinalValidationAccuracy;
        else
            validationAccuracyOrRMSE=trInfo.FinalValidationRMSE;
        end
        validationLoss=trInfo.FinalValidationLoss;
        metrics(3:4)={validationAccuracyOrRMSE,validationLoss};
    end
end

