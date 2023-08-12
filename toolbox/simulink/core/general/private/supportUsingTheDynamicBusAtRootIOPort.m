



function result = supportUsingTheDynamicBusAtRootIOPort( dBusName )
busDict = Simulink.BusDictionary.getInstance(  );
result = busDict.findInDBusNameSetForRootIOPort( dBusName );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpJNOlDh.p.
% Please follow local copyright laws when handling this file.

