function kitInfo = kitOpen( kitName, projectName, options )

arguments
    kitName( 1, : ){ mustBeText } = '';
    projectName( 1, : ){ mustBeText } = '';
    options.ServerTest{ mustBeNumericOrLogical } = false;
    options.DownloadOnly{ mustBeNumericOrLogical } = false;
    options.Type{ mustBeText, mustBeMember( options.Type, [ "serial", "parallel", "" ] ) } = "";
    options.MatchPattern{ mustBeText } = "";
end

nargoutchk( 0, 1 );

testUrl = getenv( 'SIT_KIT_SERVER_TEST_URL' );
if isempty( testUrl )
    baseUrl = 'https://ssd.mathworks.com/supportfiles/SIT/kits';
else
    baseUrl = testUrl;
end

listUrl = [ baseUrl, '/sitkitlist.csv' ];
messageString = [  ];

try
    list = webread( listUrl, weboptions( ContentType = 'text' ) );
catch
    list = [  ];
    messageString = message( 'si:kits:ServerUnavailable' );
end
serverDown = isempty( list );

if options.ServerTest
    kitInfo = ~serverDown;
    return ;
end

if serverDown
    error( messageString );
end

if ~( ischar( list ) || isstring( list ) || istable( list ) )
    error( message( 'si:kits:KitInfoFailure' ) );
end
if ~startsWith( list, 'name,type,description,minRelease' ) && ~istable( list )

    error( message( 'si:kits:KitInfoFailure' ) );
end

if ~istable( list )
    cell = textscan( list, '%q%q%q%q', 'Delimiter', ',' );
    cell = [ cell{ : } ];
    list = cell2table( cell( 2:end , : ), 'VariableNames', cell( 1, : ) );
end
if isempty( list )
    error( message( 'si:kits:KitInfoFailure' ) );
end

assert( isa( list, "table" ), message( 'si:kits:KitInfoFailure' ) );
assert( width( list ) == 4, message( 'si:kits:KitInfoFailure' ) );
varNames = { 'name', 'type', 'description', 'minRelease' };
assert( all( contains( list.Properties.VariableNames, varNames ) ),  ...
    message( 'si:kits:KitInfoFailure' ) );
assert( height( list ) > 0, message( 'si:kits:KitInfoFailure' ) );

if ~isempty( kitName ) && ~any( strcmp( list.name, kitName ) )
    options.MatchPattern = kitName;
    kitName = [  ];
    disp( getString( message( 'si:kits:SearchMatchingKits', options.MatchPattern ) ) );
end

if isempty( kitName )

    if options.Type ~= ""
        keep = strcmp( string( list.type ), options.Type );
        list = list( keep, : );
    end

    if options.MatchPattern ~= ""
        keepName = contains( string( list.name ), options.MatchPattern, IgnoreCase = true );
        keepDesc = contains( string( list.description ), options.MatchPattern, IgnoreCase = true );
        list = list( keepName | keepDesc, : );
    end

    keep = arrayfun( @( x )canBeListed( x ), string( list.minRelease ) );
    list = list( keep, : );
    if isempty( list )
        disp( getString( message( 'si:kits:NoMatchingKits' ) ) );
    end

    list.minRelease = arrayfun( @( x )regexprep( x, '_.*', '' ), string( list.minRelease ) );

    if nargout > 0
        kitInfo = list;
    elseif ~isempty( list )

        appNameMap = [ "Parallel Link Designer", "Serial Link Designer" ];
        list.app = arrayfun( @( x )appNameMap( int16( strcmp( x, "serial" ) ) + 1 ), list.type );

        lines = strings( height( list ), 1 );
        for ilist = 1:height( list )
            if canBeDownloaded( char( list.minRelease( ilist ) ) )
                lines( ilist ) = sprintf(  ...
                    '<a href="matlab:openSignalIntegrityKit(''%s'')">%s</a> - %s kit for %s.\n',  ...
                    char( list.name( ilist ) ), char( list.name( ilist ) ),  ...
                    char( list.app( ilist ) ), char( list.description( ilist ) ) );
            else
                note = getString( message( 'si:kits:NewerReleaseNeeded',  ...
                    char( list.name( ilist ) ), char( list.minRelease( ilist ) ) ) );
                lines( ilist ) = sprintf( '%s - %s kit for %s.\n  %s.\n',  ...
                    char( list.name( ilist ) ), char( list.app( ilist ) ),  ...
                    char( list.description( ilist ) ), note );
            end
        end
        disp( strjoin( lines, '' ) );
    end
    return ;
end

kitName = char( kitName );
[ ~, stem, ext ] = fileparts( kitName );
if any( strcmp( ext, { '.klp', '.zip' } ) )
    zipFilePath = kitName;
    if ~isfile( zipFilePath )
        error( message( 'si:kits:KitMustExist', zipFilePath ) );
    end
    kitName = stem;
    zipFileSpecified = true;
else
    zipFileSpecified = false;
end

if ~zipFileSpecified
    minRelease = char( list.minRelease( strcmp( list.name, kitName ) ) );
    canDownload = canBeDownloaded( minRelease );
    if ~canDownload
        msgbox(  ...
            getString( message( 'si:kits:NewerReleaseNeeded', kitName, minRelease ) ),  ...
            getString( message( 'si:kits:MessageBoxTitle' ) ), 'error' );
        kitInfo = [  ];
        return ;
    end
end

if isempty( projectName )
    projectName = kitName;
end

needDownload = true;
if isfolder( projectName )
    newProjectName = getNumberedProjectName( projectName );
    response = existingProjectAction( projectName, newProjectName );
    switch response
        case 'open'
            needDownload = false;
        case 'rename'
            projectName = newProjectName;
        otherwise
            kitInfo = [  ];
            return ;
    end
end

projectExists = isfolder( projectName );
if ~projectExists
    mkdir( projectName );
end

projectWhat = what( projectName );
if ~isempty( projectWhat )
    projectFolder = projectWhat.path;
    if ~projectExists
        rmdir( projectFolder );
    end
else
    error( message( 'si:kits:ProjCreateError', projectName ) );
end

if needDownload

    tempFolder = tempname;
    mkdir( tempFolder );

    if ~zipFileSpecified
        zipFilePath = fullfile( tempFolder, [ kitName, '.zip' ] );
        zipUrl = [ baseUrl, '/', kitName, '.zip' ];
        try
            websave( zipFilePath, zipUrl );
        catch ME
            error( message( 'si:kits:DownloadError', kitName ) );
        end
    end

    try
        unzip( zipFilePath, tempFolder );
    catch ME
        error( message( 'si:kits:ExtractError', ME.message ) );
    end

    extractedFolder = fullfile( tempFolder, kitName );
    if isfolder( extractedFolder )
        movefile( extractedFolder, projectFolder );
        rmdir( tempFolder, 's' );
    else
        error( message( 'si:kits:FolderNotExtracted', extractedFolder ) );
    end
end

if ~options.DownloadOnly

    interfaces = dir( fullfile( projectFolder, 'interfaces' ) );
    interfaceIdx = find( ~contains( { interfaces.name }, '.' ) );
    if interfaceIdx > 0
        interface = string( interfaces( interfaceIdx( 1 ) ).name );

        interfaceFile = fullfile( projectFolder, "interfaces",  ...
            interface, interface + ".qcd" );
        if isfile( interfaceFile )
            serialLinkDesigner( interfaceFile );
        else
            interfaceFile = fullfile( projectFolder, "interfaces",  ...
                interface, interface + ".edk" );
            if isfile( interfaceFile )
                parallelLinkDesigner( interfaceFile );
            else
                error( message( 'si:kits:InterfaceNotFound', interfaceFile ) );
            end
        end
    else
        error( message( 'si:kits:NoInterfaces', projectFolder ) );
    end
end

if nargout > 0
    kitInfo = projectFolder;
end
end


function tf = canBeDownloaded( minRelease )
validateattributes( minRelease, { 'char', 'string' }, { 'nonempty' } );
[ downloadRel, ~ ] = strsplit( char( minRelease ), '_' );
downloadRel = downloadRel{ 1 };
baseRelease = downloadRel( 1:6 );
if length( downloadRel ) > 7 && downloadRel( 7 ) == 'U'
    updateNumber = str2double( downloadRel( 8:end  ) );
else
    updateNumber = 0;
end
tf = ~isMATLABReleaseOlderThan( baseRelease, matlabRelease.Stage, updateNumber );
end


function tf = canBeListed( minRelease )
validateattributes( minRelease, { 'char', 'string' }, { 'nonempty' } );
parts = strsplit( string( minRelease ), '_' );
if length( parts ) < 2
    tf = true;
else
    if startsWith( parts( 2 ), "listnever" )
        tf = false;
    elseif startsWith( parts( 2 ), "listR" )
        listRelease = char( extractAfter( parts( 2 ), "list" ) );
        baseRelease = listRelease( 1:6 );
        if length( listRelease ) > 7 && listRelease( 7 ) == 'U'
            updateNumber = str2double( listRelease( 8:end  ) );
        else
            updateNumber = 0;
        end
        tf = ~isMATLABReleaseOlderThan( baseRelease, matlabRelease.Stage, updateNumber );
    else
        error( message( 'si:kits:BadCSVFormat' ) );
    end
end
end


function newProjectName = getNumberedProjectName( projectName )

newProjectName = projectName;
while isfolder( newProjectName )
    baseName = extractBefore( newProjectName, '_' + digitsPattern + lineBoundary );
    if isempty( baseName )
        baseName = newProjectName;
        sequence = 1;
    else
        suffix = newProjectName( 1, ( length( baseName ) + 1 ):end  );
        sequence = round( str2double( suffix( 2:end  ) ) ) + 1;
    end
    newProjectName = sprintf( '%s_%d', baseName, sequence );
end
end


function action = existingProjectAction( projectName, newProjectName )
dlgTitle = getString( message( 'si:kits:ProjectExistsTitle' ) );
dlgQuestion = getString( message( 'si:kits:ProjectExistsQuestion',  ...
    projectName, newProjectName ) );
openButtonName = getString( message( 'si:kits:OpenButtonName' ) );
renameButtonName = getString( message( 'si:kits:RenameButtonName' ) );
cancelButtonName = getString( message( 'si:kits:CancelButtonName' ) );
response = questdlg( dlgQuestion, dlgTitle,  ...
    openButtonName, renameButtonName, cancelButtonName,  ...
    openButtonName );
switch response
    case openButtonName
        action = 'open';
    case renameButtonName
        action = 'rename';
    otherwise
        action = 'cancel';
end
end


