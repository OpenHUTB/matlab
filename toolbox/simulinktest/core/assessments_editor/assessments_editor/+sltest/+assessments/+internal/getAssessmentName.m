function result=getAssessmentName(assessmentsId,assessmentId)
    result='';



    try
        assessmentsInfo=stm.internal.getAssessmentsInfo(assessmentsId);
        if isempty(assessmentsInfo)
            return;
        end

        if isa(assessmentId,'char')

            sep=strfind(assessmentId,':');
            if length(sep)~=1
                return;
            end
            assessmentId=str2double(assessmentId(sep+1:end));
        end

        assessmentRowRegexp=regexp(assessmentsInfo,['{"id":',num2str(assessmentId),',[^}]+}'],'match');
        if isempty(assessmentRowRegexp)
            return;
        end
        assessmentRowText=assessmentRowRegexp{1};
        assessmentNameRegexp=regexp(assessmentRowText,'"assessmentName":"([^"]+)"','tokens');
        if isempty(assessmentNameRegexp)
            return;
        end

        result=assessmentNameRegexp{1}{1};
    catch
    end
end

