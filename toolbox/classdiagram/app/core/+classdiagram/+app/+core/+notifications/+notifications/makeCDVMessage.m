function msg=makeCDVMessage(varargin)
    [varargin{:}]=convertStringsToChars(varargin{:});
    msg=message(['classdiagram_editor:messages:'...
    ,varargin{1}],varargin{2:end});
end