function updateCLI( this, varargin )

try 
this.getCPObj.CLI.set( varargin{ : } );
catch mEx
if strncmp( mEx.identifier, 'HDLShared:CLI:', 14 )
this.addCheck( this.ModelName, 'Error', mEx );



for ii = 1:2:numel( varargin )
if strncmpi( 'errorc', varargin{ ii }, 6 )
this.getCPObj.CLI.ErrorCheckReport = varargin{ ii + 1 };
end 
end 
else 
mEx2 = MException( message( 'HDLShared:CLI:invalidPV' ) ).addCause( mEx );
throw( mEx2 );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpTiVaIR.p.
% Please follow local copyright laws when handling this file.

