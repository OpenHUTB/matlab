function ff=getFoldingFactor(this)





    ff=zeros(1,length(this.Stage));
    for n=1:length(this.Stage)
        ff(n)=getFoldingFactor(this.stage(n));
    end


