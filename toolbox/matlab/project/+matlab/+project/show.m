function show()







    import matlab.internal.project.util.*;

    if isDesktopAvailable()
        if matlab.internal.project.util.useWebFrontEnd()
            container=matlab.ui.container.internal.RootApp.getInstance();
            panel=container.getPanel('projectFileUI');
            if~isempty(panel)
                panel.Selected=true;
            end
        else
            com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIUtils.showProjectCanvas([]);
        end
    end

end
