function dialog = createLabelsDialog( debug )

arguments
    debug = false;
end

referencesView = matlab.internal.project.view.LabelsView( debug );

dialog = matlab.internal.project.view.ProjectDialog(  ...
    referencesView.ViewModel,  ...
    referencesView.Url );

end

