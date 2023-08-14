classdef StudentLoggedSignal<learning.assess.assessments.StudentAssessment


    properties(Constant)
        type='LoggedSignal';
    end

    properties
SignalNames
    end

    methods
        function obj=StudentLoggedSignal(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,userModelName)
            eachIsCorrect=zeros(1,length(obj.SignalNames));

            for idx=1:length(obj.SignalNames)
                thisLine=find_system(userModelName,"FindAll","on","type","Line","Name",obj.SignalNames{idx});
                if isempty(thisLine)
                    isCorrect=false;
                    return
                end



                dataLogging=get_param(get_param(thisLine(1),"SrcPortHandle"),"DataLogging");
                if strcmp(dataLogging,"on")
                    eachIsCorrect(idx)=1;
                end
            end

            isCorrect=all(eachIsCorrect);
        end

        function requirementString=generateRequirementString(obj)

            if length(obj.SignalNames)>1
                messageName='learning:simulink:genericRequirements:loggedSignalMultiple';
            else
                messageName='learning:simulink:genericRequirements:loggedSignal';
            end
            allSignalsText='';
            for idx=1:length(obj.SignalNames)
                currentSignalText=['          ',obj.SignalNames{idx}];
                allSignalsText=[allSignalsText,newline,currentSignalText];
            end
            requirementString=message(messageName,allSignalsText).getString();

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
