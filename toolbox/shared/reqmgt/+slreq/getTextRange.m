


























function textRange=getTextRange(varargin)

    [varargin{:}]=convertStringsToChars(varargin{:});

    if nargin>1&&ischar(varargin{end})
        textRange=slreq.TextRange.getRangeById(varargin{:});
    else
        textRange=slreq.getTextRanges(varargin{:});
    end
end

