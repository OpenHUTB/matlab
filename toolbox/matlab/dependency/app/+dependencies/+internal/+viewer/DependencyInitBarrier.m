classdef DependencyInitBarrier<handle





    properties(GetAccess=public,SetAccess=immutable)
Initialized
    end

    properties(GetAccess=private,SetAccess=immutable)
Subscription
    end

    methods
        function this=DependencyInitBarrier(uuid)
            channel="/dependency/viewer/"+uuid+"/init";
            initialized=dependencies.internal.widget.event.ReusableBarrier;
            connector.ensureServiceOn();
            this.Subscription=message.subscribe(...
            channel,@(varargin)initialized.notify());
            this.Initialized=initialized;
        end

        function delete(this)
            message.unsubscribe(this.Subscription);
        end
    end
end
