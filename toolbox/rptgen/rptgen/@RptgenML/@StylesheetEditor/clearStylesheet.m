function clear(this)






    thisChild=down(this);
    while~isempty(thisChild)
        nextChild=thisChild.right;
        delete(thisChild);
        thisChild=nextChild;
    end

    setDirty(this,false);
    this.ErrorMessage='';
    this.JavaHandle=[];

    r=this.up;
    if isa(r,'RptgenML.Root')
        enableActions(r);


        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',this);
    end