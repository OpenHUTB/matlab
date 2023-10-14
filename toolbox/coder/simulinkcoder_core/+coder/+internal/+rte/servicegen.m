function [ buildInfo, buildOpts ] = servicegen(  ...
    intGeneratorFcns, impGeneratorFcns,  ...
    rteFolders, algBuildInfoFolder, codeDescriptor )

arguments
    intGeneratorFcns( 1, : )cell
    impGeneratorFcns( 1, : )cell
    rteFolders( 1, 1 )struct
    algBuildInfoFolder( 1, : )char
    codeDescriptor( 1, 1 )coder.codedescriptor.CodeDescriptor
end


nIntGenerators = numel( intGeneratorFcns );
assert( nIntGenerators > 0, 'No interface generators were passed to servicegen.' );
nImpGenerators = numel( impGeneratorFcns );
for i = 1:nIntGenerators
    assert( isa( intGeneratorFcns{ i }, 'function_handle' ) )
end
for i = 1:nImpGenerators
    assert( isa( impGeneratorFcns{ i }, 'function_handle' ) )
end

assert( all( isfield( rteFolders, { 'intFolder', 'libFolder', 'impFolder', 'exeFolder' } ) ) );
intFolder = rteFolders.intFolder;
libFolder = rteFolders.libFolder;
impFolder = rteFolders.impFolder;
exeFolder = rteFolders.exeFolder;

assert( ~isempty( intFolder ), 'RTE Interface folder cannot be empty.' );
if isempty( libFolder )
    assert( ~isempty( impFolder ) );
    assert( ~isempty( exeFolder ) );
    assert( nImpGenerators > 0 );
else
    assert( isempty( impFolder ) );
    assert( isempty( exeFolder ) );
    assert( nImpGenerators == 0 );
end


assert( isfolder( algBuildInfoFolder ) );
assert( isfile( fullfile( algBuildInfoFolder, 'buildInfo.mat' ) ) );
validateBuildInfoContent = true;
[ algBuildInfo, algBuildOpts ] = coder.make.internal.loadBuildInfo(  ...
    fullfile( algBuildInfoFolder, 'buildInfo.mat' ), validateBuildInfoContent );


if ~isfolder( intFolder )
    mkdir( intFolder );
end

for i = 1:nIntGenerators
    generatorFcn = intGeneratorFcns{ i };

    feval( generatorFcn, codeDescriptor, intFolder, algBuildInfo );
end

if ~isempty( libFolder )


    algBuildInfo.removeSourceFiles( 'ert_main.c' );
    if ~isfolder( libFolder )
        mkdir( libFolder );
    end
    algBuildInfo.ComponentBuildFolder = libFolder;
    algBuildInfo.setOutputFolder( libFolder );
    coder.make.internal.syncRelativePathToAnchor( algBuildInfo );
    algBuildOpts.BuildVariant = 'STATIC_LIBRARY';
    buildInfo = algBuildInfo;
    buildOpts = algBuildOpts;
    save( fullfile( libFolder, 'buildInfo.mat' ), 'buildInfo', 'buildOpts' );
else
    if ~isfolder( impFolder )
        mkdir( impFolder );
    end

    for i = 1:nImpGenerators
        generatorFcn = impGeneratorFcns{ i };

        feval( generatorFcn, codeDescriptor, impFolder, algBuildInfo );
    end
    if ~isfolder( exeFolder )
        mkdir( exeFolder );
    end
    algBuildInfo.ComponentBuildFolder = exeFolder;
    coder.make.internal.syncRelativePathToAnchor( algBuildInfo );
    algBuildOpts.BuildVariant = 'STANDALONE_EXECUTABLE';
    buildInfo = algBuildInfo;
    buildOpts = algBuildOpts;
    save( fullfile( exeFolder, 'buildInfo.mat' ), 'buildInfo', 'buildOpts' );
end

end

