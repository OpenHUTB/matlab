classdef(Sealed)CreateBusWrapper<Simulink.internal.CompositePorts.BusActionWrapper


    methods

        function this=CreateBusWrapper(varargin)

            this=this@Simulink.internal.CompositePorts.BusActionWrapper(varargin{:});
            try
                this.mData.actions.simulink=Simulink.internal.CompositePorts.CreateSimulinkBus(this.mData.editor,this.mData.selection);
                this.mData.actions.physmod=Simulink.internal.CompositePorts.CreatePhysmodBus(this.mData.editor,this.mData.selection);
            catch ex
                if slsvTestingHook('BusActionsRethrow')==1
                    rethrow(ex);
                end
            end
        end
    end


    methods(Access=protected)

        function msg=executeImpl(this)
            msg='';
            if this.mData.actions.simulink.canExecute()
                msg=this.mData.actions.simulink.execute();
            elseif this.mData.actions.physmod.canExecute()
                msg=this.mData.actions.physmod.execute();
            end
        end
    end
end
