function cleanup(this)




    if(~isempty(this.CloseListener))
        delete(this.CloseListener);
    end
    if(~isempty(this.SDIListeners))
        delete(this.SDIListeners);
    end
    delete(this);
end