function AddSelection(block,ax,ports)









    ioSigs=get_block_param(block,'IOSignals');









    if length(ioSigs)<ax



        if ax-length(ioSigs)>1
            ioSigs(end+1:ax)={struct('Handle',-1,'RelativePath','')};
        else
            ioSigs{ax}=struct('Handle',-1,'RelativePath','');
        end
    end

    ioSigs=Simulink.scopes.Util.RemoveInvalHandles(ioSigs,ax);
    axIOSigs=ioSigs{ax};
    for i=1:length(ports)
        hp=ports(i);
        if ishandle(hp)
            axIOSigs(end+1)=struct('Handle',hp,'RelativePath','');%#ok<AGROW>
        end
    end
    [~,i,~]=unique([axIOSigs.Handle],'stable');
    axIOSigs=axIOSigs(i);
    ioSigs{ax}=axIOSigs;

    set_param(block,'IOSignals',ioSigs);







    lines=get_param(ports,'Line');
    if iscell(lines)
        lines=[lines{:}]';
    end
    for i=1:length(lines)
        if(lines(i)>0)
            set_param(lines(i),'Selected','on')
        end
    end

    try



        sso=get_param(block,'ScopeSpecificationObject');
    catch
        sso=[];
    end

    if~isempty(sso)
        hScope=getUnifiedScope(sso);
        if~isempty(hScope)
            updateSourceName(hScope.DataSource);
            updateTitleBar(hScope);
        end
    end


