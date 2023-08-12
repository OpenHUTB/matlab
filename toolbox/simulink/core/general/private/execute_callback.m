function execute_callback( obj, cbname )



oldcba = callback_annotation( obj );
toExec = get( obj, cbname );
[ bd, err ] = getBlockDiagramName( obj );
if ( err == 0 )
c = onCleanup( @(  )callback_cleanup( oldcba ) );
try 
evalin( 'base', toExec );
catch 

lr = lasterr;
[ begin, term ] = regexp( lr, '^Error.*evalin\n' );
lr( begin:term ) = [  ];
disp( [ 'Error executing callback ''', cbname, '''' ] );
disp( lr );
end 
else 
callback_annotation( oldcba );
end 

function [ bdname, err ] = getBlockDiagramName( objit )

while ( ~isa( objit, 'Simulink.BlockDiagram' ) )
objit = objit.up;
if ( isempty( objit ) )
bdname = '';
err = 1;
return ;
end 
end 
err = 0;
bdname = objit.Name;

function callback_cleanup( oldcba )
callback_annotation( oldcba );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpitp8FJ.p.
% Please follow local copyright laws when handling this file.

