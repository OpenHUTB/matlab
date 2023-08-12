function pc = getCheckedoutProduct( prod_code_list )






pc = '';



l = license( 'inuse' );
for i = 1:numel( l )
prodname = matlab.internal.product.getProductNameFromFeatureName( l( i ).feature );
basecode = matlab.internal.product.getBaseCodeFromProductName( prodname );
if ( any( ismember( prod_code_list, basecode ) ) )
pc = basecode;
break ;
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp7Jp4mf.p.
% Please follow local copyright laws when handling this file.

