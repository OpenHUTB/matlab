classdef StudentSdiHasSignals<learning.assess.assessments.StudentAssessment




    properties(Constant)
        type='SdiHasSignals';
    end

    properties
SignalNames
    end

    methods
        function obj=StudentSdiHasSignals(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,~)
            sdiRuns=Simulink.sdi.Run.getLatest;
            if isempty(sdiRuns)||~obj.isSdiOpen
                isCorrect=false;
                return
            end

            sdiSignals=sdiRuns.getAllSignals;
            sdiSignalNames={sdiSignals.Name};

            isCorrect=isequal(sort(intersect(sdiSignalNames,obj.SignalNames)),sort(obj.SignalNames));
        end

        function requirementString=generateRequirementString(~)

            requirementString=message('learning:simulink:genericRequirements:sdiOpenWithRun').getString();

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

        function sdiIsOpen=isSdiOpen(~)
            sdiIsOpen=false;
            windowManager=matlab.internal.webwindowmanager.instance();
            if~isempty(windowManager.windowList)
                windowUrls={windowManager.windowList.URL};
                if any(contains(windowUrls,'sdi.html'))
                    sdiIsOpen=true;
                end
            end
        end

    end
end
