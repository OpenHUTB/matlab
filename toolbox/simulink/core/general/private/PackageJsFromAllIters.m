function Jo = PackageJsFromAllIters( Js, sepABCD )



numJs = length( Js );

A = [  ];
B = [  ];
C = [  ];
D = 0;
for i = 1:numJs
J = Js{ i };
A = blkdiag( A, J.A );
B = vertcat( B, J.B );%#ok<AGROW>
C = horzcat( C, J.C );%#ok<AGROW>
D = D + J.D;
end 

if sepABCD
Jo.A = A;
Jo.B = B;
Jo.C = C;
Jo.D = D;
else 
Jo = sparse( [ A, B;C, D ] );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpY4v_bN.p.
% Please follow local copyright laws when handling this file.

