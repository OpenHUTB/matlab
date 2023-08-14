classdef MATLABWorkspace<ee.internal.app.common.model.Workspace




    methods
        function variables=whos(~)
            variables=evalin('base','whos');
        end

        function value=importVariable(~,name)
            value=evalin('base',name);
        end













    end

end