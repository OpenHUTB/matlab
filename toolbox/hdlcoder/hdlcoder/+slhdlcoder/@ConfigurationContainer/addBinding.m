function addBinding(this,scope,block,blockparams,impl,implparams)











    if nargin<6
        implparams=[];
    end

    if strcmpi(scope,'*')
        this.defaultFor(block,blockparams,impl,implparams);
    else
        this.forEach(scope,block,blockparams,impl,implparams);
    end


