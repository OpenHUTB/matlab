function crviewer(varargin)




    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    RTW.viewTfl(varargin{:});

