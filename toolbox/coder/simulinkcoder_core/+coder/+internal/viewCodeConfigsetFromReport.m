function viewCodeConfigsetFromReport( url )


[ file, model ] = Simulink.document.parseFileURL( url );
if ~isempty( model )
model = model( 2:end  );
end 

coder.internal.viewCodeConfigset( model, file );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpooyu0G.p.
% Please follow local copyright laws when handling this file.

