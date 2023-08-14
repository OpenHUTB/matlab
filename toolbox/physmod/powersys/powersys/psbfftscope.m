function varargout=psbfftscope(varargin)





    if nargout==0,
        power_fftscope_pr(varargin{:});
    else
        [varargout{1:nargout}]=power_fftscope_pr(varargin{:});
    end