classdef SLTContext<dig.CustomContext






    properties(SetAccess=private,SetObservable=true)
Model
    end

    methods
        function obj=SLTContext(model,app)
            obj=obj@dig.CustomContext(app);
            obj.Model=model;
        end


    end
end
