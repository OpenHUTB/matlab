







function xcpExtModeArgs = parseXcpExtModeArgs( extModeMexArgs, transport, modelName, codeGenFolder, buildInfo )








R36
extModeMexArgs
transport
modelName
codeGenFolder
buildInfo = RTW.BuildInfo.empty
end 


assert( ismember( transport,  ...
{ Simulink.ExtMode.Transports.XCPTCP.Transport,  ...
Simulink.ExtMode.Transports.XCPSerial.Transport,  ...
Simulink.ExtMode.Transports.XCPCAN.Transport } ) );


xcpExtModeArgs.transport = transport;
xcpExtModeArgs.symbolsFileName = getDefaultSymbolsFileName( modelName, codeGenFolder );
xcpExtModeArgs.targetPollingTime = getDefaultTargetPollingTime( modelName );
xcpExtModeArgs.verbosityLevel = 0;


tokens = coder.internal.xcp.tokenizeArgsString( extModeMexArgs );

if strcmp( xcpExtModeArgs.transport, Simulink.ExtMode.Transports.XCPTCP.Transport )
xcpExtModeArgs = coder.internal.xcp.parseXcpExtModeTCPIPParameters( xcpExtModeArgs, tokens );
elseif strcmp( xcpExtModeArgs.transport, Simulink.ExtMode.Transports.XCPSerial.Transport )
xcpExtModeArgs = coder.internal.xcp.parseXcpExtModeSerialParameters( xcpExtModeArgs, tokens );
elseif strcmp( xcpExtModeArgs.transport, Simulink.ExtMode.Transports.XCPCAN.Transport )
xcpExtModeArgs = coder.internal.xcp.parseXcpExtModeCANParameters( xcpExtModeArgs, tokens, buildInfo );
end 

end 

function defaultSymbolsFileName = getDefaultSymbolsFileName( modelName, codeGenFolder )


filesToSearch = {  ...
 ...
 ...
[ modelName, '.pdb' ],  ...
 ...
 ...
[ modelName, '.elf' ],  ...
 ...
[ modelName, '.dwo' ],  ...
 ...
 ...
[ modelName, '.dwarf' ],  ...
 ...
[ modelName, '.exe' ],  ...
 ...
 ...
 ...
modelName ...
 };


for kFile = 1:numel( filesToSearch )
defaultSymbolsFileName = fullfile( codeGenFolder, filesToSearch{ kFile } );
if isfile( defaultSymbolsFileName )
return ;
end 
end 

end 

function pollingTime = getDefaultTargetPollingTime( modelName )


pollingTime = 2.0;

if bdIsLoaded( modelName )
baseRatePeriod = str2double( get_param( modelName, 'CompiledStepSize' ) );
if ~isnan( baseRatePeriod ) && ( baseRatePeriod > 1.0 )






pollingTime = 2 * baseRatePeriod;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEp4ZPY.p.
% Please follow local copyright laws when handling this file.

