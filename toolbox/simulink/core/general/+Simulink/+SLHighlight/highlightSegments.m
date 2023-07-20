function style=highlightSegments(segmentHandles,objs,varargin)




    import Simulink.SLHighlight.*;

    highlighter=SLHighlighter.Instance;
    if~isempty(objs)
        bd=bdroot(objs(1));
    else
        bd=get_param(bdroot,'Handle');
    end

    style=highlighter.highlightElements(objs,segmentHandles,bd,varargin{:});

end
