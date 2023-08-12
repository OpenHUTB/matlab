function dialog = createLabelsDialog( debug )




R36
debug = false;
end 

referencesView = matlab.internal.project.view.LabelsView( debug );

dialog = matlab.internal.project.view.ProjectDialog(  ...
referencesView.ViewModel,  ...
referencesView.Url );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBwg7mI.p.
% Please follow local copyright laws when handling this file.

