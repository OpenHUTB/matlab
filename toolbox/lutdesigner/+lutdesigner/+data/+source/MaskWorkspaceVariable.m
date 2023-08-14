classdef MaskWorkspaceVariable<lutdesigner.data.source.DataSource

    methods
        function this=MaskWorkspaceVariable(maskOwner,variableName)
            this=this@lutdesigner.data.source.DataSource(...
            'mask workspace',...
            regexprep(getfullname(maskOwner),'\s',' '),...
            variableName);
        end
    end

    methods(Access=protected)
        function restrictions=getReadRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.ReadRestriction.empty();
        end

        function restrictions=getWriteRestrictionsImpl(~)
            restrictions=lutdesigner.data.restriction.WriteRestriction('lutdesigner:data:localMaskWorkspaceVariable');
        end

        function data=readImpl(this)
            this.forceMaskInitializationIfPossible();
            mask=Simulink.Mask.get(this.Source);
            vars=mask.getWorkspaceVariables();
            var=vars(arrayfun(@(v)strcmp(v.Name,this.Name),vars));
            data=var.Value;
        end

        function writeImpl(~,~)
        end
    end

    methods(Access=private)
        function forceMaskInitializationIfPossible(this)
            anyChild=find_system(this.Source,'FirstResultOnly','on','Type','block');
            if~isempty(anyChild)
                slResolve('forceMaskInitialization',anyChild{1});
            end
        end
    end
end
