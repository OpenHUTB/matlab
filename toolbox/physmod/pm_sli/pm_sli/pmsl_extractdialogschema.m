function [ widget, path, success ] = pmsl_extractdialogschema( schema, varargin )














isKey = @isfield;
map = @getfield;
isLeaf = @( schema )~isfield( schema, 'Items' );
getNumBranches = @( schema )numel( schema.Items );
getBranch = @( schema, idx )schema.Items{ idx };

reqsCell = varargin;

[ widget, path, success ] = pmsl_extracttreenode( schema, reqsCell, isKey, map, isLeaf, getNumBranches, getBranch );


pm_assert( nargout >= 3 || success );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHTz10N.p.
% Please follow local copyright laws when handling this file.

