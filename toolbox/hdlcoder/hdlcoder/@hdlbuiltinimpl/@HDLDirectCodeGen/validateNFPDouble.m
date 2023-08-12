function v = validateNFPDouble( this, hC )%#ok<INUSL>


v = hdlvalidatestruct(  );

if targetcodegen.targetCodeGenerationUtils.isNFPMode(  )
blkPath = hC.Name;
try 
blkPath = getfullname( hC.SimulinkHandle );
catch mEx %#ok<NASGU>
end 
for itr = 1:length( hC.PirInputSignals )
refType = hC.PirInputSignals( itr ).Type.getLeafType;
if refType.isDoubleType
v = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:NFPContainsDoubleError' ) );
return ;
end 
end 

for itr = 1:length( hC.PirOutputSignals )
refType = hC.PirOutputSignals( itr ).Type.getLeafType;
if refType.isDoubleType
v = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:NFPContainsDoubleError' ) );
return ;
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIxsNZy.p.
% Please follow local copyright laws when handling this file.

