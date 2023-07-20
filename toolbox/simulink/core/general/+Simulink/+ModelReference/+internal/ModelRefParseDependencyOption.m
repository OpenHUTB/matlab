classdef ModelRefParseDependencyOption<uint8



    enumeration
        PARSE_MODEL_WORKSPACE(1)
        PARSE_NON_MODEL_WORKSPACE(2)
    end

    methods(Static)
        function result=pruneDeps(parseOption,deps)
            import Simulink.ModelReference.internal.ModelRefParseDependencyOption.isWorkspaceDep
            switch(parseOption)
            case 'PARSE_MODEL_WORKSPACE'
                matches=arrayfun(@(x)isWorkspaceDep(x.Type),deps);
            case 'PARSE_NON_MODEL_WORKSPACE'
                matches=arrayfun(@(x)~isWorkspaceDep(x.Type),deps);
            end
            result=deps(matches);
        end

        function result=isWorkspaceDep(depType)
            result=strcmp(depType,'MODELDEP_WORKSPACE_FILE');
        end
    end
end