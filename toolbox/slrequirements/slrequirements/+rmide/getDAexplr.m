

function me=getDAexplr()
    me=[];
    if~dig.isProductInstalled('Simulink')||~is_simulink_loaded
        return;
    end

    root=slroot;
    daRoot=DAStudio.Root;
    explorers=daRoot.find('-isa','DAStudio.Explorer');
    for i=1:length(explorers)
        explorerRoot=explorers(i).getRoot;
        if isa(explorerRoot,"DAStudio.DAObjectProxy")
            explorerRoot=explorerRoot.getMCOSObjectReference;
        end
        if root==explorerRoot
            me=explorers(i);
            break;
        end
    end
end
