function dialog = createSourceControlRootDialog( debug )

arguments
    debug = false;
end

viewModel = matlab.internal.cmlink.view.createStandaloneView(  );
if ( debug )
    url = "/toolbox/shared/cmlink/view/core_web/index-debug.html";
else
    url = "/toolbox/shared/cmlink/view/core_web//index.html";
end
url = url ...
    + "?client=" + viewModel.ClientChannel ...
    + "&server=" + viewModel.ServerChannel ...
    + "&command=" + viewModel.CommandChannel;
url = connector.getUrl( url );

dialog = matlab.internal.cmlink.view.Dialog(  ...
    viewModel,  ...
    url );

end

