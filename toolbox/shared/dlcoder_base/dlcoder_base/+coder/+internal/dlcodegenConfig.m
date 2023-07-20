function cfgObj=dlcodegenConfig(varargin)

























    try
        cfgObj=coder.internal.dlcodegenConfigBase(varargin{:});
    catch err
        throwAsCaller(err);
    end


end
