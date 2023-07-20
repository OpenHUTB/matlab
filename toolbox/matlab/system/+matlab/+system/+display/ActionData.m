classdef(Sealed)ActionData<handle















    properties





        UserData;
    end

    properties(Hidden,SetAccess=private)



        SystemHandle;
    end

    methods
        function obj=ActionData(systemHandle)
            obj.SystemHandle=systemHandle;
        end
    end
end