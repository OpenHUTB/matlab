function setDirty(this,tf)




    if nargin<2||tf
        this.Dirty=true;
    else
        set(find(this,'Dirty',true),...
        'Dirty',false);
    end
