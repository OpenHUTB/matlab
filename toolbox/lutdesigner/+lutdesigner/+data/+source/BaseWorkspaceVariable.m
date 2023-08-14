classdef BaseWorkspaceVariable<lutdesigner.data.source.DataSource

    methods
        function this=BaseWorkspaceVariable(variableName)
            this=this@lutdesigner.data.source.DataSource(...
            'base workspace',...
            'base workspace',...
            variableName);
        end
    end

    methods(Access=protected)
        function restrictions=getReadRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.ReadRestriction.empty();
        end

        function restrictions=getWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction.empty();
        end

        function data=readImpl(this)
            data=evalin('base',this.Name);
        end

        function writeImpl(this,data)
            assignin('base',this.Name,data);
        end
    end
end
