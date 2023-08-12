function writeUserDefinedHeaderIf( ~, fid, infoStruct )



if infoStruct.hasWrapper

fprintf( fid, '  %%if IsModelReferenceSimTarget() || CodeFormat=="S-Function" || ::isRAccel\n' );
else 

fprintf( fid, '  %%if IsModelReferenceSimTarget()\n' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQ9REiF.p.
% Please follow local copyright laws when handling this file.

