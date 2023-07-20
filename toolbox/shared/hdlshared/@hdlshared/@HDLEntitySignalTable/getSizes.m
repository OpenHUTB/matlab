function sizes=getSizes(this,indices)





    if isscalar(indices)
        sltype=this.Signals(indices).SLType;
        [size,bp,signed]=hdlwordsize(sltype);
        sizes=[size,bp,signed];
    else
        sizes=zeros(length(indices),3);
        for n=1:length(indices)
            sltype=this.Signals(indices(n)).SLType;
            [size,bp,signed]=hdlwordsize(sltype);
            sizes(n,:)=[size,bp,signed];
        end
    end

