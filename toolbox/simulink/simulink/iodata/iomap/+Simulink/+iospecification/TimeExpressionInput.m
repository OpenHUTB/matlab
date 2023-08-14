classdef TimeExpressionInput<Simulink.iospecification.ExternalInput




    methods























        function varNames=conditionVarNames(obj,varNames)


        end



        function InputVariablePlugin=getInputVariablePluginFromIndex(obj,mappingIndex)

            InputVariablePlugin=Simulink.iospecification.NullInput(num2str(mappingIndex),'');
        end
    end

    methods(Access='protected')


        function IS_GOOD=qualifyVarNames(~,varNames)
            if~ischar(varNames)
                IS_GOOD=false;
                return;
            end

            IS_GOOD=true;
        end


        function IS_GOOD=qualifyVarValues(~,varValues)
            if~ischar(varValues)
                IS_GOOD=false;
                return;
            end

            IS_GOOD=true;
        end
    end

end
