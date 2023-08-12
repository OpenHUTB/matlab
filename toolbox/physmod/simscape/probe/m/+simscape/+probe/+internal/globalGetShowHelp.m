function shouldShow = globalGetShowHelp( stage )



R36
stage
end 
shouldShow = true;
prefs = getpref( prefs_name(  ) );
if isfield( prefs, stage_field_name( stage ) )
shouldShow = prefs.( stage_field_name( stage ) );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpJrdxlw.p.
% Please follow local copyright laws when handling this file.

