function setKeywords()




    deepLearningKeyword='deep_blocks:common:DeepLearningKeyword';


    predictKeywords={deepLearningKeyword,'activations'};
    predictBlock='deeplib/Predict';
    set_param(predictBlock,'BlockKeywords',predictKeywords);


    classifierKeywords={deepLearningKeyword,'classify'};
    classifierBlock='deeplib/Image Classifier';
    set_param(classifierBlock,'BlockKeywords',classifierKeywords);


    statefulPredictKeywords={deepLearningKeyword,'predictAndUpdateState'};
    statefulPredictBlock='deeplib/Stateful Predict';
    set_param(statefulPredictBlock,'BlockKeywords',statefulPredictKeywords);


    statefulClassifyKeywords={deepLearningKeyword,'classifyAndUpdateState'};
    statefulClassifyBlock='deeplib/Stateful Classify';
    set_param(statefulClassifyBlock,'BlockKeywords',statefulClassifyKeywords);

end