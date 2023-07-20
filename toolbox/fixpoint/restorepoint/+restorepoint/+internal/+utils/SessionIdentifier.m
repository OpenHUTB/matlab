classdef(Sealed)SessionIdentifier<handle






    methods(Access=?restorepoint.internal.utils.SessionInformationManager)
        function obj=SessionIdentifier
            obj.PID=feature('getpid');
            obj.UUID=char(matlab.lang.internal.uuid);
            obj.Time=now;
        end
    end

    properties(GetAccess=public,SetAccess=?fxpRestorepoint.SessionIdentifierAccessor)
PID
UUID
Time
    end

    properties(GetAccess=public,SetAccess=public)



        NodeName char
        ModelName char
        ModelPath char
    end

    methods
        function isequal=eq(obj1,obj2)
            isequal=false;
            if~isa(obj1,'restorepoint.internal.utils.SessionIdentifier')
                return;
            end
            if~isa(obj2,'restorepoint.internal.utils.SessionIdentifier')
                return;
            end
            if obj1.PID~=obj2.PID
                return;
            end
            if obj1.Time~=obj2.Time
                return;
            end
            if~strcmp(obj1.UUID,obj2.UUID)
                return;
            end
            isequal=true;
        end
    end
end


