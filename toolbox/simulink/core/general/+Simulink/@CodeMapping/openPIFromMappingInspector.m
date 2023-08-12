




function openPIFromMappingInspector( ss, ~, ~ )
studio = ss.getStudio;
PI = studio.getComponent( 'GLUE2:PropertyInspector', 'Property Inspector' );
if ~PI.isVisible
studio.showComponent( PI );
end 
PI.restore;
studio.focusComponent( PI );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwakWV2.p.
% Please follow local copyright laws when handling this file.

