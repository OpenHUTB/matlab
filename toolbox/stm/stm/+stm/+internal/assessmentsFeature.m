function value=assessmentsFeature(flag,update)
    persistent feature
    if isempty(feature)
        feature=struct();
        feature.ShowAssessmentsSection='on';
        feature.ShowAssessmentsSectionInRealTimeTestCase='on';
        feature.graphicalExplanation='on';
        feature.ShowAssessmentsCallback='on';
        feature.useReservedTimeVariable='on';
        feature.AllowMRTAssessments='on';
    end
    if~exist('flag','var')
        value=feature;
    elseif~exist('update','var')
        if isstruct(flag)
            value=feature;
            feature=flag;
        elseif isfield(feature,flag)
            value=feature.(flag);
        else
            value=[];
        end
    else
        if isfield(feature,flag)
            value=feature.(flag);
        else
            value=[];
        end
        if isempty(update)
            feature=rmfield(feature,flag);
        else
            feature.(flag)=update;
        end
    end


    if exist('update','var')&&strcmp(flag,'ShowAssessmentsSection')...
        ||exist('flag','var')&&isfield(flag,'ShowAssessmentsSection')
        sectionOn=double(isfield(feature,'ShowAssessmentsSection')&&strcmp(feature.ShowAssessmentsSection,'on'));



        stm.internal.loadLibrary;
        if slfeature('AssessmentRunInCustomCriteria')~=sectionOn
            prev=slfeature('AssessmentRunInCustomCriteria',sectionOn);
            fprintf('Also setting slfeature(''AssessmentRunInCustomCriteria'', %d) for convenience (previous value: %d)\n',sectionOn,prev);
        end
    end

    message.publish('/stm/messaging',struct('VirtualChannel','AssessmentsFeature','Payload',feature));
end
