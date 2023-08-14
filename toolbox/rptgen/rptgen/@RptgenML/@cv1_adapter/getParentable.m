function p=getParentable(this)






    i=getinfo(this);

    p=(isempty(i.ValidChildren)|...
    ~i.ValidChildren{1});