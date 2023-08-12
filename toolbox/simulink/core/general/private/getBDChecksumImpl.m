function [ checksum, additionalInfo ] = getBDChecksumImpl( mdlH )

















































































mdl = get_param( mdlH, 'Name' );
simStatus = get_param( mdl, 'SimulationStatus' );




restorePureIntegerToOn = false;
restoreMdlClean = false;
needToTerm = false;
try 
if ~strcmpi( simStatus, 'paused' )
isAccel = strcmp( get_param( mdl, 'SimulationMode' ), 'accelerator' );
if ( isAccel || ~license( 'test', 'Real-Time_Workshop' ) )
wasMdlClean = strcmpi( get_param( mdl, 'Dirty' ), 'off' );
if ( isAccel )
restorePureIntegerToOn = strcmpi(  ...
get_param( mdl, 'PurelyIntegerCode' ), 'on' );
if restorePureIntegerToOn
set_param( mdl, 'PurelyIntegerCode', 'off' );
if wasMdlClean

set_param( mdl, 'Dirty', 'off' );
end 
end 
end 
restoreMdlClean = wasMdlClean && restorePureIntegerToOn;
feval( mdl, 'initForChecksumsOnly', 'simcmd' );




cleanAfterCompile = strcmpi( get_param( mdl, 'Dirty' ), 'off' );




restoreMdlClean = restoreMdlClean && cleanAfterCompile;
else 


feval( mdl, 'initForChecksumsOnly', 'rtwgen' );
end 
needToTerm = true;
else 
needToTerm = false;
end 

checksum = get_param( mdl, 'ModelChecksum' );

if ( nargout >= 2 )
additionalInfo.ContentsChecksum = get_param( mdl, 'ModelContentsChecksum' );
additionalInfo.InterfaceChecksum = get_param( mdl, 'ModelInterfaceChecksum' );
additionalInfo.ContentsChecksumItems =  ...
get_param( mdl, 'ModelContentsChecksumDetails' );
additionalInfo.InterfaceChecksumItems =  ...
get_param( mdl, 'ModelInterfaceChecksumDetails' );
end 

catch e
localCleanup( mdl, needToTerm, restoreMdlClean, restorePureIntegerToOn );
rethrow( e )
end 

localCleanup( mdl, needToTerm, restoreMdlClean, restorePureIntegerToOn );


end 

function localCleanup( mdl, needToTerm, restoreMdlClean, restorePureIntegerToOn )
if ( needToTerm )
feval( mdl, 'term' );
end 
if restorePureIntegerToOn

set_param( mdl, 'PurelyIntegerCode', 'on' );
end 
if restoreMdlClean

set_param( mdl, 'Dirty', 'off' );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvUnOsh.p.
% Please follow local copyright laws when handling this file.

