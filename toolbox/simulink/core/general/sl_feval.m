function varargout = sl_feval( varargin )





[ varargout{ 1:nargout } ] = feval( varargin{ : } );






sl_feval_vars = setdiff( who, { 'varargin', 'varargout' } );
for sl_feval_idx = 1:length( sl_feval_vars )
assignin( 'caller',  ...
sl_feval_vars{ sl_feval_idx },  ...
eval( sl_feval_vars{ sl_feval_idx } ) );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpCq9lsn.p.
% Please follow local copyright laws when handling this file.

