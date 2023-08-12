function out = getSelectedModelFromDAExplorer(  )

me = daexplr;
im = DAStudio.imExplorer( me );

node = im.getCurrentTreeNode;

if isa( node, 'Simulink.BlockDiagram' )
ismodel = 1;
obj = node;
elseif isa( node, 'Simulink.ConfigSet' ) || isa( node, 'Simulink.ConfigSetRef' )
ismodel = 0;
obj = node;
else 
node = im.getSelectedListNodes;
if isa( node, 'Simulink.BlockDiagram' )
ismodel = 1;
obj = node;
elseif isa( node, 'Simulink.ConfigSet' ) || isa( node, 'Simulink.ConfigSetRef' )
ismodel = 0;
obj = node;
else 
ismodel =  - 1;
obj = [  ];
end 
end 

if ismodel == 1
out.model = obj;
out.cs = getActiveConfigSet( out.model );
elseif ismodel == 0
out.cs = obj;
out.model = obj.getParent;
end 

out.im = im;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJ_Pi4B.p.
% Please follow local copyright laws when handling this file.

