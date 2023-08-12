function t = mustBeStringProperty( t, names )



R36
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpiFyMHP.p.
% Please follow local copyright laws when handling this file.

