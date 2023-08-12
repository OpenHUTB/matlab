classdef ClassDiagramLaunchManager < handle
methods ( Static )
function app = launchClassViewer( tagID, importCurrentProject )




R36

tagID( 1, 1 )string;


importCurrentProject( 1, 1 )logical = false;
end 
try 

wmgr = classdiagram.app.core.WindowManager.Instance;
app = wmgr.findAppByTag( tagID );
if isempty( app )
cv = matlab.diagram.ClassViewer(  );

app = cv.getApp;

app.notifier.setMode(  ...
classdiagram.app.core.notifications.Mode.UI,  ...
classdiagram.app.core.notifications.Mode.WAIT );

if importCurrentProject
cv.importCurrentProject(  );
end 


app.cdWindow.Tag = tagID;
else 
app.show(  );
end 
catch EX
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpq13R7r.p.
% Please follow local copyright laws when handling this file.

