function sub_array = slselsubs( varargin )









if length( varargin ) < 2
DAStudio.error( 'Simulink:blocks:SlselsubsNotEnoughArgs' );
end 

a = varargin{ 1 };
idx = varargin{ 2 };
toend = false;
if length( varargin ) > 2
toend = varargin{ 3 };
end 

size_a = size( a );
if length( size_a ) ~= 2 || ( size_a( 1 ) > 1 && size_a( 2 ) > 1 )
DAStudio.error( 'Simulink:blocks:SlselsubsFirstArgNotVector' );
end 

if ~isnumeric( idx ) || ~isvector( idx )
DAStudio.error( 'Simulink:blocks:SlselsubsSecondArgNotVectorOrScalar' );
end 

if ~islogical( toend ) || ~isscalar( toend )
DAStudio.error( 'Simulink:blocks:SlselsubsThirdArgNotLogicScalar' );
end 

if toend
if ~isscalar( idx )
DAStudio.error( 'Simulink:blocks:SlselsubsSecondArgNotScalarAsStartingIdx' );
end 
sub_array = a( idx:end  );
elseif iscell( a )
sub_array = a{ idx };
else 
sub_array = a( idx );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSHOigg.p.
% Please follow local copyright laws when handling this file.

