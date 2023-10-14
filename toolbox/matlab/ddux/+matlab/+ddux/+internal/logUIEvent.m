function status = logUIEvent( identification, varargin )

arguments

    identification( 1, 1 )matlab.ddux.internal.UIEventIdentification
end
arguments( Repeating )
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

