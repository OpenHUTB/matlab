function retVal = pmsl_cachedsetparam( varargin )















































persistent PARAM_CACHE;
retVal = [  ];
if nargin == 1 && ischar( varargin{ 1 } )
cmdStr = lower( strtrim( varargin{ 1 } ) );
switch cmdStr
case { 'purge', 'reset' }
if ~isempty( PARAM_CACHE )
PARAM_CACHE = [  ];
end 
case 'get'
retVal = PARAM_CACHE;
case 'set'
if ~isempty( PARAM_CACHE ) &&  ...
isfield( PARAM_CACHE, 'mParams' ) &&  ...
~isempty( PARAM_CACHE.mParams )
pairs = lGetModified( PARAM_CACHE.mBlockHandle, PARAM_CACHE.mParams( : ) );
if ~isempty( pairs )
set_param( PARAM_CACHE.mBlockHandle, pairs{ : } );
end 
pmsl_cachedsetparam( 'purge' );
end 
end 
else 


if nargin == 1 && iscell( varargin{ 1 } )
tmpCell = varargin{ 1 };
elseif nargin > 1
tmpCell = varargin;
end 


assert( isempty( PARAM_CACHE ) ||  ...
~isfield( PARAM_CACHE, 'mBlockHandle' ) ||  ...
PARAM_CACHE.mBlockHandle == tmpCell{ 1 } );
if ( ~isfield( PARAM_CACHE, 'mBlockHandle' ) )
PARAM_CACHE.mBlockHandle = tmpCell{ 1 };
end 


tmpCellTail = tmpCell( 2:end  );


if ( ~isfield( PARAM_CACHE, 'mParams' ) )
PARAM_CACHE.mParams = {  };
end 
PARAM_CACHE.mParams = [ PARAM_CACHE.mParams( : )', tmpCellTail( : )' ];

end 

end 

function pairs = lGetModified( hBlk, pairs )





mn = get_param( hBlk, 'MaskNames' );
mv = get_param( hBlk, 'MaskValues' );
pn = pairs( 1:2:end  );
pv = pairs( 2:2:end  );
[ ~, iP, iM ] = intersect( lower( pn ), lower( mn ), 'stable' );
if numel( iP ) == numel( pn )
iModified = ~strcmp( pv, mv( iM ) );
pn = pn( iModified );
pv = pv( iModified );
pairs = [ pn';pv' ];
pairs = pairs( : );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpDdn8nU.p.
% Please follow local copyright laws when handling this file.

