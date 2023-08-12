function generateFGRunScript( h )






R36
h Aero.FlightGearAnimation
end 





if h( 1 ).Architecture == Aero.internal.flightgear.Architecture.Default
operatingSystem = computer(  );
else 
switch h( 1 ).Architecture

case Aero.internal.flightgear.Architecture.Win64
operatingSystem = "PCWIN64";
case Aero.internal.flightgear.Architecture.Linux
operatingSystem = "GLNXA64";
case Aero.internal.flightgear.Architecture.Mac
operatingSystem = "MACI64";
case Aero.internal.flightgear.Architecture.MacARM
operatingSystem = "MACA64";
end 
end 



if isempty( h( 1 ).FlightGearBaseDirectory )
errormsg = message( 'aero:aerofgrunscript:InvalidPath', h( 1 ).FlightGearBaseDirectory );
titlemsg = message( 'aero:aerofgrunscript:InvalidFileNameTitle' );
h.throwError( errormsg, titlemsg );
return 
end 



[ header, errorThrown ] = Aero.internal.flightgear.generateScriptHeader( h( 1 ), operatingSystem );
if errorThrown
return 
end 

environment = Aero.internal.flightgear.generateScriptEnvironment( h( 1 ), operatingSystem );
cmd = Aero.internal.flightgear.generateScriptCommand( h( 1 ), operatingSystem );
flags = arrayfun( @( hh )Aero.internal.flightgear.generateScriptCommandFlags( hh, operatingSystem ), h );
multiplayerFlags = Aero.internal.flightgear.generateScriptMultiplayerFlags( h );

cmd = cmd + " " + flags( : ) + " " + multiplayerFlags + " " + [ h.CustomCommandLineOptions ].';


if operatingSystem ~= "PCWIN64"
cmd = cmd + " &";
end 

fileText = [ 
header;
missing;
environment;
missing;
cmd;
 ];
fileText = fillmissing( fileText, "constant", "" );




[ fid, sysMessage ] = fopen( h( 1 ).OutputFileName, 'wt+' );


if fid ==  - 1
errormsg = message( 'aero:aerofgrunscript:InvalidFileName', h( 1 ).OutputFileName, sysMessage );
errortitle = message( 'aero:aerofgrunscript:InvalidFileNameTitle' );
h( 1 ).throwError( errormsg, errortitle );
return 
end 


fprintf( fid, "%s\n", fileText );


fclose( fid );


if ~ispc
fileattrib( h( 1 ).OutputFileName, '+x' );
end 



if ~isfolder( h( 1 ).FlightGearBaseDirectory )
warning( message( 'aero:aerofgrunscript:FGDirNotFound', h( 1 ).FlightGearBaseDirectory ) );
return 
end 


if ( operatingSystem == "MACI64" || operatingSystem == "MACA64" )
FGAircraftDirectory = fullfile( h( 1 ).FlightGearBaseDirectory,  ...
'Contents', 'Resources', 'data', 'Aircraft' );
else 
FGAircraftDirectory = fullfile( h( 1 ).FlightGearBaseDirectory, 'data', 'Aircraft' );
end 

FGGeometryDirectory = fullfile( FGAircraftDirectory, string( { h.GeometryModelName }.' ) );


idxFolder = isfolder( FGGeometryDirectory );
if all( idxFolder )
return 
end 


dirXML = dir( fullfile( FGAircraftDirectory, '*', '*.xml' ) );
if isempty( dirXML )
idxXml = false( size( idxFolder ) );
else 
idxXml = any( string( { dirXML.name } ) == ( { h.GeometryModelName } + ".xml" ).', 2 );
end 

idxAircraft = idxXml | idxFolder;
if ~all( idxAircraft )
warning( message( 'aero:aerofgrunscript:FGGeometryNotFound', FGAircraftDirectory ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHyUFX6.p.
% Please follow local copyright laws when handling this file.

