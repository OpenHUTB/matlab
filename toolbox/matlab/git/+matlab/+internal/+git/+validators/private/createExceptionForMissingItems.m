function ex = createExceptionForMissingItems( missingItems, errorID )




numOfMissingItems = numel( missingItems );
if numOfMissingItems <= 6
msgIDs = [  ...
"MATLAB:validators:OneField",  ...
"MATLAB:validators:TwoFields",  ...
"MATLAB:validators:ThreeFields",  ...
"MATLAB:validators:FourFields",  ...
"MATLAB:validators:FiveFields",  ...
"MATLAB:validators:SixFields" ...
 ];
messageObject = message( msgIDs( numOfMissingItems ), missingItems{ 1:end  } );
ex = MException( message( errorID, messageObject.getString ) );
else 
ex = MException( message( errorID, createPrintableList( missingItems ) ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxgIHXJ.p.
% Please follow local copyright laws when handling this file.

