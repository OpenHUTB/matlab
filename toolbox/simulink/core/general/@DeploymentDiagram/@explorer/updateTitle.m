function updateTitle(h)



    h.Title=DeploymentDiagram.getTitle(h.getRoot);

    h.Icon=fullfile(matlabroot,h.getRoot.getDisplayIcon);

