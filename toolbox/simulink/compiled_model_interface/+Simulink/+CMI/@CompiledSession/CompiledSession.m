classdef CompiledSession<Simulink.CMI.cpp.CompiledSession
    methods
        function obj=CompiledSession(varargin)
            obj=obj@Simulink.CMI.cpp.CompiledSession(varargin{:});
        end
        function init(obj,varargin)
            init@Simulink.CMI.cpp.CompiledSession(obj,varargin{:});
        end
        function term(obj,bd)
            term@Simulink.CMI.cpp.CompiledSession(obj,bd);
        end
    end
end
