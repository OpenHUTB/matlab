classdef PrjImportProducer<coderapp.internal.config.AbstractProducer
    methods
        function imported=import(~,imported)

        end
        function produce(this)
            val=this.value('prjImportInput');

            if~isempty(val)
                this.requestImport(val,true,false);
            end
        end
    end
end
