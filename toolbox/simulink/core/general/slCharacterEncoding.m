function varargout = slCharacterEncoding( varargin )











































prevEncoding = get_param( 0, 'CharacterEncoding' );

if nargin > 0
newEncoding = varargin{ 1 };

if ~isempty( newEncoding )
set_param( 0, 'CharacterEncoding', newEncoding );
end 
end 

if nargout == 1 || nargin == 0
varargout = { prevEncoding };
else 
varargout = {  };
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpghhBzf.p.
% Please follow local copyright laws when handling this file.

