function f=framesAvailable(this)





    if~isempty(this.prevPanel.data)
        f=size(this.prevPanel.data,4);
    else
        f=0;
    end

end