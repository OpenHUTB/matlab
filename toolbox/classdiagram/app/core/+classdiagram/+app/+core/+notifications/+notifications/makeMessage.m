function msg=makeMessage(varargin)
    [varargin{:}]=convertStringsToChars(varargin{:});
    msg=message([varargin{1}],varargin{2:end});
end