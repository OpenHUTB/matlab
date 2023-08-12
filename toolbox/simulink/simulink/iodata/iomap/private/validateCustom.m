function validateCustom( customFcn )





if isstring( customFcn ) && isscalar( customFcn )
customFcn = char( customFcn );
elseif isstring( customFcn ) && ~isscalar( customFcn )
DAStudio.error( 'sl_inputmap:inputmap:apiCustomFunctionValue' );
end 

[ ~, customFcn, ~ ] = fileparts( customFcn );


if ~ischar( customFcn ) || ( ~exist( customFcn, 'file' ) )
DAStudio.error( 'sl_inputmap:inputmap:apiCustomFunctionValue' );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpKH5K5g.p.
% Please follow local copyright laws when handling this file.

