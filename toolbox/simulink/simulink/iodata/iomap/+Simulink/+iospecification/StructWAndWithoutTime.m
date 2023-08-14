classdef StructWAndWithoutTime<Simulink.iospecification.ExternalInput









    methods


        function varNames=conditionVarNames(obj,varNames)

        end


        function varValue=getVariableByName(obj,varName)

            varValue='';
        end


        function varValue=getVariableByIndex(obj,idx)

            dataVal=obj.InputVariables.signals(idx).values;
            timeVal=[1:length(dataVal)]';

            if isfield(obj.InputVariables,'time')&&~isempty(obj.InputVariables.time)
                timeVal=obj.InputVariables.time;
            end

            varValue=timeseries(dataVal,timeVal);
        end


        function NUM_INPUTS=getNumberOfInputs(obj)
            NUM_INPUTS=length(obj.InputVariables.signals);
        end


        function[varName,varValue]=getVariableFromMapping(obj,inMapping)



            varValue=[];
            varName='';

        end


        function InputVariablePlugin=getInputVariablePluginFromIndex(obj,mappingIndex)

            varValue=getVariableByIndex(obj,mappingIndex);
            varName=obj.InputVariables.signals(mappingIndex).label;

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

            IS_GOOD=Simulink.sdi.internal.Util.isStructureWithTime(varValues)||...
            Simulink.sdi.internal.Util.isStructureWithoutTime(varValues);

        end


        function overrideConstructorErrorMessages(obj)

            obj.VARNAME_ERR='sl_iospecification:inputvariables:structwtimeinputVarnameErr';
            obj.VARVALUES_ERR='sl_iospecification:inputvariables:structwtimeinputVarvalueErr';
        end
    end
end
