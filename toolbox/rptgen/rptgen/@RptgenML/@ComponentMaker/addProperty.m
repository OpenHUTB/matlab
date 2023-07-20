function d=addProperty(this,varargin)



















    d=RptgenML.ComponentMakerData(varargin{:});
    firstChild=this.down;
    if isempty(firstChild)
        connect(d,this,'up');
    else
        connect(d,firstChild,'right');
    end
    d.updateErrorState;

    this.setDirty(true);


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyChangedEvent',this);


    this.DlgCurrentPropertyIdx=length(this.getHierarchicalChildren);



    if isa(this.up,'RptgenML.Root')
        expandChildren(this.up,this);
    end
