function globalSetShowHelp( stage, shouldShow )

arguments
    stage
    shouldShow( 1, 1 )logical
end
setpref( prefs_name(  ), stage_field_name( stage ), shouldShow );
end


