function openAddonExplorerFor( basecodes )

arguments
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
