function status = logData( identification, varargin )

R36

identification( 1, 1 )matlab.ddux.internal.DataIdentification
end 
R36( Repeating )



varargin
end 


identStruct.product = identification.Product;
identStruct.appComponent = identification.AppComponent;
identStruct.eventKey = identification.EventKey;


if nargin == 1
data = struct(  );
elseif nargin == 2
data = varargin{ 1 };
else 
data = struct( varargin{ 1:( nargin - 1 ) } );
end 


status = dduxinternal.logData( identStruct, data );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpNERFuv.p.
% Please follow local copyright laws when handling this file.

