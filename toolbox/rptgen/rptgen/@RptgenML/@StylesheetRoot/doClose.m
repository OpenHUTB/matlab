function wasClosed=doClose(this,varargin)






    thisChild=this.down;
    wasClosed=true;
    while~isempty(thisChild)&&wasClosed
        nextChild=thisChild.right;
        wasClosed=thisChild.doClose(varargin{:});
        thisChild=nextChild;
    end

    if wasClosed

        disconnect(this);
    end


