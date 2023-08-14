classdef BuildExampleModelSkip<handle





    properties(GetAccess=public,SetAccess=private)
Models
IsEnabled
    end

    methods(Access=public)
        function this=BuildExampleModelSkip()
            this.Models={};
            this.IsEnabled=true;
            this.cleanup();
        end

        function delete(this)
            this.cleanup();
        end

        function addModel(this,model)
            if this.IsEnabled
                this.Models{end+1}=model;
            end
        end

        function disable(this)
            this.IsEnabled=false;
            this.cleanup();
        end

        function result=skip(this,model)
            result=this.IsEnabled&&ismember(model,this.Models);
            if result
                fprintf("Skipping %s \n",model);
            end
        end

        function skipChildren(this,model,childModels)
            if~this.IsEnabled
                return;
            end

            locModelsToSkip=intersect(childModels,this.Models);
            if isempty(locModelsToSkip)
                return;
            end

            fprintf("Adding %s to skip list for %s\n",strjoin(locModelsToSkip,", "),model);
            cellfun(@(x)Simulink.ModelReference.RebuildManager.addModelToSkipList(model,x),locModelsToSkip);
        end
    end

    methods(Access=private)
        function cleanup(~)
            Simulink.ModelReference.RebuildManager.clearRebuildManager();
        end
    end
end
