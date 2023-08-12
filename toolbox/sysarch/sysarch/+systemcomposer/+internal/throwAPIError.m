function throwAPIError( id, varargin )



try 
errorId = [ 'systemcomposer:API:', id ];%#ok<NASGU>
msgId = [ 'SystemArchitecture:API:', id ];%#ok<NASGU>
evalStr = 'error(errorId, message(msgId';
for i = 1:numel( varargin )
evalStr = [ evalStr, ',varargin{', num2str( i ), '}' ];%#ok<AGROW>
end 
evalStr = [ evalStr, ').getString)' ];
eval( evalStr );
catch ME
throwAsCaller( ME );
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpAFvgYu.p.
% Please follow local copyright laws when handling this file.

