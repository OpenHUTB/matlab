function dialog=createReferencesDialog(debug)




    if nargin<1
        debug=false;
    end

    referencesView=matlab.internal.project.view.ReferencesView(debug);

    dialog=matlab.internal.project.view.ProjectDialog(...
    referencesView.ViewModel,...
    referencesView.Url);

end
