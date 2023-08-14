function classifierIssues=validateMPGSAClassifiers(modelObj,classifiers)
































    [classifierTokens,tfValidClassifier]=SimBiology.gsa.MPGSA.getClassifierTokens(modelObj,classifiers);


    for i=numel(classifiers):-1:1
        if tfValidClassifier(i)
            classifierIssues=struct("IsError",logical.empty,...
            "Messages",{{}});
        else
            msg=message('SimBiology:GlobalSensitivityAnalysis:InvalidClassifier',classifiers{i});
            classifierIssues=struct("IsError",true,...
            "Messages",{msg.getString()});
        end
    end

    if any(tfValidClassifier)

        classifierTokens=unique(vertcat(classifierTokens{:}),"stable");
        dimensionalAnalysisIssues=SimBiology.gsa.MPGSA.dimensionalAnalysisHelper(modelObj,...
        classifierTokens,classifiers(tfValidClassifier),false);
        classifierIssues(tfValidClassifier)=dimensionalAnalysisIssues;
    end

end