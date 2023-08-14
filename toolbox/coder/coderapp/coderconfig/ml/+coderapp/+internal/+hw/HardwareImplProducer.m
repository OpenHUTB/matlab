classdef(Sealed)HardwareImplProducer<coderapp.internal.config.util.CompositeProducer




    methods
        function this=HardwareImplProducer()
            this@coderapp.internal.config.util.CompositeProducer('coder.HardwareImplementation',...
            'BoundObjectKey','boundHardwareImpl',...
            'SyncBoundWithValidation',false);
        end
    end

    methods(Access=protected)
        function reuse=canReuse(this)
            boundConfig=this.value('boundConfig');
            reuse=isempty(boundConfig)||(isa(boundConfig,'coder.CodeConfig')&&...
            ~isempty(boundConfig.HardwareImplementation));
        end

        function instance=instantiate(this)
            if this.useHardwareImpl()
                instance=instantiate@coderapp.internal.config.util.CompositeProducer(this);
            else
                instance=coder.HardwareImplementation.empty();
            end
        end

        function updateScript(this)
            if~isempty(this.value('boundHardwareImpl'))
                this.ScriptHelper.setInstantiator('coder.HardareImplementation');
            elseif this.useHardwareImpl()
                this.ScriptHelper.setInstantiator('');
            else
                this.ScriptHelper.setInstantiator('coder.HardwareImplementation.empty()');
            end




            [prodDevice,targetDevice]=this.value('x_prodDevice','x_targetDevice');
            update=struct();
            if any(this.isUserModified({'prodDeviceVendor','prodDeviceType'}))
                update.x_prodDevice=string(prodDevice);
            end
            if any(this.isUserModified({'targetDeviceVendor','targetDeviceType'}))
                update.x_targetDevice=string(targetDevice);
            end
            if~isempty(fieldnames(update))
                this.ScriptHelper.updateValues(update);
            end
        end

        function imported=postImport(~,hwImpl,imported)
            if isempty(imported)||isempty(hwImpl)
                return
            end

            prodDevice=strsplit(hwImpl.ProdHWDeviceType,'->');
            [imported.prodDeviceVendor,imported.prodDeviceType]=prodDevice{:};
            targetDevice=strsplit(hwImpl.TargetHWDeviceType,'->');
            [imported.targetDeviceVendor,imported.targetDeviceType]=targetDevice{:};
            imported=rmfield(imported,{'x_prodDevice','x_targetDevice'});
        end

        function[mappedKeys,mappedProps]=keysToProperties(this,varargin)
            if~this.useHardwareImpl()
                mappedKeys={};
                mappedProps={};
                return
            end




            [mappedKeys,mappedProps]=keysToProperties@coderapp.internal.config.util.CompositeProducer(this,varargin{:});
            pSelect=ismember(mappedKeys,{'prodEqTarget','x_prodDevice','x_targetDevice'});
            mappedKeys=[mappedKeys(pSelect);mappedKeys(~pSelect)];
            mappedProps=[mappedProps(pSelect);mappedProps(~pSelect)];
        end
    end

    methods(Access=private)
        function yes=useHardwareImpl(this)
            yes=this.canReuse()||any(this.isUserModified());
        end
    end
end

