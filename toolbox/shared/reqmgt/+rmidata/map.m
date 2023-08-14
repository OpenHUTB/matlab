function[varargout]=map(model,varargin)


    model=convertStringsToChars(model);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    disp('rmidata.map() is deprecated. Please use rmi(''map'',...) instead.');

    varargout{1}=rmi('map',model,varargin{:});

end
