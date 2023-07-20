classdef GUI





    methods(Static)
        gui=pbGUI(varargin)
        open(varargin)
        close(blockId)
    end


    methods(Hidden=true,Static=true)
        gui=getSetGUI(blockId,obj)
    end
end
