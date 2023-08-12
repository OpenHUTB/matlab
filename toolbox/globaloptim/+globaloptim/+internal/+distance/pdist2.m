function distance = pdist2( X, Y, dtol )








R36
X double
Y double = [  ]
dtol( 1, 1 )double = 0
end 


Xt = X';

if isempty( Y )
singleSet = true;
else 
Yt = Y';
singleSet = false;
end 

if isempty( X ) || ( isempty( Y ) && ~singleSet )

distance = [  ];
return ;
end 














if singleSet

distance = sqrt( globaloptim.internal.mexfiles.mx_distancepoints( Xt ) );
else 
distance = sqrt( globaloptim.internal.mexfiles.mx_distancepoints( Xt, Yt, dtol ) );

distance = distance';
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpCpdYv4.p.
% Please follow local copyright laws when handling this file.

