function warmupHelp()





    help figure;


    matlab.internal.web.htmlrenderer('textonly');

    com.mathworks.mlservices.MLHelpServices.registerMLHelpBrowser(...
    'com.mathworks.mlwidgets.help.motw.MotwHelpBrowserRegistrar',...
    'getHelpBrowser',...
    'com.mathworks.mlwidgets.help.motw.MotwHelpBrowser');
    com.mathworks.mlservices.MLHelpServices.registerMLCSHelpViewer(...
    'com.mathworks.mlwidgets.help.motw.MotwCSHelpViewerRegistrar',...
    'getCSHelpViewer');

    com.mathworks.mlwidgets.help.HelpPopup.setShowHelpBrowserPreference(true);

end
