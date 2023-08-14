classdef ImportProfileToModelNOAction<handle

    properties
        tag;
    end

    methods
        function this=ImportProfileToModelNOAction(tag)
            this.tag=tag;
        end

        function tag=getTag(this)
            tag=this.tag;
        end

        function label=getDisplayLabel(this)
            label=DAStudio.message('SystemArchitecture:ProfileDesigner:Select');
        end

        function icon=getDisplayIcon(~)

            icon='';
        end

        function is=getEnabled(~)
            is=true;
        end
    end

end
