function wasClosed=closeReport(this,rpt,varargin)







    if nargin<2
        rpt=this.getCurrentDoc;
    end

    wasClosed=true;
    if isempty(rpt)

    elseif isa(rpt,'rptgen.DAObject')

        nextSelect=rpt.left;
        if isempty(nextSelect)
            nextSelect=rpt.right;
        end
        if isempty(nextSelect)
            nextSelect=rpt.up;
        end

        wasClosed=doClose(rpt,varargin{:});

        if wasClosed&&isa(this.Editor,'DAStudio.Explorer')
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent',this);
            m=DAStudio.imMode;%#ok Force UI to be synchronous
            this.Editor.view(nextSelect);
        end
    elseif ischar(rpt)
        wasClosed=this.closeReport(this.findRptByName(rpt),varargin{:});
    else
        warning(message('rptgen:RptgenML_Root:closingUnknownObject',class(rpt)));
    end
