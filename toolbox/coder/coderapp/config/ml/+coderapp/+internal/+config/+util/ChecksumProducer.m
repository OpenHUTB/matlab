classdef(Sealed)ChecksumProducer<handle&coderapp.internal.config.AbstractProducer



    properties(Access=private)
OrderedKeys
    end

    methods
        function produce(this)
            if~iscell(this.OrderedKeys)
                this.OrderedKeys=sort(this.keys());
            end
            input=this.value(this.OrderedKeys);
            checksum=lower(strjoin(dec2hex(CGXE.Utils.md5(input)),''));
            if~strcmp(checksum,this.Production)
                this.Production=checksum;
            end
        end
    end
end