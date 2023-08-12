function out_rtp = modifyBDTunableParametersImpl( in_rtp, varargin )

















if nargin < 2

help modifyTunableParameters;
out_rtp = in_rtp;
return ;
end 
out_rtp = sl( 'modifyRTP', in_rtp, varargin{ : } );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpPDx8k1.p.
% Please follow local copyright laws when handling this file.

