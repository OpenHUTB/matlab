function deleteSSContentsImpl( ss )














if nargin ~= 1
DAStudio.error( 'Simulink:modelReference:slSSDeleteContentsInvalidNumInputs' );
end 

ss = convertStringsToChars( ss );

ssType = Simulink.SubsystemType( ss );
if ~ssType.isSubsystem || ssType.isStateflowSubsystem
DAStudio.error( 'Simulink:modelReference:slSSDeleteContentsInvalidInput' );
end 

Simulink.ModelReference.DeleteContent.deleteContents( ss );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpLTb_86.p.
% Please follow local copyright laws when handling this file.

