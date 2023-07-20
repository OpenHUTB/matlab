



classdef TypeDataItems<handle



    properties(GetAccess='public',SetAccess='private')
        Items;
    end

    methods(Access='public')
        function this=TypeDataItems(varagin)
            if nargin>0
                this.Items=varagin;
            else
                this.Items=[];
            end
        end
        function addItem(this,item)
            this.Items=[this.Items,item];
        end
    end
end


