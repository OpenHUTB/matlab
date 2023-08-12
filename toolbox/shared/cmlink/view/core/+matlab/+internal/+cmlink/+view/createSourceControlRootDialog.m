function dialog = createSourceControlRootDialog( debug )




R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpB1HoXF.p.
% Please follow local copyright laws when handling this file.

