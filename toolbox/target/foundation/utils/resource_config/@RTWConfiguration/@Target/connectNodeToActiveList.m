function connectNodeToActiveList(target,node)











    if~isempty(node.up)
        disconnect(node)
    end











    x='x';
    pattern=node.sourceLibrary;
    while 1
        node_l=target.activeList.find('-regexp','sourceLibrary',...
        ['^',pattern,'$']);
        if~isempty(node_l)|isempty(x)
            break;
        end
        x=findstr(pattern,'/');
        if~isempty(x)
            pattern=pattern(1:x(end)-1);
        end
    end





    if isempty(node_l)
        n=target.getNodes('active');
        for i=1:length(n)
            sl=n(i).sourceLibrary;


            b=find_system(sl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'linkstatus','resolved');
            c=get_param(b,'referenceblock');
            d=get_param(c,'parent');
            e=unique(d);
            for j=1:length(e)
                if regexp(pattern,['^',e{j},'$']);
                    node_l=n(i);
                    break;
                end
            end
            if~isempty(node_l)
                break;
            end
        end
    end

    if~isempty(node_l)
        node_l=node_l(1);
        node.connect(node_l,'left');
    else



        node_r=target.activeList.find('-class','RTWConfiguration.Node');
        if~isempty(node_r)
            node_r=node_r(1);
            node.connect(node_r,'right');
        else


            target.activeList.connect(node,'down');
        end
    end

    if~isempty(node.data)
        node.data.activate(node,target)
    end


