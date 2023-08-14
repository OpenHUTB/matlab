

classdef MainModel<handle



    properties(Access=private)
Model
    end

    methods

        function this=MainModel(signalMgr,inputSignal)
            this.Model=edffileanalyzer.internal.models.Model(signalMgr,inputSignal);
        end

        function model=getModel(this)
            model=this.Model;
        end
    end
end