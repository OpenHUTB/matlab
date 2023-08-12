function [ blk, submodel, rest, sepChar ] = decpath( varargin )




enc_path = '';
combine = false;

if ( nargin > 0 )
enc_path = varargin{ 1 };
if ~ischar( enc_path )
DAStudio.error( 'Simulink:tools:decPathFirstArgError' );
end 

if ( nargin > 1 )
combine = varargin{ 2 };
if ~islogical( combine )
DAStudio.error( 'Simulink:tools:decPathSecondArgError' );
end 
end 
end 

[ blk, submodel, rest, sepChar ] = slInternal( 'decpath', enc_path, combine );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpI6scgy.p.
% Please follow local copyright laws when handling this file.

