function UI_Launch( modelName )




src = simulinkcoder.internal.util.getSource( modelName );
studio = src.studio;
editor = studio.App.getActiveEditor;
cp = simulinkcoder.internal.CodePerspective.getInstance;
cmTask = cp.getTask( 'CodeMapping' );
cmTask.turnOn( editor );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7Ok7hr.p.
% Please follow local copyright laws when handling this file.

