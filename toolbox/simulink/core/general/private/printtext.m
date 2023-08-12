function printtext( varargin )











ArgsIn = varargin;
printerName = '';

if ( ArgsIn{ 1 }( 1 ) ~= '-' )
if ~ischar( ArgsIn{ 1 } )
DAStudio.error( 'Simulink:utility:fileNameArgMustBeStr' );
else 
filename = ArgsIn;
end 

elseif ( ArgsIn{ 1 }( 2 ) == 'P' )
printerName = ArgsIn{ 1 }( 3:end  );
filename = ArgsIn( 2:end  );

else 
DAStudio.error( 'Simulink:utility:invFileNameOrPrinter' );

end 


for lp = 1:length( filename )
SLPrint.PrintLog.Print( filename{ lp }, printerName );
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpAg7eHN.p.
% Please follow local copyright laws when handling this file.

