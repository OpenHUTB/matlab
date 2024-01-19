function performScopeUpgrades(this)

    block=get_param(this.FullPath,'Handle');
    block_diagram_handle=bdroot(block);

    if any(strcmp(get_param(block_diagram_handle,'Name'),...
        {'dspsnks4','simulink','simviewers'}))||...
        strcmp(get_param(block_diagram_handle,'Lock'),'on')
        return;
    end

    ud=get_param(block,'UserData');
    if(isstruct(ud)&&isfield(ud,'Scope'))
        scopeSpec=get_param(block,'ScopeSpecification');
        if isempty(scopeSpec)

            if isprop(ud.Scope,'ScopeCfg')
                scopeSpec=ud.Scope.ScopeCfg;
            else
                scopeSpec=[];
            end

            if isempty(scopeSpec)
                scopeSpec=Simulink.scopes.TimeScopeBlockCfg;
                warning(message('Spcuilib:scopes:EmptyConfig'));
            end
        end
        scopeCfgString=scopeSpec.toString(false,true);

        set_param(block,'UserData',[],'UserDataPersistent','off');
    else
        scopeSpec=get_param(block,'ScopeSpecification');
        if isempty(scopeSpec)
            scopeSpec=get_param(block,'ScopeSpecificationObject');
        end

        if isempty(scopeSpec)
            scopeCfgString=get_param(block,'DefaultConfigurationName');
        else
            scopeCfgString=scopeSpec.toString(false,true);
        end
    end

    if~isempty(scopeSpec)
        if~isempty(scopeSpec.Scope)
            delete(scopeSpec.Scope);
            scopeSpec.Scope=[];
            scopeSpec.Block=[];
        end

        scopeSpec.Block=this;

        set_param(block,...
        'DefaultConfigurationName',class(scopeSpec),...
        'ScopeSpecificationObject',scopeSpec,...
        'ScopeSpecification',[]);
    end

    set_param(block,'ScopeSpecificationString',scopeCfgString);

    resetCallbacks(block,'OpenFcn');
    resetCallbacks(block,'DeleteFcn');
    resetCallbacks(block,'PreDeleteFcn');
    resetCallbacks(block,'NameChangeFcn');
    resetCallbacks(block,'PreSaveFcn');
    resetCallbacks(block,'CloseFcn');
    resetCallbacks(block,'DestroyFcn');
    resetCallbacks(block,'CopyFcn');
end


function resetCallbacks(blk,uMethod)
    uCallback=get_param(blk,uMethod);
    if strncmp(uCallback,'scopeext',8)||strncmp(uCallback,'simscope',8)
        set(blk,uMethod,'');
    end
end

