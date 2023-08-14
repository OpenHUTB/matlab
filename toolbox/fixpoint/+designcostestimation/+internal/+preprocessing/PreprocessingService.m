classdef PreprocessingService<handle





    properties(SetAccess=private)
        Model(1,:)char
        Actions(1,:)cell

    end

    methods

        function obj=PreprocessingService(model)
            obj.Model=model;
            obj.collectActions();
        end


        function process(obj)



            for idx=1:numel(obj.Actions)
                currentAction=obj.Actions{idx};
                currentAction(obj.Model);
            end
        end
    end

    methods(Hidden,Access=private)

        function collectActions(obj)

            obj.Actions{1}=@designcostestimation.internal.preprocessing.isCodegenReady;

            obj.Actions{2}=@designcostestimation.internal.preprocessing.hasMismatchedConfigsets;
        end

    end
end
