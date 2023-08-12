function v = validateNFPHalf( this, hC )%#ok<INUSL>


v = hdlvalidatestruct(  );

if targetcodegen.targetCodeGenerationUtils.isNFPMode(  )
for itr = 1:length( hC.PirInputSignals )
refType = hC.PirInputSignals( itr ).Type.getLeafType;
if refType.isHalfType
v = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:NFPContainsHalfError' ) );
return ;
end 
end 

for itr = 1:length( hC.PirOutputSignals )
refType = hC.PirOutputSignals( itr ).Type.getLeafType;
if refType.isHalfType
v = hdlvalidatestruct( 1, message( 'hdlcommon:nativefloatingpoint:NFPContainsHalfError' ) );
return ;
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpAd7ONE.p.
% Please follow local copyright laws when handling this file.

