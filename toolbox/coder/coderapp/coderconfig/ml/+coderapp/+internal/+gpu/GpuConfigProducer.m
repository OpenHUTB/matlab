classdef(Sealed)GpuConfigProducer<coderapp.internal.config.util.CompositeProducer




    methods
        function this=GpuConfigProducer()
            this@coderapp.internal.config.util.CompositeProducer('coder.gpu.config',...
            'BoundObjectKey','boundGpuConfig',...
            'SyncBoundWithValidation',false,...
            'Reuse',false);
        end
    end

    methods(Access=protected)
        function instance=instantiate(this)
            if isempty(this.value('boundGpuConfig'))
                if this.value('gpuEnabled')


                    instance=coder.gpu.config();
                    instance.Enabled=true;
                else
                    instance=coder.GpuCodeConfig.empty();
                end
            else
                instance=coder.gpu.config();
            end
        end

        function updateScript(this)
            if~isempty(this.value('boundGpuConfig'))
                this.ScriptHelper.setInstantiator('coder.gpu.config');
            else
                this.ScriptHelper.setInstantiator('');


                this.ScriptHelper.updateSnippets(struct('gpuEnabled',[]));
            end
        end

        function imported=postImport(~,cfg,imported)
            if isempty(cfg)
                if isempty(imported)
                    imported=struct();
                end
                imported.gpuEnabled=false;
            end
        end
    end
end

