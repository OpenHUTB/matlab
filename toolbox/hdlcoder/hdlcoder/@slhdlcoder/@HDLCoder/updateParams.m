function updateParams( this, params )


params = orderParams( params );
if ~isempty( params )
this.updateCLI( params{ : } );
end 
end 


function params = orderParams( params )

tlpos = strmatch( 'targetl', lower( params( 1:2:end  ) ) );
if ~isempty( tlpos )
tlpos = ( ( tlpos - 1 ) * 2 ) + 1;
tls = params( tlpos( end  ):tlpos( end  ) + 1 );
for ii = length( tlpos ): - 1:1
params( tlpos( ii ) ) = [  ];
params( tlpos( ii ) ) = [  ];
end 
params = { tls{ 1:end  }, params{ 1:end  } };
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpyNy2Ch.p.
% Please follow local copyright laws when handling this file.

