classdef BusActionWrapper<handle


    properties(Access=protected)


        mData;
    end


    methods(Access=protected,Abstract)
        msg=executeImpl(this)
    end






    methods(Access=protected)

        function this=BusActionWrapper(editor,selection)
            narginchk(2,2);
            this.mData=struct();
            this.mData.editor=editor;
            this.mData.selection=selection;
        end
    end


    methods(Sealed=true)
        function tf=canExecute(this)
            tf=false;

            try
                acts=struct2cell(this.mData.actions);
                for i=1:numel(acts)
                    if acts{i}.canExecute()
                        tf=true;
                        return;
                    end
                end
            catch ex
                tf=false;
                if slsvTestingHook('BusActionsRethrow')==1
                    rethrow(ex);
                end
            end
        end

        function execute(this)
            try
                if~this.canExecute()
                    return;
                end

                msg=this.executeImpl();

                if~isempty(msg)
                    warndlg(msg);
                end
            catch ex
                if slsvTestingHook('BusActionsRethrow')==1
                    rethrow(ex);
                end
            end
        end
    end
end
