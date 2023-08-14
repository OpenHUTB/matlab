























function textRanges=getTextRanges(varargin)
    textRanges=slreq.TextRange.empty();








    if nargin<1
        error(message('Slvnv:reqmgt:rmi:NotEnoughArguments'));
    end

    [varargin{:}]=convertStringsToChars(varargin{:});

    if isnumeric(varargin{nargin})
        lines=varargin{nargin};
    else
        lines=[];
    end
    if nargin>1&&ischar(varargin{2})
        artifact=slreq.utils.validateArtifactUri(varargin{1});
        textId=varargin{2};
    else
        [artifact,textId]=slreq.TextRange.resolveTextUnitId(varargin{1});
        if isempty(artifact)
            return;
        end
    end


    linkSet=slreq.find('type','LinkSet','Artifact',artifact);
    if~isempty(linkSet)
        textRanges=linkSet.getTextRanges(textId,lines);
    end
end
