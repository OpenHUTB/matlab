classdef StudentActiveConfigSet<learning.assess.assessments.StudentAssessment


    properties(Constant)
        type='ActiveConfigSet';
    end

    properties
ConfigSetFile
ConfigSetType
ConfigsToVerify
ModelName
    end

    methods
        function obj=StudentActiveConfigSet(props)

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
                activeSet=getActiveConfigSet(obj.ModelName);
            else
                activeSet=getActiveConfigSet(userModelName);
            end


            if strcmp(obj.ConfigSetType,'.m')
                configObj=eval(obj.ConfigSetFile);
            else
                loadCommand='load(''%s'')';
                filename=strcat(obj.ConfigSetFile,obj.ConfigSetType);
                configObj=eval(sprintf(loadCommand,filename));


                field=fieldnames(configObj);
                configObj=configObj.(field{1});
            end

            eachParamCorrect=zeros(1,length(obj.ConfigsToVerify));

            for idx=1:length(eachParamCorrect)
                solutionProp=obj.cleanParameter(configObj.getProp(obj.ConfigsToVerify{idx}));
                activeProp=obj.cleanParameter(activeSet.getProp(obj.ConfigsToVerify{idx}));

                if isnumeric(solutionProp)&&isnumeric(activeProp)
                    eachParamCorrect(idx)=solutionProp==activeProp;
                else
                    eachParamCorrect(idx)=strcmp(solutionProp,activeProp);
                end
            end

            isCorrect=all(eachParamCorrect);
        end

        function requirementString=generateRequirementString(~)
            requirementString=message('learning:simulink:genericRequirements:activeConfigSet').getString();
        end
    end

    methods(Access=protected)
        function validateAndSetProps(obj,props)

            if isempty(props.ConfigSetFile)||isempty(props.ConfigsToVerify)
                error(message('learning:simulink:resources:MissingParameters'));
            end

            mustBeTextScalar(props.ConfigSetFile);
            mustBeText(props.ConfigsToVerify);

            obj.ConfigsToVerify=cellstr(props.ConfigsToVerify);

            [~,name,ext]=fileparts(props.ConfigSetFile);
            if isempty(ext)||~ismember(ext,{'.m','.mat'})
                error(message('learning:simulink:resources:InvalidInput'));
            else
                obj.ConfigSetFile=name;
                obj.ConfigSetType=ext;
            end


            if isfield(props,'ModelName')
                mustBeTextScalar(props.ModelName);
                obj.ModelName=props.ModelName;
            end

        end

    end

    methods(Static,Access=protected)
        function cleanedParameter=cleanParameter(configurationParameter)

            cleanedParameter=str2double(configurationParameter);


            if isnan(cleanedParameter)
                cleanedParameter=strrep(configurationParameter,' ','');
            end
        end
    end
end
