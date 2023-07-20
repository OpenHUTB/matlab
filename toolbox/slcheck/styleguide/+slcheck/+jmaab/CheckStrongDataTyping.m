classdef CheckStrongDataTyping<slcheck.subcheck
    methods
        function obj=CheckStrongDataTyping(InitParams)
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID=InitParams.Name;
        end
        function result=run(this)
            result=false;
        end
    end
end