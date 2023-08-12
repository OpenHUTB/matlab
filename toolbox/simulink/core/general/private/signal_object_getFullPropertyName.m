function path = signal_object_getFullPropertyName( signalObj, prop )




tempPath = [ 'CoderInfo.', prop ];
if signalObj.isValidProperty( tempPath )
path = tempPath;
return ;
end 

tempPath = [ 'CoderInfo.CustomAttributes.', prop ];
if signalObj.isValidProperty( tempPath )
path = tempPath;
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpuoivSf.p.
% Please follow local copyright laws when handling this file.

