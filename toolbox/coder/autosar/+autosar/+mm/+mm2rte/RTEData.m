classdef RTEData<handle





    properties(GetAccess='public',SetAccess='protected')
        DataItems;
    end

    methods(Access='public')
        function this=RTEData()
            this.DataItems={};
        end

        function insertItem(this,item)
            this.DataItems{end+1}=item;
        end
    end
end
