classdef ReusableBarrier<dependencies.internal.widget.event.Barrier





    properties(GetAccess=public,SetAccess=private)
        HasFired(1,1)logical=false;
    end

    properties(Access=private)
        Actions(1,:)cell={};
    end

    methods

        function execute(this,action)
            if this.HasFired
                action();
            else
                this.Actions{end+1}=action;
            end
        end

        function notify(this)
            this.HasFired=true;

            actions=this.Actions;
            this.Actions={};

            for action=actions
                action{1}();
            end
        end

        function reset(this)
            this.HasFired=false;
        end

    end

end
