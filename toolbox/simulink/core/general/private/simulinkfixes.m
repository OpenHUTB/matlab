function action_performed = simulinkfixes( aMsgId, varargin )




fix_function = [ 'fix', aMsgId ];
action_performed = feval( fix_function, varargin );
end 


function action_performed = fixStrictBusMigrationError( varargin )
model = varargin{ 1 }{ 1 };




upgradeadvisor( model );


action_performed = '';
end 

function action_performed = fixInportDataTypeMismatch( varargin )
model = bdroot( varargin{ 1 }{ 1 } );
set_param( model, 'LoadExternalInput', 'off' );
action_performed = message( 'Simulink:SimInput:InportDataTypeMismatchFix' ).getString(  );
end 

function action_performed = fixLoadingDataTypeMismatch( varargin )
model = bdroot( varargin{ 1 }{ 1 } );
set_param( model, 'LoadExternalInput', 'off' );
action_performed = message( 'Simulink:SimInput:LoadingDataTypeMismatchFix' ).getString(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHyfJCM.p.
% Please follow local copyright laws when handling this file.

