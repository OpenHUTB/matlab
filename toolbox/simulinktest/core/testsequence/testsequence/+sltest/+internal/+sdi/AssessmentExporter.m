classdef AssessmentExporter<Simulink.sdi.internal.export.ElementExporter
    methods
        function ret=getDomainType(~)
            ret='slt_verify';
        end

        function assessment=exportElement(~,~,dataStruct)
            sdi=Simulink.sdi.Instance.engine;

            assessment=sltest.Assessment();
            assessment.Name=dataStruct.Name;
            assessment.BlockPath=dataStruct.BlockPath;
            assessment.BlockPath.SubPath=char(sdi.getMetaDataV2(dataStruct.ID,'SubPath'));
            assessment.Values=dataStruct.Values;
            assessment.Result=slTestResult(sdi.getMetaDataV2(dataStruct.ID,'AssessmentResult'));
            if isempty(assessment.Result)


                assessment.Result=slTestResult(max(dataStruct.Values));
                if isempty(assessment.Result)

                    assessment.Result=slTestResult.Untested;
                end
            end
            assessment.SSIdNumber=sdi.getMetaDataV2(dataStruct.ID,'SSIDNumber');
            assessment.AssessmentId=sdi.getMetaDataV2(dataStruct.ID,'AssessmentId');
        end
    end
end
