function updateMagnitudeLim( p, lim, visFlag )






if nargin < 2 || isempty( lim )
lim = p.pMagnitudeLim;
end 
lim = constrainMagnitudeLim( p, lim );
p.pMagnitudeLim = lim;
p.pMagnitudeLim_Scaled = lim * p.pMagnitudeScale;


if nargin < 3
i_changeMagnitudeLim( p );
else 
i_changeMagnitudeLim( p, visFlag );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3jiE70.p.
% Please follow local copyright laws when handling this file.

