function rtp=buildRapidAcceleratorTarget(varargin)
































    rtp=cpp_feval_wrapper('slprivate','buildBDRapidAcceleratorTargetImpl',varargin{:});

end

