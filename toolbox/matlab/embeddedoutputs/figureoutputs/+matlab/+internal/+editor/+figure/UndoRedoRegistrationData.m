classdef UndoRedoRegistrationData<event.EventData





    properties
        Object;
ActionToRegister
        DoRegisterLEUndoRedo logical
        IsUndoable(1,1)logical=true
    end

    methods
        function obj=UndoRedoRegistrationData(hObject,actionToRegister,isUndoable,doRegisterUndoRedo)
            obj.Object=hObject;
            obj.ActionToRegister=actionToRegister;
            obj.IsUndoable=isUndoable;
            obj.DoRegisterLEUndoRedo=doRegisterUndoRedo;
        end
    end

end