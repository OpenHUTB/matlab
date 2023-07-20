classdef ModelClose<handle





    properties(Access=protected)
        closeListener;
    end

    methods(Access=public)
        function registerCloseListener(this,bdHdl)



            if~isempty(this.closeListener)
                delete(this.closeListener);
            end

            bdObj=get_param(bdHdl,'Object');
            this.closeListener=...
            Simulink.listener(bdObj,'CloseEvent',@(s,e)onModelClose(this));
        end

        function onModelClose(this)

            delete(this);
        end
    end
end