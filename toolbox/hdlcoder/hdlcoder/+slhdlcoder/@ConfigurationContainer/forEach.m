function forEach(this,scopes,block,blockparams,impl,implparams)





    if~(ischar(scopes)||iscell(scopes))||~ischar(block)||~ischar(impl)

        fprintf('Invalid configuration ''forEach'' statement in file: %s',this.fileName);
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
            implparams={{{block},implparams{:}}};
        else
            implparams={{block;implparams}};
        end
    end

    if iscell(scopes)
        for ii=1:length(scopes)
            newbinding=local_make_configstmt(scopes{ii},block,blockparams,impl,implparams);
            if isempty(this.statements)
                this.statements=newbinding;
            else
                this.statements(end+1)=newbinding;
            end
        end
    else
        newbinding=local_make_configstmt(scopes,block,blockparams,impl,implparams);
        if isempty(this.statements)
            this.statements=newbinding;
        else
            this.statements(end+1)=newbinding;
        end
    end




    function newbinding=local_make_configstmt(scope,block,blockparams,impl,implparams)
        newbinding=struct(...
        'Scope',scope,...
        'BlockType',block,...
        'BlockParams',blockparams,...
        'Implementation',impl,...
        'ImplParams',implparams);


