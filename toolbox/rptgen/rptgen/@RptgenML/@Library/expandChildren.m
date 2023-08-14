function expandChildren(this,expandState)






    if nargin<2
        expandState=true;
    end

    thisChild=this.down;
    while~isempty(thisChild)
        if isa(thisChild,'RptgenML.LibraryCategory')
            thisChild.Expanded=expandState;
        end
        thisChild=thisChild.right;
    end

    r=RptgenML.Root;
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ListChangedEvent',r.getCurrentComponent);
