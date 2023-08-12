function [ isContainer ] = isContainerSignal( signals )






isContainer = zeros( 1, length( signals ) );


for kSig = 1:length( signals )

if Simulink.sdi.internal.Util.isSimulationDataSet( signals{ kSig } ) ||  ...
( Simulink.sdi.internal.Util.isStructureWithTime( signals{ kSig } ) ||  ...
Simulink.sdi.internal.Util.isStructureWithoutTime( signals{ kSig } ) ) ||  ...
( iofile.Util.isValidSignalDataArray( signals{ kSig } ) &&  ...
~iofile.Util.isValidFunctionCallInput( signals{ kSig } ) &&  ...
~iofile.Util.isFcnCallTableData( signals{ kSig } ) ) ||  ...
iofile.Util.isValidTimeExpression( signals{ kSig } )

isContainer( kSig ) = 1;
end 

end 


end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpw4HbkT.p.
% Please follow local copyright laws when handling this file.

