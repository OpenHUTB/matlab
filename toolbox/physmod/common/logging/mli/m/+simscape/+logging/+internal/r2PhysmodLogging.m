function value=r2PhysmodLogging(varargin)





    try
        value=builtin('_r2_physmod_logging',varargin{:});
    catch ME
        ME.throwAsCaller();
    end
end
