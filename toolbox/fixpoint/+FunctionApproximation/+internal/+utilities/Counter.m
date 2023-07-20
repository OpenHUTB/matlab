classdef Counter<handle



    properties(SetAccess=private)
        Count;
    end

    methods
        function getNext(this)

            if isempty(this.Count)
                this.Count=0;
            end

            this.Count=this.Count+1;
        end
    end
end