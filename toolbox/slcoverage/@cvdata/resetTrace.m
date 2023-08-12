function resetTrace( this )




try 

this.aggregatedTestInfo = [  ];


id = this.id;
cv( 'set', id, '.traceOn', 0 );
if isempty( this.trace )
return ;
end 
traceField = fields( this.trace );
for tIdx = 1:numel( traceField )
if ~strcmpi( traceField{ tIdx }, 'testobjectives' )
cv( 'set', id, [ '.traceData.', traceField{ tIdx } ], [  ] );
end 
end 
metricdataIds = cv( 'get', id, 'testdata.testobjectives' );
metricdataIds( metricdataIds == 0 ) = [  ];
if ~isempty( metricdataIds )
for tIdx = 1:numel( metricdataIds )
cv( 'set', metricdataIds( tIdx ), '.trace.rawdata', [  ] );
end 
end 

catch MEx
rethrow( MEx );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpjWSVk2.p.
% Please follow local copyright laws when handling this file.

