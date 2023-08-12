function productNames = pmsl_getproductname( licenseNames )



















licensePassedAsChar = false;
if ischar( licenseNames )
licensePassedAsChar = true;
licenseNames = { licenseNames };
end 

if usejava( 'jvm' )

lookUpFcn = @lGetRegisteredDescription;
else 

lookUpFcn = @lGetLocalDescription;
end 

nProducts = numel( licenseNames );
productNames = cell( nProducts, 1 );
for iProduct = 1:nProducts
productNames{ iProduct } = lookUpFcn( licenseNames{ iProduct } );
end 

if licensePassedAsChar && numel( productNames ) > 0
productNames = productNames{ 1 };
end 

end 

function description = lGetRegisteredDescription( theProduct )


productInfo =  ...
com.mathworks.product.util.ProductIdentifier.get( theProduct );
if ~isempty( productInfo )
description = char( productInfo.getName(  ) );
else 
description = theProduct;
end 
end 

function description = lGetLocalDescription( theProduct )


persistent theLicenseMap
if isempty( theLicenseMap )
theEntrees =  ...
{ 'simscape', 'Simscape'
'simdriveline', 'Simscape Driveline'
'simhydraulics', 'Simscape Fluids'
'simmechanics', 'Simscape Multibody'
'power_system_blocks', 'Simscape Electrical' };
theLicenseMap = containers.Map(  ...
theEntrees( :, 1 ), theEntrees( :, 2 ) );
end 
theProduct = lower( theProduct );
if theLicenseMap.isKey( theProduct )
description = theLicenseMap( theProduct );
else 
description = theProduct;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpo07bv0.p.
% Please follow local copyright laws when handling this file.

