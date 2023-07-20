classdef(Hidden,Sealed)InternalProducer<coderapp.internal.config.AbstractProducer


    properties(Constant,Hidden)
        SNAPSHOT_PATH=fullfile(matlabroot,'toolbox/coder/coderapp/common/schemas/globalconfig_snapshot.json')
    end

    methods
        function produce(this)
            keys=this.keys();
            values=this.getScriptValues(keys);
            this.Production=cell2struct(values,keys,2);
        end
    end
end