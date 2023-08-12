function varargout = PWMWriteCb( func, blkH, varargin )





if nargout == 0
feval( func, blkH, varargin{ : } );
else 
[ varargout{ 1:nargout } ] = feval( func, blkH, varargin{ : } );
end 
end 


function MaskInitFcn( blkH )%#ok<*DEFNU>
persistent hadError
if isempty( hadError )
hadError = false;
end 
locSetMaskHelp( blkH );
try 


if isequal( get_param( bdroot( blkH ), 'SimulationStatus' ), 'stopped' ) ||  ...
isequal( get_param( bdroot( blkH ), 'SimulationStatus' ), 'updating' )

end 
soc.internal.setBlockIcon( blkH, 'socicons.PWM' );
inPort1 = sprintf( 'port_label(''input'',1, '''')' );
outPort1 = sprintf( 'port_label(''output'',1, ''msg'')' );

blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );




set_param( blkPath, 'BlockSID', codertarget.peripherals.utils.getBlockSID( blkH, false ) );


PwmDrvBlock = [ blkPath, '/Variant/CODEGEN/PWM Write' ];
set_param( PwmDrvBlock, 'BlockID', codertarget.peripherals.utils.getBlockSID( blkH, true ) );

fullLabel = sprintf( '%s;\n %s;',  ...
inPort1, outPort1 );
set_param( blkH, 'MaskDisplay', fullLabel );
blkPath = [ get( blkH, 'Path' ), '/', get( blkH, 'Name' ) ];

inPort1 = sprintf( 'port_label(''input'',1, ''compare'')' );
if ( strcmpi( get_param( blkH, 'ShowPeriodInp' ), 'on' ) && strcmpi( get_param( blkH, 'ShowPhaseInp' ), 'on' ) )
replace_block( [ blkPath, '/Period' ], 'Ground', 'Inport', 'noprompt' );
replace_block( [ blkPath, '/Phase' ], 'Ground', 'Inport', 'noprompt' );
inPort2 = sprintf( 'port_label(''input'',2, ''period'')' );
inPort3 = sprintf( 'port_label(''input'',3, ''phase'')' );
fullLabel = sprintf( '%s;\n %s;\n %s;\n %s;',  ...
inPort1, inPort2, inPort3, outPort1 );
set_param( blkH, 'MaskDisplay', fullLabel );
elseif ( strcmpi( get_param( blkH, 'ShowPeriodInp' ), 'on' ) && strcmpi( get_param( blkH, 'ShowPhaseInp' ), 'off' ) )
replace_block( [ blkPath, '/Period' ], 'Ground', 'Inport', 'noprompt' );
replace_block( [ blkPath, '/Phase' ], 'Inport', 'Ground', 'noprompt' );
inPort2 = sprintf( 'port_label(''input'',2, ''period'')' );
fullLabel = sprintf( '%s;\n %s;\n %s;',  ...
inPort1, inPort2, outPort1 );
set_param( blkH, 'MaskDisplay', fullLabel );
elseif ( strcmpi( get_param( blkH, 'ShowPeriodInp' ), 'off' ) && strcmpi( get_param( blkH, 'ShowPhaseInp' ), 'on' ) )
replace_block( [ blkPath, '/Phase' ], 'Ground', 'Inport', 'noprompt' );
replace_block( [ blkPath, '/Period' ], 'Inport', 'Ground', 'noprompt' );
inPort2 = sprintf( 'port_label(''input'',2, ''phase'')' );
fullLabel = sprintf( '%s;\n %s;\n %s;',  ...
inPort1, inPort2, outPort1 );
set_param( blkH, 'MaskDisplay', fullLabel );
else 
replace_block( [ blkPath, '/Period' ], 'Inport', 'Ground', 'noprompt' );
replace_block( [ blkPath, '/Phase' ], 'Inport', 'Ground', 'noprompt' );
fullLabel = sprintf( '%s;\n %s;',  ...
inPort1, outPort1 );
set_param( blkH, 'MaskDisplay', fullLabel );
end 

catch ME
hadError = true;
rethrow( ME );
end 
end 


function setPeripheralConfigButtonVisibility( blkH )

codertarget.peripherals.utils.setBlockMaskButtonVisibility( blkH, 'PeripheralConfigBtn' );
end 


function locSetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_pwmwrite'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpGErMQg.p.
% Please follow local copyright laws when handling this file.

