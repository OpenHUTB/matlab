

















function textRange=createTextRange(varargin)





    [varargin{:}]=convertStringsToChars(varargin{:});

    textRange=[];
    lines=varargin{nargin};
    if~isnumeric(lines)
        error(message('Slvnv:slreq_objtypes:NoLinesArgument'));
    end
    switch nargin
    case 3
        artifact=slreq.utils.validateArtifactUri(varargin{1});
        textId=varargin{2};
    case 2
        [artifact,textId]=slreq.TextRange.resolveTextUnitId(varargin{1});
        if isempty(artifact)
            return;
        end
    otherwise
        error(message('Slvnv:reqmgt:rmi:WrongArgumentNumber'));
    end

    [~,~,fExt]=fileparts(artifact);
    switch fExt
    case '.mdl'
        error(message('Slvnv:slreq_objtypes:NoSupportMDL'));
    case '.slx'
        domain='linktype_rmi_simulink';
    otherwise
        domain='linktype_rmi_matlab';
    end

    dataLinkSet=slreq.utils.getLinkSet(artifact,domain,true);

    if~isempty(dataLinkSet)
        linkSet=slreq.LinkSet(dataLinkSet);
        textRange=linkSet.createTextRange(textId,lines);
    end
end
