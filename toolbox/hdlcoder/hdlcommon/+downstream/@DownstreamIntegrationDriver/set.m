function varargout = set( obj, varargin )








if nargin == 1 && nargout == 0
obj.setdisp;

elseif nargin == 2 && nargout <= 1
optionID = varargin{ 1 };
choice = obj.getOptionChoice( optionID );
varargout{ 1 } = choice;

elseif nargin == 3 && nargout == 0;
optionID = varargin{ 1 };
optionValue = varargin{ 2 };
obj.setOptionValue( optionID, optionValue )

else 
error( message( 'hdlcommon:workflow:SetOptionValue' ) );

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5uutif.p.
% Please follow local copyright laws when handling this file.

