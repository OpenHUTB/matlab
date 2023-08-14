classdef ConstructArgs

    properties(Access=private)
m_args
    end

    methods(Access=public)
        function obj=ConstructArgs(varargin)
            obj.m_args=varargin;
        end

        function args=getArgs(this)
            args=this.m_args;
        end
    end
end
