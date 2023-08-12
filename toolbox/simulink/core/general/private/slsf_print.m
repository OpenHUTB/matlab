
function slsf_print( pj )


if ( isprop( 0, 'TerminalProtocol' ) && ~strcmpi( get( 0, 'TerminalProtocol' ), 'x' ) )

ex = MException( message( 'Simulink:Printing:NoPrintingWithoutDisplay' ) );
throw( ex );
end 


drawnow;

slSfObj = SLPrint.Utils.GetSLSFObject( pj.Handles{ 1 } );
mode = SLPrint.Utils.SLSFGet( slSfObj, 'PaperPositionMode' );
switch mode
case 'tiled'
pj.TiledPrint = 1;
pj.frame = 0;
case 'frame'
pj.TiledPrint = 0;
pj.frame = 1;
otherwise 
pj.TiledPrint = 0;
pj.frame = 0;
end 


if ( isempty( pj.PrinterName ) && ( strcmpi( pj.Driver, 'pdfe' ) || ~strcmpi( pj.DriverExt, 'pdf' ) ) )
SLPrint.PrintJobGateway.ExecutePrintJob( pj );
else 

GLUE2.Portal.beginSpooling;

try 
SLPrint.PrintJobGateway.ExecutePrintJob( pj );
catch me
GLUE2.Portal.cancelSpooling;
rethrow( me );
end 


GLUE2.Portal.endSpooling;
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpMWn7cJ.p.
% Please follow local copyright laws when handling this file.

