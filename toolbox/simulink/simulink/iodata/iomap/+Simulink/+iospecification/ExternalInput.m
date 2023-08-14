classdef ExternalInput<handle




    properties


InputVariables

InputVariableNames




    end

    properties(Access=protected)
        VARNAME_ERR='sl_iospecification:inputvariables:externalinputVarnameErr';
        VARVALUES_ERR='sl_iospecification:inputvariables:externalinputVarvalueErr';
    end


    methods


        function obj=ExternalInput(varNames,varValues)









            overrideConstructorErrorMessages(obj);


            varNames=conditionVarNames(obj,varNames);

            IS_GOOD=qualifyVarNames(obj,varNames);

            if~IS_GOOD
                DAStudio.error(obj.VARNAME_ERR);
            end


            obj.InputVariableNames=varNames;
            obj.InputVariables=varValues;
        end


        function varNames=conditionVarNames(obj,varNames)
            for kVar=1:length(varNames)
                if isnumeric(varNames{kVar})&&isempty(varNames{kVar})
                    varNames{kVar}='';
                end
            end
        end


        function varValue=getVariableByName(obj,varName)
            idx=strcmp(obj.InputVariableNames,varName);
            if~any(idx)
                DAStudio.error('sl_iospecification:inputvariables:externalInputNoMatchingVarName',varName);
            end
            varValue=obj.InputVariables{idx};
        end


        function NUM_INPUTS=getNumberOfInputs(obj)
            NUM_INPUTS=length(obj.InputVariableNames);
        end


        function InputVariablePlugin=getInputVariablePluginFromMapping(obj,inMapping)




            [varName,varValue]=getVariableFromMapping(obj,inMapping);


            if isnumeric(varName)&&isempty(varName)
                varName='';
            end

            InputVariablePlugin=getInputVariablePlugin(obj,varName,varValue);
        end


        function[varName,varValue]=getVariableFromMapping(obj,inMapping)

            varName=inMapping.DataSourceName;

            if isnumeric(varName)&&isempty(varName)
                varName='';
            end

            varValue=getVariableByName(obj,varName);
        end


        function InputVariablePlugin=getInputVariablePlugin(obj,varName,varValue)
            inputFactory=Simulink.iospecification.InputVariableFactory.getInstance();

            try
                InputVariablePlugin=inputFactory.getInputVariableType(varName,varValue);
            catch ME
                throwAsCaller(ME);
            end
        end
    end


    methods(Access=protected)


        function IS_GOOD=qualifyVarNames(~,varNames)
            if~iscellstr(varNames)
                IS_GOOD=false;
                return;
            end

            IS_GOOD=true;
        end


        function IS_GOOD=qualifyVarValues(~,varValues)
            if ischar(varValues)
                IS_GOOD=false;
                return;
            end

            if~all(cellfun(@isSimulinkSignalFormat,varValues))
                IS_GOOD=false;
                return;
            end

            IS_GOOD=true;
        end


        function overrideConstructorErrorMessages(obj)

        end
    end
end
