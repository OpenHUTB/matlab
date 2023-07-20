function app=openClassViewerFromFile(filename)

    filename=string(filename);
    viewers=matlab.diagram.ClassViewer.getAllViewers;
    for i=1:numel(viewers)
        viewer=viewers(i);
        if~isempty(viewer.ActiveFile)&&viewer.ActiveFile==filename
            viewer.Visible=1;
            return;
        end
    end

    matlab.diagram.ClassViewer("Load",filename);
end

