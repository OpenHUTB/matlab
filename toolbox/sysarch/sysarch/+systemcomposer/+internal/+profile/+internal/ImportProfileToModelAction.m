classdef ImportProfileToModelAction<handle

    properties(Access=private)
        mdl;
    end

    methods
        function this=ImportProfileToModelAction(mdl)
            this.mdl=mdl;
        end

        function tag=getTag(this)
            tag=this.mdl;
        end

        function label=getDisplayLabel(this)
            label=this.mdl;
        end

        function icon=getDisplayIcon(~)

            icon='';
        end

        function is=getEnabled(~)
            is=true;
        end
    end

end