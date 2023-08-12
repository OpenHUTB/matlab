function stiffFlag = stiffDetector( A, stepSize, normIdx )




































switch normIdx
case '1'
fundQty = sum( abs( A ) )' - abs( diag( A ) );
upper = max( fundQty + real( diag( A ) ) );
lower =  - max( fundQty - real( diag( A ) ) );
case 'inf'
fundQty = sum( abs( A' ) )' - abs( diag( A ) );
upper = max( fundQty + real( diag( A ) ) );
lower =  - max( fundQty - real( diag( A ) ) );
case '2'
fundQty = eig( 0.5 .* ( A + A' ) );
upper = max( fundQty );
lower = min( fundQty );
otherwise 
error( 'Error: Not a valid norm for computing the stiffness indicator' );
end 

sigma = 0.5 * ( upper + lower );

stiffFlag = stepSize / ( ( sigma < 0 ) * min( stepSize,  - 1 / sigma ) + ( sigma >= 0 ) * stepSize ) > 1000;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpPgc58Z.p.
% Please follow local copyright laws when handling this file.

