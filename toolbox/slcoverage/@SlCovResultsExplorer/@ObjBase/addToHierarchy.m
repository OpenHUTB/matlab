function varargout=addToHierarchy(this,newElement)




    firstChild=this.down;
    if(~isempty(firstChild))&&(firstChild==newElement)

    else
        connect(this,newElement,'down');
    end


    if nargout>0
        varargout{1}=newElement;
    end





