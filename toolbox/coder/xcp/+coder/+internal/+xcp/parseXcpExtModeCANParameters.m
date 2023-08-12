




function xcpExtModeArgs = parseXcpExtModeCANParameters( xcpExtModeArgs, tokens, buildInfo )






R36
xcpExtModeArgs
tokens
buildInfo = RTW.BuildInfo.empty(  )
end 


xcpExtModeArgs.canVendor = 'MathWorks';
xcpExtModeArgs.canDevice = 'Virtual 1';
xcpExtModeArgs.canChannel = 1;
xcpExtModeArgs.canIDEBitCommand = 0;
xcpExtModeArgs.canIDEBitResponse = 0;

if isempty( buildInfo )

xcpExtModeArgs.baudRate = 500000;
xcpExtModeArgs.canIDCommand = 4646;
xcpExtModeArgs.canIDResponse = 6565;
else 

defineMap = coder.internal.xcp.a2l.DefineMapFactory.fromBuildInfo( buildInfo );


if defineMap.isKey( 'XCP_CAN_BAUDRATE' )
[ baudrate, elemNumber, errMsg ] = sscanf( defineMap( 'XCP_CAN_BAUDRATE' ), "%i" );
if ~isempty( baudrate ) && ( elemNumber == 1 ) && isempty( errMsg ) && locIsValidBaudrate( baudrate )
xcpExtModeArgs.baudRate = double( baudrate );
else 
xcpExtModeArgs.baudRate = 500000;
MSLDiagnostic( 'coder_xcp:host:InvalidMacroDetected', 'XCP_CAN_BAUDRATE' ).reportAsWarning;
end 
end 


if defineMap.isKey( 'XCP_CAN_ID_MASTER' )
[ canIDCommand, elemNumber, errMsg ] = sscanf( defineMap( 'XCP_CAN_ID_MASTER' ), "%i" );

if ~isempty( canIDCommand ) && ( elemNumber == 1 ) && isempty( errMsg ) && locIsValidCANId( canIDCommand, 1 )
xcpExtModeArgs.canIDCommand = double( canIDCommand );
else 
xcpExtModeArgs.canIDCommand = 4646;
MSLDiagnostic( 'coder_xcp:host:InvalidMacroDetected', 'XCP_CAN_ID_MASTER' ).reportAsWarning;
end 
end 


if defineMap.isKey( 'XCP_CAN_ID_SLAVE' )
[ canIDResponse, elemNumber, errMsg ] = sscanf( defineMap( 'XCP_CAN_ID_SLAVE' ), "%i" );

if ~isempty( canIDResponse ) && ( elemNumber == 1 ) && isempty( errMsg ) && locIsValidCANId( canIDResponse, 1 )
xcpExtModeArgs.canIDResponse = double( canIDResponse );
else 
xcpExtModeArgs.canIDResponse = 6565;
MSLDiagnostic( 'coder_xcp:host:InvalidMacroDetected', 'XCP_CAN_ID_SLAVE' ).reportAsWarning;
end 
end 
end 


if ~isempty( tokens )

xcpExtModeArgs.canVendor = strip( tokens{ 1 }{ 1 }, '''' );


if numel( tokens ) > 1
xcpExtModeArgs.canDevice = strip( tokens{ 2 }{ 1 }, '''' );
end 


if numel( tokens ) > 2 && ~( strcmp( tokens{ 3 }{ 1 }, '[]' ) || strcmp( tokens{ 3 }{ 1 }, '''''' ) )
[ canChannel, elemNumber, errMsg ] = sscanf( tokens{ 3 }{ 1 }, "%i" );

if ~isempty( canChannel ) && ( elemNumber == 1 ) && isempty( errMsg ) && ( canChannel >= 1 )
xcpExtModeArgs.canChannel = double( canChannel );
else 
MSLDiagnostic( 'coder_xcp:host:InvalidCANChannelNumber', xcpExtModeArgs.canChannel ).reportAsWarning;
end 
end 


if numel( tokens ) > 3
[ verbosityLevel, elemNumber, errMsg ] = sscanf( tokens{ 4 }{ 1 }, "%i" );

if ~isempty( verbosityLevel ) && ( elemNumber == 1 ) && isempty( errMsg ) && ( verbosityLevel == 1 )

xcpExtModeArgs.verbosityLevel = 1;
else 

xcpExtModeArgs.verbosityLevel = 0;
end 
end 


if numel( tokens ) > 4 && ~( strcmp( tokens{ 5 }{ 1 }, '[]' ) || strcmp( tokens{ 5 }{ 1 }, '''''' ) )
[ baudRate, elemNumber, errMsg ] = sscanf( tokens{ 5 }{ 1 }, "%i" );

if ~isempty( baudRate ) && ( elemNumber == 1 ) && isempty( errMsg ) && locIsValidBaudrate( baudRate )
xcpExtModeArgs.baudRate = double( baudRate );
else 
MSLDiagnostic( 'coder_xcp:host:InvalidCANBaudrate', xcpExtModeArgs.baudRate ).reportAsWarning;
end 
end 


if numel( tokens ) > 5 && ~( strcmp( tokens{ 6 }{ 1 }, '[]' ) || strcmp( tokens{ 6 }{ 1 }, '''''' ) )
[ canIDEBitCommand, elemNumber, errMsg ] = sscanf( tokens{ 6 }{ 1 }, "%i" );

if ~isempty( canIDEBitCommand ) && ( elemNumber == 1 ) && isempty( errMsg ) &&  ...
( ( canIDEBitCommand == 0 ) || ( canIDEBitCommand == 1 ) )
xcpExtModeArgs.canIDEBitCommand = double( canIDEBitCommand );
else 
MSLDiagnostic( 'coder_xcp:host:InvalidCommandCANIDEBit' ).reportAsWarning;
end 
end 


if numel( tokens ) > 6 && ~( strcmp( tokens{ 7 }{ 1 }, '[]' ) || strcmp( tokens{ 7 }{ 1 }, '''''' ) )
[ canIDCommand, elemNumber, errMsg ] = sscanf( tokens{ 7 }{ 1 }, "%i" );

if ~isempty( canIDCommand ) && ( elemNumber == 1 ) && isempty( errMsg ) &&  ...
locIsValidCANId( canIDCommand, xcpExtModeArgs.canIDEBitCommand )
xcpExtModeArgs.canIDCommand = double( canIDCommand );
else 
MSLDiagnostic( 'coder_xcp:host:InvalidCANIDCommand', xcpExtModeArgs.canIDCommand ).reportAsWarning;
end 
end 


if numel( tokens ) > 7 && ~( strcmp( tokens{ 8 }{ 1 }, '[]' ) || strcmp( tokens{ 8 }{ 1 }, '''''' ) )
[ canIDEBitResponse, elemNumber, errMsg ] = sscanf( tokens{ 8 }{ 1 }, "%i" );

if ~isempty( canIDEBitResponse ) && ( elemNumber == 1 ) && isempty( errMsg ) &&  ...
( ( canIDEBitResponse == 0 ) || ( canIDEBitResponse == 1 ) )
xcpExtModeArgs.canIDEBitResponse = double( canIDEBitResponse );
else 
MSLDiagnostic( 'coder_xcp:host:InvalidResponseCANIDEBit' ).reportAsWarning;
end 
end 


if numel( tokens ) > 8 && ~( strcmp( tokens{ 9 }{ 1 }, '[]' ) || strcmp( tokens{ 9 }{ 1 }, '''''' ) )
[ canIDResponse, elemNumber, errMsg ] = sscanf( tokens{ 9 }{ 1 }, "%i" );

if ~isempty( canIDResponse ) && ( elemNumber == 1 ) && isempty( errMsg ) &&  ...
locIsValidCANId( canIDResponse, xcpExtModeArgs.canIDEBitResponse )
xcpExtModeArgs.canIDResponse = double( canIDResponse );
else 
MSLDiagnostic( 'coder_xcp:host:InvalidCANIDResponse', xcpExtModeArgs.canIDResponse ).reportAsWarning;
end 
end 



if numel( tokens ) > 9
xcpExtModeArgs.symbolsFileName = strip( tokens{ 10 }{ 1 }, '''' );
end 


if numel( tokens ) > 10 && ~( strcmp( tokens{ 11 }{ 1 }, '[]' ) || strcmp( tokens{ 11 }{ 1 }, '''''' ) )
[ targetPollingTime, elemNumber, errMsg ] = sscanf( tokens{ 11 }{ 1 }, "%i" );

if ~isempty( targetPollingTime ) && ( elemNumber == 1 ) && isempty( errMsg ) &&  ...
( targetPollingTime > 0 )
xcpExtModeArgs.targetPollingTime = double( targetPollingTime );
else 
MSLDiagnostic( 'coder_xcp:host:InvalidTargetPollingTime', xcpExtModeArgs.targetPollingTime ).reportAsWarning;
end 
end 
end 
end 

function valid = locIsValidBaudrate( baudrate )
valid = ( baudrate > 0 ) && ( baudrate <= 1000000 );
end 

function valid = locIsValidCANId( canID, IDEBit )
if ( IDEBit == 1 )
bits = 29;
else 
bits = 11;
end 
valid = ( canID >= 0 ) && ( canID < pow2( bits ) );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpX7aYLf.p.
% Please follow local copyright laws when handling this file.

