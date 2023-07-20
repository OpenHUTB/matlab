


classdef TargetBase




    properties
        ModelName;
        TestHarnessName;
        ComponentType;
        Connectivity;
    end

    properties(Dependent=true,SetAccess=private)

        ExecType;
    end



    methods
        function value=get.ExecType(obj)

            value=[obj.ComponentType,'_',obj.Connectivity];
        end


        function delete(this)
        end
    end
    methods(Abstract=true)
        setupTarget(this)
    end

end


