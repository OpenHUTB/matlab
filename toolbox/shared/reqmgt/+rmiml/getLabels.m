function result=getLabels(varargin)





    [varargin{:}]=convertStringsToChars(varargin{:});

    result='';
    reqs=rmiml.getReqs(varargin{:});

    if~isempty(reqs)

        descriptions=cell(size(reqs));
        for i=1:numel(reqs)
            descriptions{i}=slreq.internal.getDescriptionOrDestSummary(reqs(i));
        end

        result=oneLineLabel(descriptions{1});
        for i=2:length(descriptions)
            result=[result,newline,oneLineLabel(descriptions{i})];%#ok<AGROW>
        end
    end

end

function out=oneLineLabel(in)
    if isempty(in)
        in=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
    end
    out=strrep(in,newline,' ');
end
