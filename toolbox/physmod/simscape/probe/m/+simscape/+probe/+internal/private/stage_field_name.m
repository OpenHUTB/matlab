function name = stage_field_name( stage )

arguments
    stage( 1, 1 )simscape.probe.internal.HelperStage;
end
name = "ShouldShow" + string( stage ) + "Help";
end

