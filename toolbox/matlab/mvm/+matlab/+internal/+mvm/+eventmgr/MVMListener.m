

classdef(Sealed=true)MVMListener<handle




    properties
Source
EventName
Callback
Enabled
Recursive
    end

    properties(Hidden=true,Access=?matlab.internal.mvm.eventmgr.MVMEvent)
WhenDestroyed
ExecutionDepth
    end

    methods(Access={?matlab.internal.mvm.eventmgr.MVMEvent})
        function obj=MVMListener(eventName,callback)



            if(~(isa(eventName,'char')||(isa(eventName,'string'))))
                error('first argument (eventName) must be a char array or a string');
            end
            if(~isa(callback,'function_handle'))
                error('second argument (callback) must be a function handle');
            end
            obj.Source=[];
            obj.EventName=eventName;
            obj.Callback=callback;
            obj.Enabled=true;
            obj.Recursive=false;
            obj.ExecutionDepth=0;
        end
    end

    methods
        function delete(obj)

            if~isempty(obj.WhenDestroyed)
                try
                    obj.WhenDestroyed();
                catch E
                    warning(E.msg);
                end
            end
        end
    end
end
