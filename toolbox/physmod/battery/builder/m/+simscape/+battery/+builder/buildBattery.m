function buildBattery( battery, buildArguments )




arguments
    battery( 1, 1 ){ mustBeA( battery, [ "simscape.battery.builder.ParallelAssembly",  ...
        "simscape.battery.builder.Module", "simscape.battery.builder.ModuleAssembly",  ...
        "simscape.battery.builder.Pack" ] ) }
    buildArguments.Directory string{ mustBeFolder, mustBeTextScalar } = cd;
    buildArguments.LibraryName string{ mustBeValidVariableName, mustBeTextScalar } = "Batteries"
    buildArguments.MaskParameters string{ mustBeTextScalar,  ...
        mustBeMember( buildArguments.MaskParameters, [ "NumericValues", "VariableNames" ] ) } = "NumericValues";
    buildArguments.MaskInitialTargets string{ mustBeTextScalar,  ...
        mustBeMember( buildArguments.MaskInitialTargets, [ "NumericValues", "VariableNames" ] ) } = "NumericValues";
end


if ~pmsl_checklicense( 'simscape_battery' )
    error( message( 'physmod:battery:license:MissingLicense' ) );
end

try
    libraryBuilder = simscape.battery.builder.internal.export.LibraryBuilder( battery );
    libraryBuilder.LibraryDirectory = buildArguments.Directory;
    libraryBuilder.BatteriesPackageName = buildArguments.LibraryName;
    libraryBuilder.MaskParameters = buildArguments.MaskParameters;
    libraryBuilder.MaskInitialTargets = buildArguments.MaskInitialTargets;
    libraryBuilder.buildLibraries(  );
catch Me
    throwAsCaller( Me );
end
end

