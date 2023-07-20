classdef SignalCheckListener<handle


    properties
        modelName='';
        openTask=0;
    end

    properties(Access=private)
        listeners=[];
    end

    methods
        function this=SignalCheckListener(modelName)
            this.modelName=modelName;
            this.listenToSelectionChange();
        end
    end

    methods(Access=private)

        listenToSelectionChange(this);
        onSelectionChange(this,evt);
    end
end

