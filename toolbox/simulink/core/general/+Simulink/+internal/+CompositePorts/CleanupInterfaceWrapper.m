classdef(Sealed)CleanupInterfaceWrapper<Simulink.internal.CompositePorts.BusActionWrapper


    methods

        function this=CleanupInterfaceWrapper(varargin)

            this=this@Simulink.internal.CompositePorts.BusActionWrapper(varargin{:});
            try
                this.mData.actions.input=Simulink.internal.CompositePorts.CleanupInputInterface(this.mData.editor,this.mData.selection);
                this.mData.actions.output=Simulink.internal.CompositePorts.CleanupOutputInterface(this.mData.editor,this.mData.selection);
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
            if this.mData.actions.input.canExecute()
                msg=this.mData.actions.input.execute();
            elseif this.mData.actions.output.canExecute()
                msg=this.mData.actions.output.execute();
            end
        end
    end
end
