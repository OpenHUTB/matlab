function TestHarnessActivated( model )






cp = simulinkcoder.internal.CodePerspective.getInstance;
editors = GLUE2.Util.findAllEditors( get_param( model, 'Name' ) );
for ii = 1:numel( editors )
studio = editors( ii ).getStudio;
if ~cp.isInPerspective( editors( ii ) )
cmp = studio.getComponent( 'GLUE2:SpreadSheet', 'CodeProperties' );
if ~isempty( cmp ) && cmp.isVisible
studio.hideComponent( cmp );
end 
cmp = studio.getComponent( 'GLUE2:DDG Component', 'CodePerspective' );
if ~isempty( cmp ) && cmp.isVisible
studio.hideComponent( cmp );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUs7fqH.p.
% Please follow local copyright laws when handling this file.

