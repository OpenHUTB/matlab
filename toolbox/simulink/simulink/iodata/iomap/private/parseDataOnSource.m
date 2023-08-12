function [ dataOnSource ] = parseDataOnSource( dataSource, fileName, signalName, signalValue )








if ~isempty( signalName ) && ~isempty( signalValue )

dataOnSource.Names = signalName;
dataOnSource.Data = signalValue;

else 


if ~isempty( dataSource )


switch lower( dataSource )


case 'file'


try 


aMat = iofile.MatFile( fileName );


dataOnSource = import( aMat );

catch ME

throwAsCaller( ME );
end 


case 'workspace'


dataOnSource = readBaseWorkspace(  );

end 
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwzoUaa.p.
% Please follow local copyright laws when handling this file.

