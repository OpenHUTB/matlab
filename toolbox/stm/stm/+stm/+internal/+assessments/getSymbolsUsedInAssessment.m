






function symbolNames=getSymbolsUsedInAssessment(assessmentDataArray)

    symbolNames={};
    for idx=1:length(assessmentDataArray)
        if strcmp(assessmentDataArray{idx}.type,'expression')
            if(assessmentDataArray{idx}.label~="")
                s=sltest.assessments.internal.parseExpression({assessmentDataArray{idx}.label},{assessmentDataArray{idx}.dataType});
                assert(numel(s)==1);
                if~isempty(s{1}.Symbols)
                    symbolNames=[symbolNames,s{1}.Symbols];
                end
            end
        end
    end

end

