function openAddonExplorerFor( basecodes )





R36
basecodes( 1, : )string{ mustBeNonempty };
end 

id = "AO_SLTEMPLATE_RP";

if length( basecodes ) == 1
query = "identifier";
else 
query = "identifiers";
end 

matlab.internal.addons.launchers.showExplorer( id, query, basecodes );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2mFzy2.p.
% Please follow local copyright laws when handling this file.

