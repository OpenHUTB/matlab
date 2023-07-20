function defaultFor(this,block,blockparams,impl,implparams)





    if~ischar(block)||~ischar(impl)

        disp(sprintf('Invalid configuration ''DefaultFor'' statement in file: %s',this.fileName));
        disp(sprintf('Invalid configuration statement: %s',this.fileName));
        display(block);
        display(impl);
    end

    if iscell(blockparams)
        blockparams={blockparams};
    end

    if nargin<5||isempty(implparams)
        implparams={{block}};
    else
        if iscell(implparams)
            implparams={cat(1,{block},implparams(:))};
        else
            implparams={{block;implparams}};
        end
    end







    newbinding=struct(...
    'Scope','*',...
    'BlockType',block,...
    'BlockParams',blockparams,...
    'Implementation',impl,...
    'ImplParams',implparams);

    if isempty(this.defaults)
        this.defaults=newbinding;
    else
        this.defaults(end+1)=newbinding;
    end


