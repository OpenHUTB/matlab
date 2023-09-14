function metrics=getStandardMetricsFromOutputFcn(info,trainingType,usesValidation)

    if strcmp(trainingType,'classification')
        trainingAccuracyOrRMSE=info.TrainingAccuracy;
    else
        trainingAccuracyOrRMSE=info.TrainingRMSE;
    end
    trainingLoss=info.TrainingLoss;
    metrics(1:2)={trainingAccuracyOrRMSE,trainingLoss};

    if usesValidation&&~isempty(info.ValidationLoss)
        if strcmp(trainingType,'classification')
            validationAccuracyOrRMSE=info.ValidationAccuracy;
        else
            validationAccuracyOrRMSE=info.ValidationRMSE;
        end
        validationLoss=info.ValidationLoss;
        metrics(3:4)={validationAccuracyOrRMSE,validationLoss};
    end
end
