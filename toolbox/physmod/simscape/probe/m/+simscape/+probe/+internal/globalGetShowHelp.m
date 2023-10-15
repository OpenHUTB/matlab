function shouldShow = globalGetShowHelp( stage )

arguments
    stage
end
shouldShow = true;
prefs = getpref( prefs_name(  ) );
if isfield( prefs, stage_field_name( stage ) )
    shouldShow = prefs.( stage_field_name( stage ) );
end
end

