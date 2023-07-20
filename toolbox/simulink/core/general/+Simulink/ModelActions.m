classdef ModelActions<handle
    properties(SetAccess=private,GetAccess=public)
ModelName
    end


    methods(Access=public)
        function this=ModelActions(modelName)
            this.ModelName=get_param(modelName,'Name');
        end


        function delete(this)
            this.terminate;
        end


        function compile(this)
            try
                if~strcmp(get_param(this.ModelName,'SimulationStatus'),'paused')
                    this.runEvalcCommand('compileForSizes');
                end
            catch me
                ex=MException(message('Simulink:modelReferenceAdvisor:CannotCompileModel',...
                get_param(this.ModelName,'Name')));
                ex=ex.addCause(me);
                throw(ex);
            end
        end


        function terminate(this)
            if bdIsLoaded(this.ModelName)&&~isempty(this.ModelName)
                if~strcmpi(get_param(this.ModelName,'SimulationStatus'),'stopped')
                    this.runEvalcCommand('term');
                end
            end
        end


        function runEvalcCommand(this,command)
            evalc(sprintf('%s([], [], [], ''%s'')',this.ModelName,command));
        end
    end
end
