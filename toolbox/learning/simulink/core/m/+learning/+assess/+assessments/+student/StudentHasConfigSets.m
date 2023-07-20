classdef StudentHasConfigSets<learning.assess.assessments.StudentAssessment





    properties(Constant)
        type='HasConfigSets';
    end

    properties
NumConfigSets
ModelName
    end

    methods
        function obj=StudentHasConfigSets(props)

            obj.validateAndSetProps(props);
        end

        function isCorrect=assess(obj,userModelName)

            if~isempty(obj.ModelName)
                if~bdIsLoaded(obj.ModelName)
                    try
                        model=load_system(obj.ModelName);
                    catch err

                        sldiagviewer.createStage('Analysis','ModelName',userModelName);
                        sldiagviewer.reportError(err);
                        isCorrect=false;
                        return
                    end
                    cleanup=onCleanup(@()bdclose(model));
                end
                sets=getConfigSets(obj.ModelName);
            else
                sets=getConfigSets(userModelName);
            end

            isCorrect=length(sets)>=obj.NumConfigSets;
        end

        function requirementString=generateRequirementString(obj)
            messageString='learning:simulink:genericRequirements:numConfigSets';
            requirementString=message(messageString,num2str(obj.NumConfigSets)).getString();
        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)
            if isempty(props.NumConfigSets)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            if~isnumeric(props.NumConfigSets)||length(props.NumConfigSets)>1
                error(message('learning:simulink:resources:InvalidInput'));
            end

            obj.NumConfigSets=props.NumConfigSets;


            if isfield(props,'ModelName')
                mustBeTextScalar(props.ModelName);
                obj.ModelName=props.ModelName;
            end
        end


    end
end
