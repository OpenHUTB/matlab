classdef MainModel<handle




    properties(Access=private)
Model
    end

    methods(Hidden)

        function this=MainModel()
            this.Model=wavelettfanalyzer.internal.models.Model();
        end


        function model=getModel(this)
            model=this.Model;
        end
    end

end
