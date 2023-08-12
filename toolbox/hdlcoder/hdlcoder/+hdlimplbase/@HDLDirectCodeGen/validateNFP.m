function v = validateNFP( this, hC )%#ok<INUSL>


v = hdlvalidatestruct(  );

if targetcodegen.targetCodeGenerationUtils.isNFPMode(  )
blkPath = hC.Name;
try 
blkPath = getfullname( hC.SimulinkHandle );
catch mEx %#ok<NASGU>
end 
for itr = 1:length( hC.PirInputSignals )
refType = hC.PirInputSignals( itr ).Type.getLeafType;
if refType.isFloatType
v = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:Nfp_unsupported_block', blkPath ) );
return ;
end 
end 

for itr = 1:length( hC.PirOutputSignals )
refType = hC.PirOutputSignals( itr ).Type.getLeafType;
if refType.isFloatType
v = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:Nfp_unsupported_block', blkPath ) );
return ;
end 
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpSipUqy.p.
% Please follow local copyright laws when handling this file.

