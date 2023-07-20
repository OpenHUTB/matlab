function forAll(this,scope,block,blockparams,impl,implparams)





    if~ischar(scope)||~ischar(block)||~ischar(impl)

        disp(sprintf('Invalid configuration ''forAll'' statement in file: %s',this.fileName));
        display(path);
        display(block);
        display(impl);
    end

    if iscell(blockparams)
        blockparams={blockparams};
    end

    if nargin<6||isempty(implparams)
        implparams={{block}};
    else
        if iscell(implparams)
            implparams={cat(1,{block},implparams(:))};
        else
            implparams={{block;implparams}};
        end
    end

    if length(scope)>1&&~strcmp(scope(end),'*')
        if strcmp(scope(end),'/')
            scope=[scope,'*'];
        else
            scope=[scope,'/*'];
        end
    elseif strcmp(scope,'/')
        scope='*';
    end

    newbinding=local_make_configstmt(scope,block,blockparams,impl,implparams);
    if isempty(this.statements)
        this.statements=newbinding;
    else
        this.statements(end+1)=newbinding;
    end





    function newbinding=local_make_configstmt(scope,block,blockparams,impl,implparams)
        newbinding=struct(...
        'Scope',scope,...
        'BlockType',block,...
        'BlockParams',blockparams,...
        'Implementation',impl,...
        'ImplParams',implparams);


