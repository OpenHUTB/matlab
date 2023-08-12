function listOfData = readDataSource( dataSource )

try 

aMatFileImport = iofile.MatFile( dataSource );

listOfData = aMatFileImport.whos(  );
catch ME
rethrow( ME );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUtX9MP.p.
% Please follow local copyright laws when handling this file.

