function creatui(h)



    createactions(h);

    customize(h);
    createtoolbar(h);
    createviewmanager(h);
    updateactions(h,'off',DeploymentDiagram.getactions(h.getRoot));

    if~isempty(h.getRoot)
        h.imme.expandTreeNode(h.getRoot);
        m=h.findNodes('Mapping');
        if~isempty(m)
            for i=1:length(m)
                h.imme.expandTreeNode(m(i));
            end
            swn=h.findNodes('SoftwareNode');
            for i=1:length(swn)
                h.imme.expandTreeNode(swn(i));
            end
        end
    end
    h.show;
