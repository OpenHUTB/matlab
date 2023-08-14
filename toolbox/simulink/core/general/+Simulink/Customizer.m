




classdef Customizer<handle

    methods(Abstract,Static,Hidden)
        result=getInstance()
    end

    methods(Abstract,Hidden)
        result=clear(obj)
    end
end
