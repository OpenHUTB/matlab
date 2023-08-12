function [ hObj, path, success ] = pmsl_getobjecthandle( hBase, varargin )














isKey = @( hBase, prop )isprop( hBase, prop ) || isequal( prop, 'class' );
map = @( hbase, prop )hbase.( prop );
isLeaf = @( hbase )~isprop( hbase, 'Items' );
getNumBranches = @( hbase )numel( hbase.Items );
getBranch = @( hbase, idx )hbase.Items( idx );

reqsCell = varargin;

[ hObj, path, success ] = pmsl_extracttreenode( hBase, reqsCell, isKey, map, isLeaf, getNumBranches, getBranch );


pm_assert( nargout >= 3 || success );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp1Wk2C4.p.
% Please follow local copyright laws when handling this file.

