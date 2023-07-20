classdef ProjectLaunchManager<handle


    methods(Static)
        function app=showProjectInClassViewer()
            try

                p=currentProject;


                app=classdiagram.app.core.ClassDiagramLaunchManager.launchClassViewer(p.RootFolder,true);
            catch EX
            end
        end
    end

end

