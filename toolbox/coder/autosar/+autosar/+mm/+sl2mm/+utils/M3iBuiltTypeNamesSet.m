classdef M3iBuiltTypeNamesSet<handle




    properties(Access=private)
        M3iBuiltTypeNames;
    end

    methods(Access=public)
        function this=M3iBuiltTypeNamesSet()
            this.M3iBuiltTypeNames={};
        end

        function appendType(this,m3iType)
            if this.isValidType(m3iType)
                this.M3iBuiltTypeNames{end+1}=m3iType.Name;
                this.M3iBuiltTypeNames=unique(this.M3iBuiltTypeNames);
            end
        end

        function typeNames=getTypeNames(this)
            typeNames=this.M3iBuiltTypeNames;
        end

    end

    methods(Static,Access=private)
        function validity=isValidType(m3iType)
            validity=isa(m3iType,'Simulink.metamodel.foundation.ValueType')...
            ||isa(m3iType,'Simulink.metamodel.arplatform.common.ModeDeclarationGroup');
        end
    end

end


