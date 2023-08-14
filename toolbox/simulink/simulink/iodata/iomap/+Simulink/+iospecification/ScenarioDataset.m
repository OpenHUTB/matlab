classdef ScenarioDataset<Simulink.iospecification.ExternalInput





    methods


        function varNames=conditionVarNames(obj,varNames)

        end


        function varValue=getVariableByName(obj,varName)


            DOES_MATCH=strcmp(obj.InputVariables.getElementNames,varName);

            if~any(DOES_MATCH)
                DAStudio.error('sl_iospecification:inputvariables:externalInputNoMatchingVarName',varName);
            end

            idxIntoDS=find(DOES_MATCH==1,1,'first');

            varValue=obj.InputVariables.get(idxIntoDS(1));
        end


        function NUM_INPUTS=getNumberOfInputs(obj)
            NUM_INPUTS=length(obj.InputVariables.getElementNames);
        end


        function[varName,varValue]=getVariableFromMapping(obj,inMapping)

            elementStr=inMapping.DataSourceName;


            if~isempty(elementStr)||(isempty(elementStr)&&ischar(elementStr))



                inString=inMapping.InputString;

                stringIndexStart=strfind(inString,elementStr);


                if isempty(stringIndexStart)

                    dsElement=eval(['obj.InputVariables',inString(strfind(inString,'.getElement'):end)]);
                    varName=elementStr;
                else
                    dsElement=obj.InputVariables.getElement(elementStr);
                    varName=elementStr;
                end

                varValue=dsElement;
            else

                varValue=[];
                varName='';
            end
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

            IS_SIMULINK_SIGNAL=isSimulinkSignalFormat(varValues);
            IS_DS_OR_DSREF=isa(varValues,'Simulink.SimulationData.Dataset')||isa(varValues,'Simulink.SimulationData.DatasetRef');

            if~IS_SIMULINK_SIGNAL||~IS_DS_OR_DSREF
                IS_GOOD=false;
                return;
            end

            IS_GOOD=true;
        end


        function overrideConstructorErrorMessages(obj)

            obj.VARNAME_ERR='sl_iospecification:inputvariables:scenariodsinputVarnameErr';
            obj.VARVALUES_ERR='sl_iospecification:inputvariables:scenariodsinputVarvalueErr';
        end
    end
end
