function status = logUIEvent( identification, varargin )

R36

identification( 1, 1 )matlab.ddux.internal.UIEventIdentification
end 
R36( Repeating )



varargin
end 


identStruct.product = identification.Product;
identStruct.scope = identification.Scope;
identStruct.eventType = identification.EventType.getString(  );
identStruct.elementType = identification.ElementType.getString(  );
identStruct.elementId = identification.ElementId;


if nargin == 1
data = struct(  );
elseif nargin == 2
data = varargin{ 1 };
else 
data = struct( varargin{ 1:( nargin - 1 ) } );
end 


status = dduxinternal.logUIEvent( identStruct, data );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp5LUSpO.p.
% Please follow local copyright laws when handling this file.

