function RemoveSelection(block,ax,ports)








    lines=get_param(ports,'Line');
    if iscell(lines)
        lines=[lines{:}]';
    end
    for i=1:length(lines)

        if(lines(i)>0)
            Simulink.scopes.Util.DeselectLinesAndChildren(lines(i));
        end
    end



    ioSigs=get_block_param(block,'IOSignals');

    axIOSigs=ioSigs{ax};
    for i=1:length(ports)
        hp=ports(i);
        if ishandle(hp)
            axIOSigs([axIOSigs.Handle]==hp)=[];
        end
    end
    ioSigs{ax}=axIOSigs;
    set_param(block,'IOSignals',ioSigs);

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



