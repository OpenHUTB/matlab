classdef ModelWorkspaceVariable<lutdesigner.data.source.DataSource

    methods
        function this=ModelWorkspaceVariable(model,variableName)
            this=this@lutdesigner.data.source.DataSource(...
            'model workspace',...
            getfullname(model),...
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
            ws=get_param(this.Source,'ModelWorkspace');
            data=evalin(ws,this.Name);
        end

        function writeImpl(this,data)
            ws=get_param(this.Source,'ModelWorkspace');
            assignin(ws,this.Name,data);
        end
    end
end
