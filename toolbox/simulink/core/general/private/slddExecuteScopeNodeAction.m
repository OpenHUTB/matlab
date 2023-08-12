







function slddExecuteScopeNodeAction( varargin )
assert( nargin == 2, 'slddExecuteScopeNodeAction expects exactly two args' );
me = daexplr;

selectedNodes = {  };
nodeType = varargin{ 2 };
selectedNodes = me.getListSelection(  );
if isempty( selectedNodes ) ||  ...
~isa( selectedNodes( 1 ), nodeType )


selectedNodes = me.getTreeSelection(  );
if ~isa( selectedNodes, nodeType )
selectedNodes = {  };
end 
end 




if ~isempty( selectedNodes )
action = varargin{ 1 };
len = length( selectedNodes );
for i = 1:len
if isa( selectedNodes( i ), nodeType )
selectedNodes( i ).executeAction( action, me );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmps40RD9.p.
% Please follow local copyright laws when handling this file.

