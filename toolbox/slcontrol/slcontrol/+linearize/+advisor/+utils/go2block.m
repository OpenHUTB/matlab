function varargout=go2block(blk)

    if iscell(blk)&&isscalar(blk)
        blk=blk{1};
    end
    validateattributes(blk,{'char','string'},{'scalartext'});
    blk=char(blk);

    root=strtok(blk,'/');
    load_system(root);
    name=regexprep(get_param(blk,'Name'),'\n',' ');
    highlighter=linearize.advisor.highlighter.SCDHighlighter(blk,[],[],name,...
    LocalGetHighlightingOptions);
    highlightBlock(highlighter);
    if nargout>0
        varargout{1}=[];
        if nargout>1
            varargout{2}=highlighter;
        end
    end

    function opts=LocalGetHighlightingOptions()
        opts=linearize.advisor.highlighter.SCDHighlighter.getDefaultHLOptions;
        opts.blockfillcolor=[1,1,0,1];

