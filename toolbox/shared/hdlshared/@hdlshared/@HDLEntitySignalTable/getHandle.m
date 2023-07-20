function handle=getHandle(this,indices)





    if isscalar(indices)
        handle=this.PortHandles(indices);
    else
        handle={};
        for n=1:length(indices)
            vec{n}=this.PortHandles(indices(n));
        end
    end

