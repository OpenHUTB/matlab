classdef(Abstract)DependencyHandler<handle&matlab.mixin.Heterogeneous

    properties(Abstract,Constant)

        Types(1,:)string;
    end

    methods

        function unhilite=openDownstream(this,dependency)%#ok<INUSD>
            unhilite=@()[];
        end


        function unhilite=openUpstream(this,dependency)%#ok<INUSD>
            unhilite=@()[];
        end
    end
end
