classdef ModelRefStatusHelper<handle





    methods(Static)

        function result=getDefaultStatus()
            result.targetStatus=Simulink.ModelReference.internal.ModelRefTargetStatus.TARGET_WAS_UP_TO_DATE;
            result.parentalAction=Simulink.ModelReference.internal.ModelRefParentalAction.NO_ACTION_REQUIRED;
            result.artifactStatus=Simulink.ModelReference.internal.ModelRefArtifactStatus.ALL_ARTIFACTS_UP_TO_DATE;
            result.pushParBuildArtifacts=Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts.NONE;
        end
    end
end