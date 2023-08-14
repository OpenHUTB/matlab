classdef StudentSdiSelectedSignals<learning.assess.assessments.StudentAssessment




    properties(Constant)
        type='SdiSelectedSignals';
    end

    properties
SignalNames
    end

    methods
        function obj=StudentSdiSelectedSignals(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,~)
            sdiRuns=Simulink.sdi.Run.getLatest;
            if isempty(sdiRuns)
                isCorrect=false;
                return
            end

            sdiSignals=sdiRuns.getAllSignals;
            sdiSignalNames={sdiSignals.Name};
            sdiSignalChecked={sdiSignals.Checked};

            signalInds=matches(sdiSignalNames,obj.SignalNames);

            isCorrect=all(cellfun(@(x)isequal(x,1),sdiSignalChecked(signalInds)));
        end

        function requirementString=generateRequirementString(~)

            requirementString=message('learning:simulink:genericRequirements:sdiSignalSelected').getString();

        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)
            if isempty(props.SignalNames)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            mustBeText(props.SignalNames);

            obj.SignalNames=cellstr(props.SignalNames);
        end


    end
end
