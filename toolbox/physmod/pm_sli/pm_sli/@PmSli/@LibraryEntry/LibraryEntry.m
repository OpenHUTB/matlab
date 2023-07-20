function hObj=LibraryEntry(varargin)





















    hObj=PmSli.LibraryEntry;

    if nargin>0
        hObj.initialize(varargin{:});
    end

end
