classdef BlockTag<handle


    properties
        block=[]
        name=[]
    end


    methods
        function this=BlockTag(block,name)
            this.block=block;
            this.name=name;
        end


        function value=getValue(this)
            value=[];
            blockTagValue=get_param(this.block.getPath(),'Tag');

            if~isempty(blockTagValue)
                try
                    eval(blockTagValue);
                    value=eval(this.name);
                catch
                end
            end
        end
    end
end
