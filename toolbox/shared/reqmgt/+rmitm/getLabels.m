function result=getLabels(varargin)

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    result={};
    reqs=rmitm.getReqs(varargin{:});

    for i=1:length(reqs)
        result{end+1}=oneLineLabel(reqs(i).description);%#ok<AGROW>
    end
end


function out=oneLineLabel(in)
    if isempty(in)
        out=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
    else
        out=rmiut.filterChars(in,false,false);
    end
end
