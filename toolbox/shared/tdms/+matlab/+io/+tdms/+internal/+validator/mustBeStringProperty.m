function t = mustBeStringProperty( t, names )

arguments
    t table
    names( 1, : )string
end
tf = ismember( names, t.Properties.VariableNames );
for name = names( tf )
    if ~isa( t.( name ), "string" )
        eid = "tdms:TDMS:mustBeStringProperty";
        throwAsCaller( MException( eid, message( eid, name ) ) );
    end
end
end
