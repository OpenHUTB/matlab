function simPrintInterfaceView( slStudioApp )

GLUE2.Portal.cancelSpooling;

slActiveEditor = slStudioApp.getActiveEditor;
diagram = slActiveEditor.getDiagram;
model = diagram.Model;
hdl = model.SLGraphHandle;

printOption.PaperType = get_param( hdl, 'PaperType' );
printOption.PaperOrientation = get_param( hdl, 'PaperOrientation' );
printOption.ShowSysPrintDialog = true;

if GLUE2.Portal.setSpoolPrintOptions( printOption )
GLUE2.Portal.beginSpooling;
p = GLUE2.Portal;
canvas = slActiveEditor.getCanvas;
scene = canvas.Scene;
p.print( scene, scene.Bounds );
GLUE2.Portal.endSpooling;
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpm6R4qy.p.
% Please follow local copyright laws when handling this file.

