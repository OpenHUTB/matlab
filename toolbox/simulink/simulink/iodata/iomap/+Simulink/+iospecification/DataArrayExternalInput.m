classdef DataArrayExternalInput<Simulink.iospecification.ExternalInput









    methods


        function varNames=conditionVarNames(obj,varNames)

        end


        function varValue=getVariableByName(obj,varName)

            varValue='';
        end


        function varValue=getVariableByIndex(obj,idx)

            dataVal=obj.InputVariables(:,idx+1);
            timeVal=obj.InputVariables(:,1);

            varValue=timeseries(dataVal,timeVal);
        end


        function NUM_INPUTS=getNumberOfInputs(obj)
            [~,NUM_INPUTS]=length(obj.InputVariables);
            NUM_INPUTS=NUM_INPUTS-1;
        end


        function[varName,varValue]=getVariableFromMapping(obj,inMapping)



            varValue=[];
            varName='';

        end


        function InputVariablePlugin=getInputVariablePluginFromIndex(obj,mappingIndex)

            varValue=getVariableByIndex(obj,mappingIndex);
            varName=[obj.InputVariableNames,'(:,',num2str(mappingIndex),')'];

            InputVariablePlugin=getInputVariablePlugin(obj,varName,varValue);
        end

    end


    methods(Access=protected)


        function IS_GOOD=qualifyVarNames(~,varNames)
            if~ischar(varNames)
                IS_GOOD=false;
                return;
            end

            IS_GOOD=true;
        end


        function IS_GOOD=qualifyVarValues(~,varValues)

            IS_GOOD=iofile.Util.isValidSignalDataArray(varValues);

        end


        function overrideConstructorErrorMessages(obj)

            obj.VARNAME_ERR='var names must a char array';
            obj.VARVALUES_ERR='var values must be a structure with or without time';
        end
    end
end
