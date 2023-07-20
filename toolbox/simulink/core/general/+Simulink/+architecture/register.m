function varargout=register(varargin)


















    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    try
        [varargout{1:nargout}]=Simulink.DistributedTarget.internal.register(varargin{:});
    catch err
        if strcmp(err.identifier,'MATLAB:undefinedVarOrClass')
            DAStudio.error('Simulink:mds:CannotRegisterArch');
        else

            throw(err);
        end
    end

end


