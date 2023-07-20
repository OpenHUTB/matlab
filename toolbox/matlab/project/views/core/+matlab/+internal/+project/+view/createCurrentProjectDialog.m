function dialog=createCurrentProjectDialog(debug)




    if nargin<1
        debug=false;
    end

    currentProjectView=matlab.internal.project.view.CurrentProjectView(debug);

    dialog=matlab.internal.project.view.ProjectDialog(...
    currentProjectView.ViewModel,...
    currentProjectView.Url);

end
