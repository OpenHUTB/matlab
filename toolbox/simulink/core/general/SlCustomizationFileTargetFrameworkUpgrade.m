classdef ( Hidden )SlCustomizationFileTargetFrameworkUpgrade < RTW.TargetRegistryFileTargetFrameworkUpgrade







methods ( Access = protected )
function functionArguments = setupRegistrationInjection( this, functionName, registerTargetFunctionHandle )



if ( isequal( functionName, 'sl_customization' ) )





dummy = this.createDummyCustomizationManagerStruct(  );






dummy.registerTargetInfo = registerTargetFunctionHandle;
functionArguments = { dummy };





this.UpgradeCleanupStack( end  + 1 ) = onCleanup( @sl_refresh_customizations );
else 


error( message( 'RTW:targetRegistry:invalidRegistrationFile', this.LegacyRegstrationFilename, 'sl_customization' ) );
end 
end 
end 

methods ( Access = private )

function dummyManager = createDummyCustomizationManagerStruct( ~ )















load_simulink;

backingManager = sl_customization_manager(  );
dummyManager = struct( backingManager );
dummyManager.BackingManager = backingManager;
cmMethods = methods( backingManager );

for i = 1:length( cmMethods )

dummyManager.( cmMethods{ i } ) = @( varargin )dummyManager.BackingManager.( cmMethods{ i } )( varargin{ : } );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpxHOHwN.p.
% Please follow local copyright laws when handling this file.

