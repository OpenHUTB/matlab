function projectContents = loadProject( projectName, archiveDir )

arguments
    projectName( 1, 1 ){ mustBeTextScalar }
    archiveDir( 1, 1 ){ mustBeTextScalar }
end

assert( exist( archiveDir, "dir" ) == 0 );


sprojFiles = unzip( projectName, archiveDir );


tfVersionR2019bOrLater = any( endsWith( sprojFiles, "modelLookup.mat" ) );
tfVersionPriorR2019b = ~tfVersionR2019bOrLater && any( endsWith( sprojFiles, ".xml" ) );
assert( ~( tfVersionPriorR2019b && tfVersionR2019bOrLater ),  ...
    "Internal error: unexpected project version. Please contact Technical Support." );

if tfVersionPriorR2019b




    projectConverter = SimBiology.web.internal.projectconverter;
    projectConverter.isLoadModelsOnly = true;
    projectConverter.convertProjects( projectName );
    if ~isempty( projectConverter.errors )
        error( message( "SimBiology:diff:UnableToLoadFileVersionPriorR2019b", projectName ) );
    end
    if isempty( projectConverter.project.Models )
        error( message( "SimBiology:diff:NoModelsInFile", projectName ) );
    end
    modelNamesInProject = string( { projectConverter.project.Models.name } );
    modelVariablenamesInProject = repmat( string( missing ), numel( modelNamesInProject ), 1 );
    diagramFiles = repmat( string( fullfile( archiveDir, projectConverter.project.Models.diagramView ) ),  ...
        numel( modelNamesInProject ), 1 );
elseif tfVersionR2019bOrLater



    modelLookup = load( fullfile( archiveDir, 'modelLookup.mat' ) );
    modelLookup = modelLookup.modelLookup;
    if isempty( modelLookup )
        error( message( "SimBiology:diff:NoModelsInFile", projectName ) );
    end
    modelVariablenamesInProject = string( { modelLookup.variableName } );
    modelNamesInProject = string( { modelLookup.name } );
    for i = numel( modelLookup ): - 1:1
        diagramFiles( i ) = string( fullfile( archiveDir, modelLookup( i ).diagramView ) );
    end
else



    loadStruct = load( fullfile( archiveDir, 'simbiodata.mat' ) );
    modelVariablenamesInProject = string( fields( loadStruct ) );
    tfValidScalarModel = arrayfun( @( field )isa( loadStruct.( field ), "SimBiology.Model" ) &&  ...
        isscalar( loadStruct.( field ) ) && isvalid( loadStruct.( field ) ), modelVariablenamesInProject );
    modelVariablenamesInProject = modelVariablenamesInProject( tfValidScalarModel );
    modelNamesInProject = string( arrayfun( @( modelVarName )loadStruct.( modelVarName ).Name,  ...
        modelVariablenamesInProject, "UniformOutput", false ) );
    diagramFiles = repmat( string( missing ), numel( modelNamesInProject ), 1 );
end



projectContents = table( modelNamesInProject( : ),  ...
    modelVariablenamesInProject( : ), diagramFiles( : ),  ...
    'VariableNames', [ "ModelNames", "ModelVariableNames", "DiagramFiles" ] );

end

