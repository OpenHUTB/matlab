function boardInfo = setBaseProductID( boardInfo, eCSpPkID, soCSpPkgID )







for i = 1:numel( boardInfo )
isSupportedBySoC = boardInfo( i ).IsSoCCompatible;
boardInfo( i ).BaseProductID = getBaseProductIDByInstallContext( eCSpPkID, soCSpPkgID, isSupportedBySoC );
end 
end 


function out = getBaseProductIDByInstallContext( eCSpPkID, soCSpPkgID, isSupportedBySoC )

out = 0;
if codertarget.internal.isSpPkgInstalled( eCSpPkID )
out = out + codertarget.targethardware.BaseProductID.EC;
end 

if codertarget.internal.isSpPkgInstalled( soCSpPkgID ) && isSupportedBySoC
out = out + codertarget.targethardware.BaseProductID.SOC;
end 

out = codertarget.targethardware.BaseProductID( out );


end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpF0qyAJ.p.
% Please follow local copyright laws when handling this file.

